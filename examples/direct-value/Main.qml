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

        Column {
            spacing: vspace

            Text {
                text: {
                    if (arc.connected) {
                        return "arc found";
                    }

                    return "arc not found";
                }
            }

            Button {
                text: "drawStyle: " + arc.style
                onClicked: {
                    arc.style = arc.style === "simple" ? "subdivisions" : "simple";
                }
            }

            Button {
                text: "gestureType: " + arc.gestureType
                onClicked: {
                    arc.cycleGestureType();
                }
            }

            SerialOSC {
                id: serialOSC
            }

            property Arc arc: Arc {
                id: arc
                prefix: "/arc"
                deviceNameToMatch: "monome arc 4"
                serialOSC: serialOSC

                property var modelAdjustBy: function(deltaInModelUnits) {
                    model.setValue(model.value + deltaInModelUnits);
                }

                property var linearGesture: LinearRelativeGesture {
                    modelAdjustBy: arc.modelAdjustBy
                }

                property var acceleratedGesture: AcceleratedRelativeGesture {
                    modelAdjustBy: arc.modelAdjustBy
                }

                property string gestureType: "accelerated"
                property var gestures: {
                    "linear": linearGesture,
                    "accelerated": acceleratedGesture,
                }
                property var gesture: gestures[gestureType]

                function cycleGestureType() {
                    var nextType = {
                        "accelerated": "linear",
                        "linear": "accelerated",
                    };

                    gestureType = nextType[gestureType];
                }

                property string style: "simple"

                onPressed: {
                    if (encoder === 0) {
                        gesture.fineDelta = true;
                    }
                }

                onReleased: {
                    if (encoder === 0) {
                        gesture.fineDelta = false;
                    }
                }

                onDelta: {
                    if (encoder === 0) {
                        gesture.adjustBy(delta);
                    }
                }

                property var dataset: {
                    "value": model.value,
                    "style": style
                }
                onDatasetChanged: requestPaint()

                onPaint: {
                    if (style === "simple") {
                        drawValue();
                    } else {
                        drawValueWithSubdivisions();
                    }
                }

                function drawValue() {
                    var context = getPaintContext(),
                    valueToArc = function (value) {
                            return 64.0 * (value - model.min) / (model.max - model.min);
                        },
                        unit = valueToArc(model.value);

                    context.drawRing(0, 0);
                    context.drawFractionalTick(0, unit, 15);
                }

                function drawValueWithSubdivisions() {
                    var context = getPaintContext(),
                        valueToArc = function (value) {
                            return 64.0 * (value - model.min) / (model.max - model.min);
                        },
                        unit = valueToArc(model.value);

                    context.drawRing(0, 0);
                    var subdivision = (unit + 64.0 * (unit - Math.floor(unit))) % 64;

                    context.drawFractionalTick(0, subdivision, 4);
                    context.drawFractionalTick(0, unit, 15);
                }
            }
        }
    }
}