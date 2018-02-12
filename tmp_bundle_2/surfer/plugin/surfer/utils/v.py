# -*- coding: utf-8 -*-
"""
surfer.utils.v
~~~~~~~~~~~~~~

This module defines thin wrappers around vim commands and functions.
"""

import logging
log = logging.getLogger(__name__)

import os
import vim
from itertools import imap
from unicodedata import normalize
from os.path import join, dirname, sep


ENCODING = vim.eval("&encoding")


def _vim_command(cmd):
    """Little wrapper around `vim.eval()`"""
    try:
        vim.command(cmd)
    except:
        log.exception("Unexpected error executing command '{0}'".format(cmd))
        raise


def _vim_eval(expr):
    """Little wrapper around `vim.comamnd()`"""
    try:
        return vim.eval(expr)
    except:
        log.exception("Unexpected error evaluating expression '{0}'".format(expr))
        raise


def eval(expr, fmt=None):
    """To evaluate the given expression."""
    val = unicode(_vim_eval(encode(expr)))
    if fmt is bool:
        return False if val == u'0' else True
    elif fmt is int:
        return int(val)
    else:
        return val


def opt(opt, fmt=None):
    """To return the value of a vim option."""
    return eval("&{0}".format(opt), fmt=fmt)


def exe(cmd):
    """To execute a vim command."""
    _vim_command(encode(cmd))


def echo(msg, hlgroup=""):
    """To display a message to the user via the command line."""
    if hlgroup:
        exe(u"echohl {0}".format(hlgroup))
    exe(u'echom "[surfer] {0}"'.format(msg).replace('"', '\"'))
    exe("echohl None")


def unicode(obj):
    """To recursively decode the given object."""
    if isinstance(obj, basestring):
        return normalize("NFC", obj.decode(ENCODING))
    if isinstance(obj, list):
        return [unicode(val) for val in obj]
    if isinstance(obj, dict):
        return dict((unicode(k), unicode(val)) for k, val in obj.items())
    return obj


def encode(obj):
    """To recursively encode the given object."""
    if isinstance(obj, basestring):
        return obj.encode(ENCODING)
    if isinstance(obj, list):
        return [encode(val) for val in obj]
    if isinstance(obj, dict):
        return dict((encode(k), encode(val)) for k, val in obj.items())
    return obj


def cwd():
    """To return the directory of the current buffer."""
    return dirname(bufname())


def highlight(hlgroup, patt):
    """To highlight with `hlgroup` every occurrence of `patt`."""
    exe(u"syn match {0} /{1}/".format(hlgroup, patt))


def redraw():
    """Little wrapper around the redraw command. See :h :redraw"""
    exe('redraw')


def focus_win(expr):
    """To go to the window numbered `expr`. See :wincmd"""
    if expr in ("#", "$"):
        expr = eval(u"winnr('{0}')".format(expr))
    exe(u'{0}wincmd w'.format(expr))


def cursor(target=None):
    """To move the cursor or return the current cursor position."""
    if not target:
        return vim.current.window.cursor
    vim.current.window.cursor = target


def bufwinnr(expr):
    """To return the number of the window for the buffer `expr`, where `expr`
    can be a number or a string. See :h bufwinnr()"""
    if isinstance(expr, (int, long)):
        return eval("bufwinnr({0})".format(expr), fmt=int)
    return eval(u"bufwinnr('{0}')".format(expr), fmt=int)


def buffer(nr=None):
    """To return the the buffer numbered `nr`. If no number is given,
    the the current buffer is returned."""
    if nr is None:
        return vim.current.buffer
    return vim.buffers[nr]


def bufname(nr=None):
    """To return the name of the buffer numbered `nr`. If no number is given,
    the name of the current buffer is returned."""
    if nr is None:
        return unicode(vim.current.buffer.name)
    return unicode(vim.buffers[nr].name)


def bufnr(expr=None):
    """To return the number of the buffer `expr`."""
    if expr is None:
        expr = "%"
    return eval(u"bufnr('{0}')".format(expr), fmt=int)


def winnr(expr=None):
    """To return the number of current window or the number of the window
    `expr`, where `expr` can be # or %. See :h winnr()"""
    if expr is None:
        return eval("winnr()", fmt=int)
    return eval(u"winnr('{0}')".format(expr), fmt=int)


def setbuffer(content):
    """To set the whole content of the current buffer at once."""
    if isinstance(content, list):
        vim.current.buffer[:] = [encode(ln) for ln in content]
    elif isinstance(content, basestring):
        vim.current.buffer[:] = encode(content).split("\n")


def getline(linenr):
    """To set a specific line of the current buffer."""
    return unicode(vim.current.buffer[linenr])


def setline(linenr, line):
    """To set a specific line of the current buffer."""
    vim.current.buffer[linenr] = encode(line)


def setwinh(height, nr=None):
    """To set the height of the window numbered `nr`. If no number is given,
    the height of the current window is set."""
    if nr is None:
        vim.current.window.height = height
    else:
        vim.windows[nr].height = height


def tagfiles():
    """To get all tagfiles in use."""
    return eval(u"tagfiles()")


def set_tagfiles(*tagfiles):
    """To set the &tags vim option."""
    exe(u"set tags={0}".format(u",".join(tagfiles)))


def buflisted(expr):
    """To check if a buffer is listed. See :h buflisted()"""
    if isinstance(expr, basestring):
        return eval(u"buflisted('{0}')".format(expr), fmt=bool)
    return eval(u"buflisted({0})".format(expr), fmt=bool)


def buffers():
    """To return a list of all listed buffers."""
    buffers = filter(None, imap(lambda b: b.name, vim.buffers))
    return filter(lambda b: buflisted(b), unicode(buffers))
