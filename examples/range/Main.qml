import com.uucidl.monome 1.0

import ".."

import QtQuick 2.2
import QtQuick.Controls 1.1

Root {
    QtObject {
        id: model

        property real min: -1.0
        property real max: 1.0
        property real minimumRangeSize: 0.01

        property var range: makeRange(min, max - min)
        property var extent: makeRange(min, max - min)

        readonly property real start: range.start
        readonly property real end: range.end
        readonly property real size: range.size

        function tryMoveStartTo(target) {
            if (start === target) {
                return;
            }

            var upperBound = range.end - minimumRangeSize,
                lowerBound = Math.min(range.start, min),
                newStart = Math.max(Math.min(target, upperBound), lowerBound),
                newSize = range.size - (newStart - range.start);

            range = makeRange(newStart, newSize);
        }

        function tryMoveEndTo(target) {
            if (end === target) {
                return;
            }

            var upperBound = Math.max(range.end, max),
                lowerBound = range.start + minimumRangeSize,
                newEnd = Math.max(Math.min(target, upperBound), lowerBound),
                newSize = newEnd - range.start;

            range = makeRange(range.start, newSize);
        }

        function tryTranslateTo(target) {
            if (start === target) {
                return;
            }

            var upperBound = Math.max(range.end, max) - range.size,
                lowerBound = Math.min(range.start, min),
                newStart = Math.max(Math.min(target, upperBound), lowerBound);

            range = makeRange(newStart, range.size);
        }

        function makeRange(start, size) {
            return {
                start: start,
                size: size,
                end: start + size
            };
        }
    }

    Component.onCompleted: {
        var halfRange = (model.max - model.min) / 2.0,
            center = (model.max + model.min) / 2.0;
        model.tryMoveEndTo(center + halfRange / 2.0);
        model.tryMoveStartTo(center - halfRange / 2.0);
    }

    Column {
        spacing: vspace

        Text {
            font: defaultFont
            text: "range: " + range(model.range) + "/" + range(model.extent)
            function range(r) {
                return "[" + r.start + ", " + r.end + "]";
            }
        }

        Flow {
            spacing: hspace

            Text {
                font: defaultFont
                text: "start/end"
            }

            Slider {
                value: model.start
                onValueChanged: {
                    model.tryMoveStartTo(value);
                }
                minimumValue: model.min
                maximumValue: model.max
            }

            Slider {
                value: model.end
                onValueChanged: {
                    model.tryMoveEndTo(value);
                }
                minimumValue: model.min
                maximumValue: model.max
            }
        }

        Flow {
            spacing: hspace
            Text {
                font: defaultFont
                text: "editing mode"
            }

            Button {
                text: arc.aspectToEdit
                onClicked: {
                    arc.cycleAspectToEdit();
                }
            }
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
                id: arc
                prefix: "/arc"
                deviceNameToMatch: "monome arc 4"
                serialOSC: serialOSC

                property string aspectToEdit: "translate"
                function cycleAspectToEdit() {
                    var table = {
                        translate: "start",
                        start: "end",
                        end: "translate",
                    };

                    aspectToEdit = table[aspectToEdit];
                }

                property var gesture: LinearRelativeGesture {
                    property var adjusters: {
                        "translate": function (modelDelta) {
                            model.tryTranslateTo(model.start + modelDelta);
                        },
                        "start": function (modelDelta) {
                            model.tryMoveStartTo(model.start + modelDelta);
                        },
                        "end": function (modelDelta) {
                            model.tryMoveEndTo(model.end + modelDelta);
                        }
                    }
                    modelAdjustBy: adjusters[arc.aspectToEdit]
                }

                property real msForCycle: 250.0
                property real pressOriginMs

                onPressed: {
                    if (encoder === 0) {
                        pressOriginMs = Date.now();
                        gesture.fineDelta = true;
                    }
                }

                onReleased: {
                    var durationMs = Date.now() - pressOriginMs;

                    if (encoder === 0 && durationMs <= msForCycle) {
                        cycleAspectToEdit();
                    }

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
                    "range": model.range,
                    "aspectToEdit": aspectToEdit,
                }
                onDatasetChanged: requestPaint()

                onPaint: {
                    var context = getPaintContext(),
                        valueToRingValue = function (value) {
                            return Math.min(63, Math.max(0, (64.0 * (value - model.min) / (model.max - model.min))));
                        },
                        startTick = valueToRingValue(model.start)|0,
                        endTick = valueToRingValue(model.end)|0;

                    context.drawRing(0, 0);

                    var rangeLevel = 15;

                    if (aspectToEdit !== "none") {
                        rangeLevel = 6;
                    }

                    context.drawRingRange(0, startTick, endTick, rangeLevel);
                    if (aspectToEdit === "start") {
                        context.drawTick(0, startTick, 15);
                    } else if (aspectToEdit === "end") {
                        context.drawTick(0, endTick, 15);
                    }

                }
            }
        }
    }
}