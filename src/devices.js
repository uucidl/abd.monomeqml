"use strict";

function makeDevice(serial, name, port)
{
        return { serial : serial, name : name, port : port | 0 };
}
