# -*- coding: utf-8 -*-
"""
surfer.generator
~~~~~~~~~~~~~~~~

This module defines the Generator class. This class is responsible for
generating tags.
"""

import logging
log = logging.getLogger(__name__)

import os
import shlex
import atexit
import Queue
import tempfile
import threading
import subprocess
from itertools import imap
from timeit import default_timer

from surfer.utils import v
from surfer.utils import misc
from surfer.utils import exceptions as ex


class Generator(threading.Thread):

    def __init__(self, errors, ctags_prg, ctags_args):
        super(Generator, self).__init__()
        self.name = __name__
        self.daemon = True
        self.errors = errors
        self.error_state = threading.Event()
        self.lock = threading.Lock()
        self.rebuild = Queue.Queue()  # IN
        self.tagfiles = Queue.Queue()  # OUT
        self.tagfile = self._new_tagfile()
        self.ctags_prg = ctags_prg
        self.ctags_args = ctags_args
        self.ctags_process = None
        atexit.register(self.cleanup)

    def cleanup(self):
        """To perform cleanup actions."""
        if self.ctags_process and self.ctags_process.poll() is None:
            self.ctags_process.terminate()
            log.info("Cleaning up. Ctags process terminated")
        self._delete_tagfile()

    def run(self):
        """To generate tags each time we are told to do so."""
        log.info(u"Generator started. Ctags program: {0}".format(self.ctags_prg))
        while not self.error_state.is_set():
            try:
                project_root, buffers = self.rebuild.get()
                self._generate_tags(project_root, buffers)
                self.tagfiles.put_nowait(self.tagfile)
            except ex.SurferCtagsError as e:
                log.error(e.message)
                self.error_state.set()
                self.errors.put(e.message)
        log.info("Generator terminated")

    def _new_tagfile(self):
        """To generate a new temporary file name."""
        with tempfile.NamedTemporaryFile(delete=False) as tf:
            return tf.name

    def _delete_tagfile(self):
        """To delete the tagfile."""
        with self.lock:
            try:
                log.info(u"Cleaning up. Tagfile deleted: {0}".format(self.tagfile))
                os.remove(self.tagfile)
                self.tagfile = ""
            except OSError as e:
                pass

    def _generate_tags(self, project_root, buffers):
        """To generate tags with the help of the integrated generator."""
        if project_root:
            log.info(u"Generating tags for project: {0}".format(project_root))
            args = self.ctags_args + u" -R {0}".format(project_root)
        elif buffers:
            log.info(u"Generating tags for open buffers: {0}".format(buffers))
            files = imap(lambda f: u'"{0}"'.format(f), buffers)
            args = self.ctags_args + u" {0}".format(u" ".join(files))
        else:
            return
        start = default_timer()
        self._generate(self.ctags_prg, args)
        log.info(u"Tags generation completed ({0:.3f}s). Tagfile written: {1}".format(
            default_timer() - start, self.tagfile))

    def _generate(self, prg, args):
        """To generate tags."""
        cmd = u"{0} -f {1} {2}".format(prg, self.tagfile, args)
        cmd = cmd if os.name != 'nt' else cmd.replace(u"\\", u"\\\\")
        err = self._run_ctags(cmd.encode("utf8"))
        if err:
            raise ex.SurferCtagsError("'{0}' failed to generate tags. {1}".format(prg, err))

    def _run_ctags(self, cmd):
        """To execute Ctags."""
        self.ctags_process = subprocess.Popen(shlex.split(cmd),
            universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            startupinfo=self._startupinfo(), close_fds=True)
        _, err = self.ctags_process.communicate()
        err = "" if "Warning" in err else err  # ignore warnings
        return err

    def _startupinfo(self):
        """OS dependent `startupinfo`."""
        startupinfo = None
        if os.name == 'nt':
            # On Ms Windows hide the console window when launching a subprocess
            startupinfo = subprocess.STARTUPINFO()
            startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        return startupinfo
