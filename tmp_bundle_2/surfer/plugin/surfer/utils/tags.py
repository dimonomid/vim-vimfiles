# -*- coding: utf-8 -*-
"""
surfer.utils.tags
~~~~~~~~~~~~~~~~~

This module defines various utilities.
"""

from unicodedata import normalize
from os.path import join, dirname, sep


def parse_tags(tags, tagfile=""):
    """To parse output of ctags."""
    for line in tags if isinstance(tags, list) else tags.split("\n"):
        tag = parse_tag_line(line, tagfile)
        if tag:
            yield tag


def parse_tag_line(line, tagfile=""):
    """To parse a single line coming from a tagfile.

    Valid tag line format:

        tagName<TAB>tagFile<TAB>exCmd;"<TAB>extensions

    Where `extensions` is a list of <TAB>-separated fields that can be:

        1) a single letter
        2) a string `attribute:value`

    If the fields is a single letter, then the fields is interpreted as
    the kind attribute.
    """
    if line.startswith("!_"):
        return
    try:
        fields, rawexts = line.strip(" \n").split(';"', 1)
        name, file, cmd = (f.decode("utf-8") for f in fields.split("\t"))
        if tagfile and not file.startswith(sep):
            file = join(dirname(tagfile), file)
        exts = {}
        for ext in rawexts.strip("\t").split("\t"):
            if (len(ext) == 1 and ext.isalpha()) or ":" not in ext:
                exts["kind"] = ext.decode("utf-8")
            else:
                t, val = ext.split(":", 1)
                exts[t] = val.decode("utf-8")
        if not exts.get("line") and cmd.isdigit():
            exts["line"] = cmd
        return {'name': name, 'file': normalize("NFC", file), 'cmd': cmd, 'exts': exts}
    except ValueError:
        return
