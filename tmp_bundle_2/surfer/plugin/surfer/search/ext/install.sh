#!/usr/bin/env bash

set -e

cd $(dirname $0)
rm -fR build search.so
python setup.py build_ext --inplace
rm -fR build
