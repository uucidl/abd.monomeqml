import QtQml 2.0

QtObject {
    id: root
    property var modelAdjustBy: function (deltaInModelUnits) {}

    property real baseValuePerDelta: 1.0 / 64.0 / 4.0
    property real fineScale: 1.0 / 64.0
    property bool fineDelta: false
    property real valuePerDelta: {
        return (fineDelta ? fineScale : 1.0) * root.baseValuePerDelta;
    }

    function adjustBy(delta) {
        var modelDelta = delta * root.valuePerDelta;
        modelAdjustBy(modelDelta);
    }
}