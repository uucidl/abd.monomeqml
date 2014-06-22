import com.uucidl.monome 1.0

import QtQml 2.2
import QtTest 1.0

import "testUtils.js" as Utils

TestCase {
    name: "Arc4"

    Component {
        id: arc4Component

        Arc4 {
                serialOSC: null
        }
    }

    function test_thatItMatchesByDevice_data() {
        var device = function (type, port) {
            return { type: type, port: port };
        };
        return [
            {
                tag: "nothing found (empty list)",
                devices: [],
                matchType: null,
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
                matchType: "other",
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
                matchType: "two",
                expectedUrl: "osc.udp://host:2",
            },
        ];
    }

    function withArc4(fn) {
        return Utils.withComponent(arc4Component, null, {}, fn);
    }

    function test_thatItMatchesByDevice(data) {
        withArc4(function (object) {
            object.deviceTypeToMatch = data.matchType;
            var url = object.arcDeviceUrl("host", data.devices);
            compare(url, data.expectedUrl);
        });
    }

    function test_thatItMatchesByName_data() {
        var device = function (name, port) {
            return { name: name, type: "dummy", port: port };
        };
        return [
            {
                tag: "nothing found (empty list)",
                devices: [],
                matchName: null,
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

    function test_thatItMatchesByName(data) {
         withArc4(function (object) {
            object.deviceNameToMatch = data.matchName;
            var url = object.arcDeviceUrl("host", data.devices);
            compare(url, data.expectedUrl);
        });
    }

    function test_thatItMatchesByNamePreferrentially(data) {
        withArc4(function (object) {
            object.deviceNameToMatch = "the-name";
            object.deviceTypeToMatch = "the-type";
            var url = object.arcDeviceUrl("host", [
                { name: "a", type: "one", port: 1 },
                { name: "b", type: "the-type", port: 2 },
                { name: "the-name", type: "three", port: 3 },
            ]);
            compare(url, "osc.udp://host:3");
        });
    }
}