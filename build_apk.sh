#!/usr/bin/env bash
set -e
python -m pip install --upgrade pip setuptools wheel cython buildozer
buildozer android clean
buildozer -v android debug
