#!/usr/bin/env sh
HERE=$(dirname ${0})

PATH=$(qmake -query QT_INSTALL_BINS):$PATH

(cd "${HERE}/build" && \
 INSTALL_DIR="${HERE}/build/qml" qmake ../monomeqml.pro && \
 make install) && \
 qmltestrunner -import build/qml -input tests
