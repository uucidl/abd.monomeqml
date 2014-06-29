import com.uucidl.monome 1.0

import QtQml 2.2

// Arc4 controller
// Device:
//     http://monome.org/devices/
// OSC protocol:
//     http://monome.org/docs/tech:osc

Arc {
    id: root

    // an OSC prefix to use (to be unique)
    prefix: "/arc4"
    deviceTypeToMatch: "monome arc 4"

    onDelta: {
        rings[encoder] += delta / 64.0;
        ringsChanged();
    }

    onPressed: {
        ringsPressed[encoder] = true;
        ringsPressedChanged();
    }

    onReleased: {
        ringsPressed[encoder] = false;
        ringsPressedChanged();
    }

    property var rings: [0.0, 0.0, 0.0, 0.0]
    property var ringsPressed: [false, false, false, false]
}