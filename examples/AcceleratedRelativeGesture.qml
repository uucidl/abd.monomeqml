import QtQml 2.0

LinearRelativeGesture {
    id: root

    /// How far to look back into the past to decide the acceleration
    property real lookupWindowMs: 250.0

    /// How much the accumulated deltas must be to double the speed
    property int deltaTilDoubling: 64

    /// How much the accumulated deltas must be to get to the normal speed
    property int deltaTilNormal: 8

    property var history: []

    function adjustBy(delta) {
        var now = Date.now();

        history = history.filter(function (d) {
            return d.ts >= now - root.lookupWindowMs;
        })

        var deltaInTimeframe = Math.abs(history.reduce(function (v, e) {
            return v + e.delta;
        }, 0)) - deltaTilNormal;

        var power = 0.0;

        if (deltaInTimeframe <= 0.0) {
            power = deltaInTimeframe / deltaTilNormal;
        } else {
            power = deltaInTimeframe / (deltaTilDoubling - deltaTilNormal);
        }

        var scale = Math.pow(2.0, power);
        modelAdjustBy(delta * scale * root.valuePerDelta);

        history.push({ ts: now, delta: delta });
    }
}