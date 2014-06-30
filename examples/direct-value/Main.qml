import com.uucidl.monome 1.0

import ".."

import QtQuick 2.2
import QtQuick.Controls 1.1

Root {
    QtObject {
        id: model

        property real value: min
        property real min: 0.0
        property real max: 1.0

        function setValue(newValue) {
            value = Math.min(Math.max(newValue, min), max);
        }
    }

    Column {
        spacing: vspace

        Text {
            text: "value: " + Math.round(10000 * model.value) / 100.0
            font: defaultFont
        }

        Slider {
            value: model.value
            onValueChanged: model.setValue(value)
            minimumValue: model.min
            maximumValue: model.max
            tickmarksEnabled: true
        }

        Text {
            text: {
                if (arc.connected) {
                    return "arc found";
                }

                return "arc not found";
            }

            SerialOSC {
                id: serialOSC
            }

            property Arc arc: Arc {
                prefix: "/arc"
                deviceNameToMatch: "monome arc 4"
                serialOSC: serialOSC

                property real baseValuePerArcDelta: 1.0 / 64.0 / 4.0
                property real fineScale: 1 / 4.0
                property real valuePerArcDelta: {
                    return (fineDelta ? fineScale : 1.0) * baseValuePerArcDelta;
                }
                property bool fineDelta: false

                onPressed: {
                    if (encoder === 0) {
                        fineDelta = true;
                    }
                }

                onReleased: {
                    if (encoder === 0) {
                        fineDelta = false;
                    }
                }

                onDelta: {
                    if (encoder === 0) {
                        model.setValue(model.value + delta * valuePerArcDelta);
                    }
                }

                property var dataset: {
                    "value": model.value
                }
                onDatasetChanged: requestPaint()

                onPaint: {
                    var context = getPaintContext();
                    context.drawRing(0, 0);
                    context.drawTick(0, 64.0 * (model.value - model.min) / (model.max - model.min), 15);
                }
            }
        }
    }
}