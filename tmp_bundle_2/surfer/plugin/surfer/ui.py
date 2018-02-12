# -*- coding: utf-8 -*-
"""
surfer.ui
~~~~~~~~~

This module defines the UserInterface class. This class is responsible
for showing up the Surfer user interface and to display to the user
all matching tags for the given search query.
"""

import logging
log = logging.getLogger(__name__)

from operator import itemgetter
from collections import namedtuple
from itertools import groupby, imap
from os.path import basename, join, expanduser, sep

from surfer.utils import v
from surfer.utils import misc
from surfer.utils import input
from surfer.utils import settings
from surfer.utils import exceptions as ex


class UserInterface:

    def __init__(self, plug):
        self.plug = plug
        self.name = '__surfer__'
        self.renderer = Renderer(plug)
        self.BufInfo = namedtuple("BufInfo", "name nr winnr")
        self.setup_colors()
        self._reset()

    def setup_colors(self):
        """To setup Surfer highlight groups."""

        def colorof(opt):
            postfix = "" if v.opt("bg") == u"light" else "_darkbg"
            color = settings.getd(opt, "color{0}".format(postfix))
            if color:
                return color
            return settings.getd(opt, "color")

        colors = {
            "SurferShade": colorof("shade"),
            "SurferMatches": colorof("matches"),
            "SurferPrompt": colorof("prompt"),
            "SurferCurrLineIndicator": colorof("curr_line_indicator"),
            "SurferError": "WarningMsg",
        }

        postfix = "" if v.opt("bg") == u"light" else "_darkbg"
        kcolors = settings.getd("visual_kinds", "colors{0}".format(postfix))
        kcolors = dict(("SurferVisualKind_{0}".format(k.lower()), val) for k, val in kcolors.items())
        colors.update(kcolors)

        for group, color in colors.items():
            if color:
                link = "" if "=" in color else "link"
                v.exe(u"hi {0} {1} {2}".format(link, group, color))

    def open(self):
        """To open the Surfer user interface."""
        log.info("Surfer user interface opened.")
        # The Fugitive plugin seems to interfere with Surfer since it adds
        # some filenames to the vim option `tags`. Surfer does this too,
        # but if Fugitive is installed and the user is editing a file in a git
        # repository, it seems that Surfer cannot append anything to the
        # `tag` option. I haven't still figured out why this happens but this
        # seems to fix the issue.
        v.exe("exe 'set tags='.&tags")

        self.user_buf = self.BufInfo(v.bufname(), v.bufnr(), v.winnr())

        prompt = u"echohl SurferPrompt | echon \"{0}\" | echohl None".format(
            settings.getd("prompt", "appearance"))

        self._open_window()
        self.renderer.render(self.winnr, -1, "", [], "")
        v.redraw()

        # Start the input loop
        key = input.Input()
        while True:

            self.perform_new_search = True

            # Display the prompt and the current query
            v.exe(prompt)
            query = self.query.replace("\\", "\\\\").replace('"', '\\"')
            v.exe(u"echon \"{0}\"".format(query))

            # Wait for the next pressed key
            key.get()

            # Go to the tag on the current line
            if (key.RETURN or key.CTRL and key.CHAR in ('g', 'o', 'p', 's')):
                mode = key.CHAR if key.CHAR in ('s', 'p') else ''
                tag = self.mapper.get(self.cursor_pos)
                if tag:
                    log.info(u"Jumping to tag '{0}' in {1}".format(tag["name"], tag["file"]))
                    self._jump_to(tag, mode)
                    break

            # Close the Surfer window
            elif key.ESC or key.INTERRUPT:
                self._close()
                break

            # Delete a character backward
            elif key.BS:
                query = self.query.strip()
                self.query = u"{0}".format(self.query)[:-1]
                self.cursor_pos = -1  # move the cursor to the bottom

            # Move the cursor up
            elif key.UP or key.TAB or key.CTRL and key.CHAR == 'k':
                self.perform_new_search = False
                if self.cursor_pos == 0:
                    self.cursor_pos = len(v.buffer()) - 1
                else:
                    self.cursor_pos -= 1

            # Move the cursor down
            elif key.DOWN or key.CTRL and key.CHAR == 'j':
                self.perform_new_search = False
                if self.cursor_pos == len(v.buffer()) - 1:
                    self.cursor_pos = 0
                else:
                    self.cursor_pos += 1

            # Clear the current search
            elif key.CTRL and key.CHAR == 'u':
                query = self.query.strip()
                if query and query[0] in settings.get("filters"):
                    self.query = query[0]
                else:
                    self.query = u""
                self.cursor_pos = -1  # move the cursor to the bottom

            # A character has been pressed.
            elif key.CHAR:
                self.query += key.CHAR
                self.cursor_pos = -1  # move the cursor to the bottom

            else:
                v.redraw()
                continue

            self._update()
            v.redraw()

        log.info("Surfer user interface closed.")

    def _open_window(self):
        """To open the Surfer window if not already visible."""
        if not self.winnr:
            self.exit_cmds.append(u"set ei={0}".format(v.opt("ei")))
            v.exe(u"set eventignore=all")
            v.exe(u'sil! keepa botright 1new {0}'.format(self.name))
            self._setup_buffer()
            self.winnr = v.bufwinnr(self.name)

    def _close(self):
        """To close the Surfer user interface."""
        v.exe('q')
        for cmd in self.exit_cmds:
            v.exe(cmd)
        if self.user_buf.winnr:
            v.focus_win(self.user_buf.winnr)
        self._reset()
        v.redraw()

    def _reset(self):
        """To reset the Surfer user interface state."""
        self.user_buf = None
        self.query = u""
        self.winnr = None
        self.mapper = {}
        self.cursor_pos = -1  # line index in the finder window
        self.exit_cmds = []
        self.search_results_cache = []
        self.perform_new_search = True
        self.plug.use_cache = False

    def _setup_buffer(self):
        """To set sane options for the search results buffer."""
        last_search = ""
        if v.eval("@/"):
            last_search = v.eval("@/").replace(u'"', u'\\"')
        self.exit_cmds.extend([
            u"let @/=\"{0}\"".format(last_search),
            u"set laststatus={0}".format(v.opt("ls")),
            u"set guicursor={0}".format(v.opt("gcr")),
        ])

        commands = [
            "let @/ = ''",
            "call clearmatches()"
        ]

        options = [
            "buftype=nofile", "bufhidden=wipe", "nobuflisted", "noundofile",
            "nobackup", "noswapfile", "nowrap", "nonumber", "nolist",
            "textwidth=0", "colorcolumn=0", "laststatus=0", "norelativenumber",
            "nocursorcolumn", "nospell", "foldcolumn=0", "foldcolumn=0",
            "guicursor=a:hor5-Cursor-blinkwait100",
        ]

        for opt in options:
            v.exe("try|setl {0}|catch|endtry".format(opt))

        for cmd in commands:
            v.exe(cmd)

    def _update(self):
        """To update search results."""
        tags = []
        error = ""
        if self.perform_new_search:
            try:
                max_results = settings.get('max_results', int)
                tags = self.plug.find_tags(self.query, max_results, self.user_buf.name)
                self.search_results_cache = tags
                self.plug.use_cache = True
            except (ex.SurferCtagsError, ex.SurferGenericError, ex.SurferFilterError) as e:
                error = e.message
        else:
            tags = self.search_results_cache

        self.mapper, self.cursor_pos = self.renderer.render(self.winnr, self.cursor_pos, self.query, tags,
                msg=error, iserror=bool(error))

    def _jump_to(self, tag, mode=""):
        """To jump to the tag on the current line."""
        buffer = self.user_buf.name
        self._close()
        count, file = self._tag_count(tag)
        if not v.opt("hidden", fmt=bool) and v.opt("mod", fmt=bool) and file != buffer:
            v.echo(u"Write the buffer first. (:h hidden)", "WarningMsg")
        else:
            v.exe(u"sil! {0}{1}tag {2}".format(count, mode, tag["name"]))
            v.exe("normal! zvzzg^")

    def _tag_count(self, tag):
        """To pick the best tag candidate for a given tag name.

        The number retruned is meant to be used in conjunction with the :tag
        vim command (see :h :tag)
        """
        candidates = v.eval(u'taglist("{0}")'.format(tag["name"]))
        if len(candidates) == 1:
            return 1, candidates[0]["filename"]

        #  group tags by file name
        groups = []
        for fname, g in groupby(candidates, key=itemgetter("filename")):
            groups.append((fname, list(g)))
        groups.sort(key=itemgetter(0))

        # sort tags by the `line` field (XXX: or `cmd`?); tags from of the
        # current buffer are put first. This is ensures that the `:[count]tag
        # [name]` command will work as expected (see :h tag-priority)
        ordered_candidates = []
        for fname, tags in groups:
            keyf = itemgetter("line") if tags[0].get("line") else itemgetter("cmd")
            sorted_tags = sorted(tags, key=keyf)
            # using `endswith(..)` instead of a straight comparison ensures
            # that this still works if relative paths are used in the tag file.
            # (Something that may occurs when Surfer is not responsible for
            # generating tag files)
            if v.bufname().endswith(fname):
                ordered_candidates = sorted_tags + ordered_candidates
            else:
                ordered_candidates.extend(sorted_tags)

        files = [c["filename"] for c in ordered_candidates]
        scores = [0]*len(ordered_candidates)
        for i, candidate in enumerate(ordered_candidates):
            if candidate.get("cmd", "") == tag["cmd"]:
                scores[i] += 1
            if candidate.get("name", "") == tag["name"]:
                scores[i] += 1
            if candidate.get("filename", "") == tag["file"]:
                scores[i] += 1
            if candidate.get("line", "") == tag["exts"].get("line"):
                scores[i] += 1
            if candidate.get("kind", "") == tag["exts"].get("kind"):
                scores[i] += 1
            if candidate.get("language", "") == tag["exts"].get("language"):
                scores[i] += 1

        idx = scores.index(max(scores))
        return idx + 1, files[idx]


