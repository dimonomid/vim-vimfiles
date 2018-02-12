# -*- coding: utf-8 -*-
"""
surfer.utils.settings
~~~~~~~~~~~~~~~~~~~~~

This module defines various utility functions for dealing with vim variables.
"""

from surfer.utils import v


prefix = 'g:surfer_'


def get(name, fmt=None):
    """To get the value of a vim variable."""
    if not v.eval(u"exists('{0}')".format(prefix + name), fmt=int):
        raise ValueError("The option '{0}' does not exists.".format(prefix + name))
    rawval = v.eval(prefix + name)
    if fmt is bool:
        return False if rawval == u'0' else True
    elif fmt is int:
        return int(rawval)
    else:
        return rawval


def getd(opt, key, fmt=None, default=None):
    """To get the value of `key` in a dictionary option."""
    d = get(opt)
    if not isinstance(d, dict):
        raise ValueError("Expected <type 'dict'>, got <type '{0}'>".format(type(d)))
    rawval = d.get(key, default)
    if fmt is bool:
        return False if rawval == u'0' else True
    elif fmt is int:
        return int(rawval)
    return rawval
