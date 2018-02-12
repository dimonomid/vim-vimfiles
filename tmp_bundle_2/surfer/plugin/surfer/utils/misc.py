# -*- coding: utf-8 -*-
"""
surfer.utils.misc
~~~~~~~~~~~~~~~~~

This module defines various utilities.
"""

from os import listdir
from timeit import default_timer
from itertools import groupby, imap
from os.path import dirname, basename

from surfer.utils import v
from surfer.utils import settings



_project_root_cache = ""
_project_root_markers = settings.get("root_markers")


def find_root(path):
    """To find the the root of the current project.

    `markers` is a list of file/directory names the can be found
    in a project root directory.
    """
    global _project_root_cache
    if _project_root_cache and path.startswith(_project_root_cache):
        return _project_root_cache
    if not path or path == u"/" or path.endswith(u":\\"):
        return u""
    elif any(m in listdir(path) for m in _project_root_markers):
        _project_root_cache = path
        return path
    else:
        return find_root(dirname(path))


def duplicates(lst):
    """To return all duplicates in `lst`."""
    return [k for k, g in groupby(sorted(lst)) if len(list(g)) > 1]


def as_byte_indexes(indexes, s):
    """To transform character indexes into byte indexes."""
    idx = 0
    byte_indexes = []
    for i, c in enumerate(s):
        if i in indexes:
            byte_indexes.append(idx)
        idx += len(v.encode(c))
    return byte_indexes
