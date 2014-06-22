TEMPLATE = lib

TARGET = build/monome
MOC_DIR = $$PWD/build/moc
OBJECTS_DIR = $$PWD/build/obj

QT += qml
QT -= gui
CONFIG += qt plugin hide_symbols c++11 warn_on
INSTALLS += target qmldir qmlsources

PLUGIN_IMPORT_PATH = com/uucidl/monome

target.path = $$[QT_INSTALL_QML]/$$PLUGIN_IMPORT_PATH

qmldir.files = src/qmldir
qmldir.path += $$target.path

qmlsources.files = src/*.qml
qmlsources.path = $$target.path

SOURCES += src/*.cpp
HEADERS += src/*.hpp

## OSCPKT
INCLUDEPATH += $$_PRO_FILE_PWD_/third-party/oscpkt/
