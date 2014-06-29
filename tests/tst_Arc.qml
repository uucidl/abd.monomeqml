import com.uucidl.monome 1.0

import QtQml 2.2
import QtTest 1.0

import "testUtils.js" as Utils

TestCase {
    name: "Arc"

    Component {
        id: arcComponent

        Arc {
                serialOSC: null
        }
    }

    function test_thatItMatchesByDevice_data() {
        var device = function (name, port) {
            return Devices.makeDevice(null, name, port);
        };
        return [
            {
                tag: "nothing found (empty list)",
                devices: [],
                matchName: "",
                expectedUrl: "",
            },
            {
                tag: "nothing found",
                devices: [
                    device("one", 1),
                    device("two", 2),
                    device("two", 3),
                    device("three", 4)
                ],
                matchName: "other",
                expectedUrl: "",
            },

            {
                tag: "found the first one",
                devices: [
                    device("one", 1),
                    device("two", 2),
                    device("two", 3),
                    device("three", 4)
                ],
                matchName: "two",
                expectedUrl: "osc.udp://host:2",
            },
        ];
    }

    function withArc(fn) {
        return Utils.withComponent(arcComponent, null, {}, fn);
    }

    function test_thatItMatchesByDevice(data) {
        withArc(function (object) {
            object.deviceNameToMatch = data.matchName;
            var url = object.arcDeviceUrl("host", data.devices);
            compare(url, data.expectedUrl);
        });
    }

    function test_thatItMatchesBySerial_data() {
        var device = function (serial, port) {
            return Devices.makeDevice(serial, null, port);
        };
        return [
            {
                tag: "nothing found (empty list)",
                devices: [],
                matchSerial: null,
                expectedUrl: "",
            },
            {
                tag: "nothing found",
                devices: [
                    device("one", 1),
                    device("two", 2),
                    device("two", 3),
                    device("three", 4)
                ],
                matchSerial: "other",
                expectedUrl: "",
            },
            {
                tag: "found the first one",
                devices: [
                    device("one", 1),
                    device("two", 2),
                    device("two", 3),
                    device("three", 4)
                ],
                matchSerial: "two",
                expectedUrl: "osc.udp://host:2",
            },
        ];
    }

    function test_thatItMatchesBySerial(data) {
         withArc(function (object) {
            object.deviceSerialToMatch = data.matchSerial;
            var url = object.arcDeviceUrl("host", data.devices);
            compare(url, data.expectedUrl);
        });
    }

    function test_thatItMatchesBySerialPreferrentially(data) {
        withArc(function (object) {
            object.deviceSerialToMatch = "the-name";
            object.deviceNameToMatch = "the-type";
            var url = object.arcDeviceUrl("host", [
                Devices.makeDevice("a", "one", 1),
                Devices.makeDevice("b", "the-type", 2),
                Devices.makeDevice("the-name", "three", 3),
            ]);
            compare(url, "osc.udp://host:3");
        });
    }
}