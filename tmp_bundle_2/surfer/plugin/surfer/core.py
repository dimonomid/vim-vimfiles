# -*- coding: utf-8 -*-
"""
surfer.core
~~~~~~~~~~~

This module defines the Surfer class.
"""

import logging
log = logging.getLogger(__name__)

import os
import Queue
import threading
from functools import partial
from operator import itemgetter
from timeit import default_timer
from collections import namedtuple
from itertools import ifilter, imap

from surfer import ui
from surfer import loader
from surfer import generator
from surfer.utils import v
from surfer.utils import misc
from surfer.utils import settings
from surfer.utils import exceptions as ex

try:
    from surfer.search.ext.search import match
    SEARCH_EXTENSION_LOADED = True
except ImportError:
    from surfer.search.search import match
    SEARCH_EXTENSION_LOADED = False


class Surfer:

    def __init__(self):
        self.ui = ui.UserInterface(self)
        self.errors = Queue.Queue()
        self.loader = self._start_loader(self.errors)
        self.generator = self._start_generator(self.errors)
        self.last_error = ""
        self.use_cache = False

    def close(self):
        """To performs cleanup actions."""
        log.info("Quitting Surfer")

    def open(self):
        """To open the Surfer user interface."""
        if self.last_error:
            v.echo(self.last_error, "WarningMsg")
            return
        try:
            self.last_error = self.errors.get_nowait()
            log.error(self.last_error)
            v.echo(self.last_error, "WarningMsg")
        except Queue.Empty:
            self.ui.open()

    def _start_generator(self, errors):
        """To start the Generator thread."""
        if not settings.get("generate_tags"):
            return
        ctags_prg = settings.get("ctags_prg")
        ctags_args = settings.get("ctags_args")
        generator_thread = generator.Generator(errors, ctags_prg, ctags_args)
        generator_thread.start()
        return generator_thread

    def _start_loader(self, errors):
        """To start the Loader thread."""
        loader_thread = loader.Loader(errors)
        loader_thread.start()
        return loader_thread

    def find_tags(self, query, max_results=-1, curr_buffer=""):
        """To find all matching tags for the given query."""
        modifier, query = self._split_query(query.strip())
        if query:
            start = default_timer()
            smart_case = settings.get("smart_case", int)
            matches = self._find(query, modifier, smart_case, curr_buffer)
            log.info(u"Searching tags for query '{0}'. {1} tags found ({2:.3f}s)".format(
                (modifier + query).strip(), len(matches), default_timer() - start))
            if max_results < 0 or max_results > len(matches):
                max_results = len(matches)
            return sorted(matches, key=itemgetter("similarity"))[:max_results]
        return []

    def _split_query(self, query):
        """To slit the query into the modifier and the effective query."""
        if query and query[0] in settings.get("filters"):
            return query[0], query[1:]
        return u" ", query

    def _find(self, query, modifier, smart_case, curr_buffer):
        """To search tags."""
        Match = namedtuple("Match", "tag similarity positions")
        project_root = misc.find_root(v.cwd())
        tags = self.loader.get_tags(self.use_cache, modifier, project_root, v.buffers(), curr_buffer)
        matches = (Match(tag, *match(query, tag["name"], smart_case)) for tag in tags)
        return [self._pack(m) for m in matches if m.positions]

    def _pack(self, match):
        return {
            "positions": match.positions, "similarity": match.similarity,
            "name": match.tag["name"], "file": match.tag["file"],
            "exts": match.tag["exts"], "cmd": match.tag["cmd"],
        }
