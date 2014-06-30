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

        readonly property real start: range.start
        readonly property real end: range.end
        readonly property real size: range.size

        property var range: makeRange(min, max - min)
        property var extent: makeRange(min, max - min)

        function tryMoveStartTo(target) {
            var upperBound = range.end - minimumRangeSize,
                lowerBound = Math.min(range.start, min),
                newStart = Math.max(Math.min(target, upperBound), lowerBound),
                newSize = range.size - (newStart - range.start);

            range = makeRange(newStart, newSize);
        }

        function tryMoveEndTo(target) {
            var upperBound = Math.max(range.end, max),
                lowerBound = range.start + minimumRangeSize,
                newEnd = Math.max(Math.min(target, upperBound), lowerBound),
                newSize = newEnd - range.start;

            range = makeRange(range.start, newSize);
        }

        function makeRange(start, size) {
            return {
                start: start,
                size: size,
                end: start + size
            };
        }
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
                    value = model.start;
                }
                minimumValue: model.min
                maximumValue: model.max
            }

            Slider {
                value: model.end
                onValueChanged: {
                    model.tryMoveEndTo(value);
                    value = model.end;
                }
                minimumValue: model.min
                maximumValue: model.max
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
                prefix: "/arc"
                deviceNameToMatch: "monome arc 4"
                serialOSC: serialOSC

                property string aspectToEdit: "none"
                function cycleAspectToEdit() {
                    var table = {
                        none: "start",
                        start: "end",
                        end: "none",
                    };

                    aspectToEdit = table[aspectToEdit];
                }

                property real baseValuePerArcDelta: 1.0 / 64.0 / 4.0
                property real fineScale: 1.0 / 64.0
                property bool fineDelta: false
                property real valuePerArcDelta: {
                    return (fineDelta ? fineScale : 1.0) * baseValuePerArcDelta;
                }

                onPressed: {
                    if (encoder === 0) {
                        fineDelta = true;
                    }
                }

                onReleased: {
                    if (encoder === 0) {
                        cycleAspectToEdit();
                    }

                    if (encoder === 0) {
                        fineDelta = false;
                    }
                }

                onDelta: {
                    if (encoder === 0) {
                        var modelDelta = delta * baseValuePerArcDelta;
                        if (aspectToEdit === "start") {
                            model.tryMoveStartTo(model.start + modelDelta);
                        } else if (aspectToEdit == "end") {
                            model.tryMoveEndTo(model.end + modelDelta);
                        }
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
                            return Math.min(63, Math.max(0, (64.0 * (value - model.min) / (model.max - model.min))|0));
                        },
                        startTick = valueToRingValue(model.start),
                        endTick = valueToRingValue(model.end);

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