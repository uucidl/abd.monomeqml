TEMPLATE = lib

TARGET = build/monome
MOC_DIR = $$PWD/build/moc
OBJECTS_DIR = $$PWD/build/obj

QT += qml
QT -= gui
CONFIG += qt plugin hide_symbols c++11 warn_on
INSTALLS += target qmldir qmlsources

PLUGIN_IMPORT_PATH = com/uucidl/monome

INSTALL_DIR=$$(INSTALL_DIR)
isEmpty(INSTALL_DIR) {
        INSTALL_DIR = $$[QT_INSTALL_QML]
}

target.path = $$INSTALL_DIR/$$PLUGIN_IMPORT_PATH

sourcedir = $$_PRO_FILE_PWD_/src

qmldir.files = $$sourcedir/qmldir
qmldir.path += $$target.path

qmlsources.files = $$sourcedir/*.qml $$sourcedir/*.js
qmlsources.path = $$target.path

SOURCES += $$sourcedir/*.cpp
HEADERS += $$sourcedir/*.hpp

## OSCPKT
INCLUDEPATH += $$_PRO_FILE_PWD_/third-party/oscpkt/
