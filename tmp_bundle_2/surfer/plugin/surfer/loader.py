# -*- coding: utf-8 -*-
"""
surfer.loader
~~~~~~~~~~~~~

This module defines the Loader class.
"""

import logging
log = logging.getLogger(__name__)

import Queue
import threading
from timeit import default_timer
from itertools import chain, imap

from surfer import watcher
from surfer.utils import v
from surfer.utils import misc
from surfer.utils import filters
from surfer.utils import settings
from surfer.utils import exceptions as ex
from surfer.utils.tags import parse_tag_line


class Loader(threading.Thread):

    def __init__(self, errors):
        super(Loader, self).__init__()
        self.name = __name__
        self.daemon = True
        self.errors = errors
        self.error_state = threading.Event()
        self.lock = threading.Lock()
        self.watcher = watcher.TagfilesWatcher()
        self.channel = Queue.Queue()
        self.watcher.register(self.channel)
        self.filters = self._get_filters()
        self.tags = {}  # {tagfile1 : [tags..], tagfile2: [tags..]}
        self.filtered = {} # {modifier1: [tags..], modifier2: [tags..]}

    def _get_filters(self):
        """To setup filter functions."""
        _filters = {}
        for modifier, fn in settings.get("filters").items():
            try:
                if not fn:
                    _filters[modifier] = lambda *args: True
                else:
                    func = getattr(filters, fn, None)
                    func = func if func else filters.user_functions[fn]
                    _filters[modifier] = func
            except KeyError as e:
                self.error_state.set()
                self.errors.put_nowait("Filter function '{0}' does not exists.".format(fn))
        return _filters

    def start(self):
        super(Loader, self).start()
        self.watcher.start()

    def run(self):
        """To load all tags into memory."""
        log.info("Loader started. Loading tagfiles as soon as they change")
        while not self.error_state.is_set():
            try:
                event = self.channel.get()
                if event.update or event.add:
                    self._load_tags(event.tagfile)
                else:
                    self._unload_tags(event.tagfile)
            except ex.SurferFilterError as e:
                self.error_state.set()
                self.errors.put_nowait(e.message)
            except Queue.Empty:
                pass
        log.info("Loader terminated")

    def get_tags(self, use_cache, modifier, project_root, open_buffers, curr_buffer):
        """To return all loaded tags."""
        with self.lock:
            if not self.filtered or not use_cache:
                self._filter_tags(project_root, open_buffers, curr_buffer)
            return self.filtered[modifier]

    def filter_tags(self, project_root, open_buffers, curr_buffer):
        with self.lock:
            self._filter_tags(project_root, open_buffers, curr_buffer)

    def _filter_tags(self, project_root, open_buffers, curr_buffer):
        log.info(u"Filtering tags: project root <{0}> current buffer <{1}> open buffers <{2}>".format(
            project_root, curr_buffer, open_buffers))
        self.filtered = {}
        tags = list(chain(*self.tags.values()))
        try:
            for modifier, func in self.filters.items():
                self.filtered[modifier] = list(func(tags, project_root, curr_buffer, open_buffers))
        except Exception as e:
            log.exception("Error occurred in custom filter function.")
            raise ex.SurferFilterError("Error occurred in custom filter function. {0}".format(e.message))

    def _load_tags(self, tagfile):
        start = default_timer()
        with self.lock:
            self.tags[tagfile] = list(self._load_tagfile(tagfile))
        log.info(u"Tagfile loaded ({0:.3f}s). {1}".format(default_timer() - start, tagfile))

    def _unload_tags(self, tagfile):
        with self.lock:
            del self.tags[tagfile]
        log.info(u"Tagfile unloaded: {0}".format(tagfile))

    def _load_tagfile(self, tagfile):
        """To load into memory the content of a single tagfile."""
        try:
            with open(tagfile, "r") as f:
                for line in f:
                    tag = parse_tag_line(line, tagfile)
                    if tag:
                        yield tag
        except IOError:
            log.error("Cannot open tagfile: {0}".format(tagfile))
