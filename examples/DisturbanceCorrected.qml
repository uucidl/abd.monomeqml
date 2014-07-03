import QtQml 2.0

//
// Allow to correct a phenomena that is disturbed by another
// phenomena.
//
QtObject {
    id: root

    // the real model adjustment function
    property var modelAdjustBy: function (delta) {}
    property real correctionWindowMs: 70.0
    property real lastDisturbanceInMs: 0.0

    // call to record a disturbance that must be filtered out
    function disturb() {
        lastDisturbanceInMs = Date.now();
        root.history.rollback(root.lastDisturbanceInMs);
    }

    // call to apply the delta
    function adjustBy(delta) {
        var now = Date.now();
        if (now > lastDisturbanceInMs + correctionWindowMs) {
            modelAdjustBy(delta);
            root.history.record(delta);
        }
    }

    property var history: {
        var self = {
            changes: [],
            reset: function () {
                self.changes = [];
            },
            record: function (delta) {
                var now = Date.now(),
                recentEnough = function (event) {
                    return event.ts >= now - correctionWindowMs;
                };

                self.changes = self.changes.filter(recentEnough);
                self.changes.push({ ts: now, delta: delta });
            },
            rollback: function (now) {
                self.changes.reverse().forEach(function (e) {
                    if (e.ts >= now - root.correctionWindowMs) {
                        root.modelAdjustBy(-e.delta);
                        e.rolledBack = true;
                    }
                });

                self.changes = self.changes.filter(function (e) {
                    return e.rolledBack === undefined;
                });
            }
        };

        return self;
    }

    onModelAdjustByChanged: {
        root.history.reset();
    }
}