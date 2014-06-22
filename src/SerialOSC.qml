import QtQml 2.2

import com.uucidl.monome 1.0

QtObject {
    id: root

    property int port: 12002
    property string hostname: "localhost"

    property string clientHostname: "localhost"
    property int clientPort: 9000

    property var knownDevices: []
    property var activeDevices: []

    property OSCDestination toSerialOSC: OSCDestination {
        oscUrl: "osc.udp://" + hostname + ":" + port
    }

    property OSCServer listener: OSCServer {
        port: root.clientPort
        onMessageIn: {
            var makeDevice = function() {
                return { id: data[1], type: data[2], port: data[3] };
            };
            if (data[0] === "/serialosc/device") {
                knownDevices.push(makeDevice());
                activeDevices = knownDevices;
                toSerialOSC.send("/serialosc/notify",[root.clientHostname, clientPort]);
            } else if (data[0] === "/serialosc/add") {
                var withSameId = function(device) {
                    return device.id === data[1];
                }, withDifferentId = function (device) {
                    return !withSameId(device);
                };

                var device = makeDevice();
                knownDevices = knownDevices.filter(withDifferentId).concat([device]);
                activeDevices = activeDevices.filter(withDifferentId).concat([device]);
                toSerialOSC.send("/serialosc/notify",[root.clientHostname, clientPort]);
            } else if (data[0] === "/serialosc/remove") {
                activeDevices = activeDevices.filter(function (device) {
                    return device.id !== data[1];
                });
                toSerialOSC.send("/serialosc/notify",[root.clientHostname, clientPort]);
            }
        }
    }

    function scanDevices() {
        // tell me about any update
        toSerialOSC.send("/serialosc/list", [root.clientHostname, clientPort]);
    }

    Component.onCompleted: {
        scanDevices();
    }
}