class Renderer:

    def __init__(self, plug):
        self.plug = plug
        self.formatter = Formatter(plug)

    def render(self, target_win, cursor_pos, query, tags, msg="", iserror=False):
        """To render all search results."""
        v.exe('syntax clear')
        v.focus_win(target_win)
        mapper = {}

        if not tags and not msg:
            msg = settings.get("no_results_msg")

        if msg:

            v.setbuffer(msg)
            v.setwinh(len(msg.split("\n")))
            v.exe(u"setl nocursorline")
            cursor_pos = 0
            if iserror:
                self._highlight_err()

        else:

            tags = tags[::-1]
            mapper = dict(enumerate(t for t in tags))
            dups = misc.duplicates(imap(basename, set(t["file"] for t in tags)))
            v.setbuffer([self._render_line(t, query, dups) for t in tags])
            cursor_pos = self._render_curr_line(cursor_pos)
            v.setwinh(len(tags))
            self._highlight_tags(tags, cursor_pos)

            if settings.get("cursorline", bool):
                v.exe(u"setl cursorline")
            else:
                v.exe(u"setl nocursorline")

        v.cursor((cursor_pos + 1, 0))
        v.exe("normal! 0")

        return mapper, cursor_pos

    def _render_line(self, tag, query, duplicates):
        """To format a single line with the tag information."""
        visualkind = u""
        if settings.getd("visual_kinds", "active", bool):
            visualkind = settings.getd("visual_kinds", "appearance")
        line_format = settings.get("line_format")
        debug = settings.get("debug", bool)
        return u"{0}{1}{2}{3}{4}".format(
            u" "*len(settings.getd("curr_line_indicator", "appearance")),
            visualkind, tag["name"],
            u"".join(self.formatter.fmt(fmtstr, tag, duplicates) for fmtstr in line_format),
            u" ({0:.4} | {1})".format(tag["similarity"], tag["positions"]) if debug else u"")

    def _render_curr_line(self, cursor_pos):
        """To add an indicator in front of the current line."""
        if cursor_pos < 0:
            cursor_pos = len(v.buffer()) - 1

        line = v.getline(cursor_pos)
        indicator = settings.getd("curr_line_indicator", "appearance")
        v.setline(cursor_pos, indicator + line[len(indicator):])

        return cursor_pos

    def _highlight_err(self):
        """To highlight the content of the Surfer window as error."""
        v.highlight("SurferError", ".*")

    def _highlight_tags(self, tags, curr_line):
        """To highlight search results."""
        vkappearance = settings.getd("visual_kinds", "appearance")
        indicator = settings.getd("curr_line_indicator", "appearance")

        for i, tag in enumerate(tags):

            if i == curr_line:
                offset = len(v.encode(indicator))
                patt = u"\%{0}l\%<{1}c.\%>{2}c".format(i+1, offset+1, 0)
                v.highlight("SurferCurrLineIndicator", patt)
            else:
                offset = len(indicator)

            if settings.getd("visual_kinds", "active", bool):
                offset += len(v.encode(vkappearance))
                kind = tag["exts"].get("kind").lower()
                patt = u"\c\%{0}l{1}".format(i+1, vkappearance.replace(u"u",u"%u"))
                v.highlight("SurferVisualKind_" + kind, patt)

            patt = u"\c\%{0}l\%{1}c.*".format(i+1, offset+len(tag["name"])+1)
            v.highlight("SurferShade", patt)

            for pos in misc.as_byte_indexes(tag["positions"], tag["name"]):
                patt = u"\c\%{0}l\%{1}c.".format(i+1, offset+pos+1)
                v.highlight("SurferMatches", patt)


