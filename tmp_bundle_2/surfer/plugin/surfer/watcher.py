# -*- coding: utf-8 -*-
"""
surfer.watcher
~~~~~~~~~~~~~~

This module defines the TagfilesWatcher class.
"""

import logging
log = logging.getLogger(__name__)

import Queue
import threading
from os.path import getmtime
from itertools import ifilter
from collections import namedtuple

from surfer.utils import v


TagfileChange = namedtuple("TagfileChange", "tagfile update add delete")
DELETE = (False, False, True)
UPDATE = (True, False, False)
ADD    = (False, True, False)


class TagfilesWatcher(threading.Thread):

    def __init__(self):
        super(TagfilesWatcher, self).__init__()
        self.name = __name__
        self.daemon = True
        self.lock = threading.Lock()
        self.tagfiles = Queue.Queue() # IN
        self.known_tagfiles = {}
        self.channels = []  # OUT

    def register(self, channel):
        """To register a channel interested in our notifications."""
        if not isinstance(channel, Queue.Queue):
            raise ValueError("Expected <type 'Queue.Queue'> for <type '{0}'>".format(channel))
        with self.lock:
            self.channels.append(channel)
            return len(self.channels) - 1

    def revoke(self, id):
        """To revoke a channel registration."""
        if not isinstance(id, int):
            raise ValueError("Expected <type 'int'> got <type '{0}'>".format(id))
        if id > len(self.channels) - 1 or id < 0 or self.cahnnels[id] is None:
            raise ValueError("No channel found with id '{0}'".format(id))
        with self.lock:
            self.channels[id] = None

    def run(self):
        """To routinely check if tagfiles used by vim have changed."""
        log.info("TagfilesWatcher started. Watching &tags for changes.")
        while True:
            tagfiles = self.tagfiles.get()
            for tagfile in tagfiles:
                if tagfile not in self.known_tagfiles:
                    self._handle_tagfile_add(tagfile)
                elif self._tagfile_has_changed(tagfile):
                    self._handle_tagfile_update(tagfile)
            for tagfile in set(self.known_tagfiles) - set(tagfiles):
                self._handle_tagfile_deletion(tagfile)
        log.info("TagfilesWatcher terminated")

    def _handle_tagfile_deletion(self, tagfile):
        log.info(u"Tagfile deleted: {0}".format(tagfile))
        del self.known_tagfiles[tagfile]
        self._broadcast(tagfile, DELETE)

    def _handle_tagfile_add(self, tagfile):
        log.info(u"Tagfile added: {0}".format(tagfile))
        self.known_tagfiles[tagfile] = getmtime(tagfile)
        self._broadcast(tagfile, ADD)

    def _handle_tagfile_update(self, tagfile):
        log.info(u"Tagfile updated: {0}".format(tagfile))
        self.known_tagfiles[tagfile] = getmtime(tagfile)
        self._broadcast(tagfile, UPDATE)

    def _tagfile_has_changed(self, tagfile):
        """To check if the tagfile has changed from the last check. Returns True
        even if the tagfile is not tracked yet."""
        if tagfile not in self.known_tagfiles:
            raise ValueError("Tagfile not tracked. Cannot determine if it has changed.")
        return getmtime(tagfile) > self.known_tagfiles[tagfile]

    def _broadcast(self, tagfile, notification):
        """To broadcast a tagfile change to all registered channels."""
        with self.lock:
            for channel in ifilter(None, self.channels):
                try:
                    channel.put_nowait(TagfileChange(tagfile, *notification))
                except Queue.Full:
                    pass
