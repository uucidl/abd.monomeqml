import com.uucidl.monome 1.0

import QtQml 2.2

// Generic Arc controller interface
// Device:
//     http://monome.org/devices/
// OSC protocol:
//     http://monome.org/docs/tech:osc
QtObject {
    id: root

    // an OSC prefix to use (to be unique)
    property string prefix

    // configure the device name to match
    property string deviceNameToMatch

    // configure the device serial to match. will override the type matching
    property var deviceSerialToMatch

    // this is the device discovery service
    property SerialOSC serialOSC

    // feed me the server to use
    property OSCServer receiver: serialOSC.listener

    // whether the device is connected
    property bool connected

    // sent when a delta arrives from an encoder
    signal delta(int encoder, int delta)

    // sent when an encoder has been pressed
    signal pressed(int encoder)

    // sent when an encoder has been released
    signal released(int encoder)

    property OSCDestination device: OSCDestination {
        oscUrl: arcDeviceUrl(serialOSC.hostname, serialOSC.activeDevices)
        onOscUrlChanged: {
            connected = false;
            if (oscUrl != "") {
                send("/sys/host", ["localhost"]);
                send("/sys/port", [root.receiver.port]);
                send("/sys/prefix", [prefix]);
                send("/sys/info", []);
            }
        }
    }

    property list<QtObject> children: [
        Connections {
            target: receiver
            onMessageIn: parseMessageIn(data)
        }
    ]

    // implementation

    function parseMessageIn(data) {
        var encoderDelta = root.prefix + "/enc/delta",
            encoderPressed = root.prefix + "/enc/key";

        if (data[0] === "/sys/prefix") {
            root.connected = data[1] === prefix;
        } else if (data[0] === encoderDelta) {
            delta(data[1], data[2]);
        } else if (data[0] === encoderPressed) {
            var encoderId = data[1];
            if (data[2] > 0) {
                pressed(encoderId);
            } else {
                released(encoderId);
            }
        }
    }

    //! send command name to the device
    // extra arguments are passed verbatim
    function sendArcCommand(commandName) {
        var args = Array.prototype.slice.call(arguments);
        device.send(prefix + commandName, args.slice(1));
    }

    function arcDeviceUrl(hostname, activeDevices) {
        var arcDevices = activeDevices.filter(function (device) {
            if (deviceSerialToMatch) {
                return device.serial === deviceSerialToMatch;
            }

            console.log(JSON.stringify(device));
            return device.name === deviceNameToMatch;
        });

        if (arcDevices.length < 1) {
            return "";
        }

        return "osc.udp://" + hostname + ":" + arcDevices[0].port;
    }
}