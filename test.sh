#!/usr/bin/env sh
HERE=$(dirname ${0})

PATH=$(qmake -query QT_INSTALL_BINS):$PATH

INSTALL_DIR="${HERE}/build/qml" qmake && make install && qmltestrunner -import build/qml -input tests