class Formatter:

    def __init__(self, plug):
        self.plug = plug

    def fmt(self, fmtstr, tag, duplicates):
        """Replace the attribute in `fmtdtr` with its value."""
        if u"{name}" in fmtstr:
            return fmtstr.replace(u"{name}", tag["name"])
        if u"{cmd}" in fmtstr:
            return fmtstr.replace(u"{cmd}", tag["cmd"])
        if u"{file}" in fmtstr:
            return fmtstr.replace(u"{file}", self._fmt_file(tag, duplicates))
        if u"{line}" in fmtstr:
            ln = self._get_linenr(tag)
            if ln:
                return fmtstr.replace(u"{line}", ln)
            else:
                return u""
        try:
            return fmtstr.format(**tag["exts"])
        except KeyError:
            return u""

    def _fmt_file(self, tag, duplicates):
        """Format tag file."""
        file = tag["file"]
        root = misc.find_root(v.cwd())

        # The user always wants the tag file displayed relative to the
        # current project root if it exists. Replacing the home with
        # '~' may be needed for files outside the current project that
        # are printed with the absolute path.
        if settings.get("tag_file_relative_to_project_root", bool):
            if root:
                f = file.replace(root, u"").replace(expanduser("~"), u"~")
                return f[1:] if f.startswith(sep) else f

        # If the `g:surfer_tag_file_custom_depth` is set,
        # cut the path according its value
        depth = settings.get("tag_file_custom_depth", int)
        if depth > 0:
            return join(*file.split(sep)[-depth:])

        # If th file name is duplicate in among search results
        # then display also the container directory
        if basename(file) in duplicates and len(file.split(sep)) > 1:
            return join(*file.split(sep)[-2:])

        # By default display only the file name
        return basename(file)

    def _get_linenr(self, tag):
        """Get line number if available."""
        if tag["exts"].get("line") or tag["cmd"].isdigit():
            return tag["exts"].get("line", tag["cmd"])
        else:
            return u""
