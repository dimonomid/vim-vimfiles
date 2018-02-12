# -*- coding: utf-8 -*-
"""
surfer.tag.filters
~~~~~~~~~~~~~~~~~~

This module defines default filter functions.
"""

from os.path import sep
from fnmatch import fnmatch

from surfer.utils import settings


user_functions = {}
EXCLUDE_TAGS = settings.get("exclude_tags")
EXCLUDE_KINDS = settings.get("exclude_kinds")


def basic_filter(tag):
    cond1 = not any(fnmatch(tag["name"], patt) for patt in EXCLUDE_TAGS)
    cond2 = not any(tag["exts"].get("kind") == kind for kind in EXCLUDE_KINDS)
    return cond1 and cond2


def SurferBufferFilter(tags, project_root, curr_buffer, open_buffers):
    fn = lambda tag: tag["file"] == curr_buffer
    return (tag for tag in tags if fn(tag) and basic_filter(tag))


def SurferProjectFilter(tags, project_root, curr_buffer, open_buffers):
    fn = lambda tag: project_root and tag["file"].startswith(project_root + sep)
    return (tag for tag in tags if fn(tag) and basic_filter(tag))


def SurferSessionFilter(tags, project_root, curr_buffer, open_buffers):
    fn = lambda tag: tag["file"] in  open_buffers
    return (tag for tag in tags if fn(tag) and basic_filter(tag))
