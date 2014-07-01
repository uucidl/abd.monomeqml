Monome support for QML
======================

This QML/Qt plugin targets Monome devices to enable common interaction
patterns with these physical devices.

To know more and purchase monome devices look on the
[official website](http://monome.org/)

Note: this is not an official plugin. Contact the manufacturer for
device questions.

Status ![Continuous Build Status](https://travis-ci.org/uucidl/pre.monomeqml.svg?branch=master)
------

Work in progress, pre-release

Licensing
---------

MIT. Look for the [LICENSE](./LICENSE) file.

Installation
------------

The following will build & install the plugin in your QT5 qml installation path:

    qmake
    make install

You may override the installation directory like so:

    INSTALL_DIR=<alternative_target> qmake
    make

Using
-----

Look for the examples under [examples](./examples/) directory.

For instance to run the direct value manipulation example:

    ./test.sh
    qmlscene -I build/qml examples/direct-value/Main.qml

Calling test.sh ensures the plugin has been built and installed to
build/qml

Contributing
------------

Requirement: qt5
Optional requirements: clang-format

use [test.sh](./test.sh) to run the unit tests.

use [pre-commit.sh](./pre-commit.sh) to ensure the code is well formatted (uses clang-format)
