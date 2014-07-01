#!/usr/bin/env sh
HERE=$(dirname ${0})

PATH=$(qmake -query QT_INSTALL_BINS):$PATH
BUILD="${HERE}/build"

[ -d "${BUILD}" ] || mkdir -p "${BUILD}"

(cd "${BUILD}" && \
 INSTALL_DIR="${BUILD}/qml" qmake ../monomeqml.pro && \
 make install) && \
 qmltestrunner -import "${BUILD}"/qml -input tests
