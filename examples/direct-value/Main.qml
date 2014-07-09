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
            if (newValue === value) {
                return;
            }

            value = Math.min(Math.max(newValue, min), max);
        }
    }

    function valueToString(value) {
        return Math.round(10000 * value) / 100.0;
    }

    Column {
        spacing: vspace

        Text {
            text: "value: " + valueToString(model.value)
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
        Rectangle {
            id: trial
            height: 200
            width: 200
            color: modelReachedValue ? "white" : "darkgrey"
            property string instruction: ""
            state: "Waiting"

            property real value: -1.0
            property real valueSetTS
            onValueChanged: {
                valueSetTS = Date.now();
            }
            property real successMinMs: Number.POSITIVE_INFINITY
            property real successMaxMs: Number.NEGATIVE_INFINITY
            property real totalSuccessMs: 0.0
            property int successes: 0
            property bool modelReachedValue: valueToString(model.value) == valueToString(trial.value)
            property real valueReachedTS
            onModelReachedValueChanged: {
                if (modelReachedValue) {
                    valueReachedTS = Date.now();
                    trial.waitForValue = true;
                }
            }
            property bool waitForValue: false

            function recordSuccess() {
                trial.successes++;
                var thisTime = trial.valueReachedTS - trial.valueSetTS;
                trial.successMinMs = Math.min(trial.successMinMs, thisTime);
                trial.successMaxMs = Math.max(trial.successMaxMs, thisTime);
                trial.totalSuccessMs += thisTime;
            }

            property var timer: Timer {
                running: trial.waitForValue
                interval: 15
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    if (!trial.modelReachedValue) {
                        trial.waitForValue = false;
                        return;
                    }

                    if (Date.now() - trial.valueReachedTS > 2000.0) {
                        trial.recordSuccess();
                        trial.waitForValue = false;
                        trial.state = "Waiting";
                    }
                }
            }

            states: [
                State {
                    name: "Waiting"
                    PropertyChanges { target: trial; instruction: "click to start trial" }
                    PropertyChanges {
                        target: trialMA
                        onClicked: {
                            trial.state = "Running"
                        }
                    }
                },
                State {
                    name: "Running"
                    PropertyChanges {
                        target: trial
                        value: Math.random()
                    }
                    PropertyChanges {
                        target: trial
                        instruction: "Pick value: " + valueToString(trial.value)
                    }
                }
            ]

            Text {
                anchors.fill: parent
                text: trial.instruction
                font: defaultFont
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                width: parent.width
                anchors.bottom: parent.bottom
                text: {
                    return "Result: " + trial.successes + " min/max/avg timeToSuccess: " + trial.successMinMs + ", " +
                    trial.successMaxMs + ", " + (trial.totalSuccessMs / trial.successes);
                }
                font: defaultFont
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.Bottom
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: trialMA
                anchors.fill: parent
            }
        }
    }
}