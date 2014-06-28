Monome support for QML
======================

Status ![Continuous Build Status](https://travis-ci.org/uucidl/pre.monomeqml.svg?branch=master)
------

Work in progress, pre-release

Installation
------------

The following will build & install the plugin in your QT5 qml installation path:

    qmake
    make install

You may override the installation directory like so:

    INSTALL_DIR=<alternative_target> qmake
    make

Contributing
------------

Requirement: qt5
Optional requirements: clang-format

use test.sh to run the unit tests.

use pre-commit.sh to be sure your code is well formatted (uses clang-format)
