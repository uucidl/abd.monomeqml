import QtQuick 2.2

/**
    a container for our examples

    sets up defaults for an uniform attractive look.
 */
Rectangle {
    width: 800
    height: 600
    color: "#CFC4BC"

    property font defaultFont
    defaultFont.family: "Helvetica Neue"
    defaultFont.pixelSize: 14

    property real vspace: defaultFont.pixelSize / 2.0
    property real hspace: defaultFont.pixelSize / 3.0
}