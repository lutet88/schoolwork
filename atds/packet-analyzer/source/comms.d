module seranyl.comms;

import core.time;
import core.thread;
import std.stdio;
import std.concurrency;

import serial.device;

import seranyl.data;
import seranyl.ui;


class SerialInterface {
    immutable(string) port;
    immutable(BaudRate) baud;

    private Tid worker;
    private bool running = false;

    private byte buf;

    private ByteGrid* bg;

    this(string port, BaudRate baud, ByteGrid* bg) {
        this.port = port;
        this.baud = baud;
        this.bg = bg;
    }

    public void start() {
        worker = spawn(&readSerial, thisTid, port, baud);
        running = true;
    }

    public void stop() {
        send(worker, false);
        // allow worker to join and safely exit
        Thread.sleep(seconds(1));
        running = false;
    }

    public void update() {
        if (!running) return;
        while (receiveTimeout(seconds(0), (byte b) { buf = b; })) {
            (*bg).addByte(buf);
        }
    }

    public void setByteGrid(ByteGrid* bg) {
        this.bg = bg;
    }

    public bool alive() {
        return running;
    }

    private static void readSerial(Tid parent, string port, BaudRate baud) {
        auto ser = new SerialPort(port, seconds(1), seconds(1));
        ser.speed(baud);
        writeln("serial port created");

        bool running = true;
        while(running) {
            void[1] buf = void;
            ser.read(buf);
            byte[] chars = cast(byte[]) buf;
            send(parent, chars[0]);

            receiveTimeout(msecs(10), (bool r) { running = r; });
        }

        send(parent, false);
    }
}

// copied from the source code of NCrashed/serial-port, since the library doesn't provide access
BaudRate switchBaud(uint baud) {
    // this is equivalent to a python dictionary (associative array)
    BaudRate[uint] baudRatetoUint = [
        0 : BaudRate.BR_0,
        50 : BaudRate.BR_50,
        75 : BaudRate.BR_75,
        110 : BaudRate.BR_110,
        134 : BaudRate.BR_134,
        150 : BaudRate.BR_150,
        200 : BaudRate.BR_200,
        300 : BaudRate.BR_300,
        600 : BaudRate.BR_600,
        1200 : BaudRate.BR_1200,
        1800 : BaudRate.BR_1800,
        2400 : BaudRate.BR_2400,
        4800 : BaudRate.BR_4800,
        9600 : BaudRate.BR_9600,
        19_200 : BaudRate.BR_19200,
        38_400 : BaudRate.BR_38400,
        57_600 : BaudRate.BR_57600,
        115_200 : BaudRate.BR_115200,
        230_400 : BaudRate.BR_230400
    ];
    if (baud in baudRatetoUint) {
        return baudRatetoUint[baud];
    }
    return BaudRate.BR_UNKNOWN;
}
