import std.stdio;
import std.conv;
import std.string;
import core.thread;
import core.stdc.stdlib;

import raylib;
import raygui;
import serial.device;

import seranyl.comms;
import seranyl.data;
import seranyl.ui;
import seranyl.rendering;


const string VERSION = "v0.1";


class Application {
    Bytes* bytes;
    SerialInterface* serial;
    ByteGrid* bg;


    this(Bytes* bytes, SerialInterface* serial, ByteGrid* bg) {
        this.bytes = bytes;
        this.serial = serial;
        this.bg = bg;
    }
}

void cleanup(SerialInterface ser) {
    CloseWindow();
    ser.stop();
}

void main()
{
    // start by asking for serial params, since we can't change those on the fly
    writeln("\n\n\n\n\n\n\n\nseranyl packet analyzer " ~ VERSION ~ "\n\nenter serial port:");
    writeln(SerialPort.ports());
    string port;
    try {
        readf!"%s\n"(port);
    } catch (Exception e) {
        writeln("invalid input");
        exit(0);
    }

    writeln("enter baud rate:");
    int baud;
    try {
        readf!"%d\n"(baud);
    } catch (Exception e) {
        writeln("invalid input");
        exit(0);
    }

    BaudRate baudrate = switchBaud(baud);
    SetTargetFPS(30);
    InitWindow(1680, 1080, "seranyl packet analyzer");

    Screen screen = Screen();
    RenderQueue rq = new RenderQueue(screen);

    int packetSize = 15;

    auto bytes = new Bytes();
    auto bg = new ByteGrid(packetSize, 0, &bytes);
    auto ser = new SerialInterface(port, baudrate, &bg);

    auto app = new Application(&bytes, &ser, &bg);

    scope(exit) cleanup(ser);

	while(!WindowShouldClose()) {

        ser.update();

        BeginDrawing();
        ClearBackground(Colors.RAYWHITE);


        // packet size GuiSlider
        int newPacketSize = cast(int) (GuiSlider(Rectangle(1440, 30, 210, 60), "Packet\nSize", cast(const(char)*) toStringz(to!string(packetSize)), packetSize, 1, 20));

        if (newPacketSize != packetSize) {
            packetSize = newPacketSize;
            bg = new ByteGrid(packetSize, bg.getOffset(), &bytes);
        }

        // movement buttons
        if (GuiButton(Rectangle(40, 20, 100, 100), "<- Byte")) {
            bg.prevByte();
        }
        if (GuiButton(Rectangle(160, 20, 100, 100), "Byte ->")) {
            bg.nextByte();
        }
        if (GuiButton(Rectangle(40, 140, 100, 100), "<- Packet")) {
            bg.prevPacket();
        }
        if (GuiButton(Rectangle(160, 140, 100, 100), "Packet ->")) {
            bg.nextPacket();
        }

        // serial controls
        if (GuiButton(Rectangle(40, 260, 60, 60), "Stop\nSerial")) {
            if (ser.alive()) ser.stop();
        }
        if (GuiButton(Rectangle(120, 260, 60, 60), "Start\nSerial")) {
            if (!ser.alive()) ser.start();
        }
        if (GuiButton(Rectangle(200, 260, 60, 60), "Renew\nSerial")) {
            if (ser.alive()) ser.stop();
            ser.start();
        }

        // delete controls

        if (GuiButton(Rectangle(40, 340, 100, 100), "Delete Byte")) {
            bg.deleteByte();
        }
        if (GuiButton(Rectangle(160, 340, 100, 100), "Delete Packet")) {
            bg.deletePacket();
        }


        // reset buttons
        if (GuiButton(Rectangle(40, 960, 100, 100), "Reset Bytes")) {
            bytes = new Bytes();
            bg.resetBytes(&bytes);
        }
        if (GuiButton(Rectangle(160, 960, 100, 100), "Reset Serial")) {
            if (ser.alive()) ser.stop();
            ser = new SerialInterface(port, baudrate, &bg);
            ser.start();
        }

        // left side labels
        DrawText(
                cast(const(char)*) toStringz(format("seranyl %s\n%s\n%d baud",
                                    VERSION,
                                    port,
                                    baud
                )),
                20,
                480,
                20,
                Colors.BLACK
        );

        DrawText(
                cast(const(char)*) toStringz(format("cursor: 0x%X (%d)\nreceived: 0x%X (%d)",
                                    bg.getOffset(),
                                    bg.getOffset(),
                                    bg.getByteCount(),
                                    bg.getByteCount()
                )),
                20,
                660,
                20,
                Colors.BLACK
        );
        DrawText(
                cast(const(char)*) toStringz(format("packet: 0x%X (%d)\ntotal: 0x%X (%d)",
                                    bg.getPacketOffset(),
                                    bg.getPacketOffset(),
                                    bg.getPacketCount(),
                                    bg.getPacketCount()
                )),
                20,
                780,
                20,
                Colors.BLACK
        );

        // right side labels
        DrawText(
                cast(const(char)*) toStringz(format("CRC: 0x%x\nLRC: 0x%x",
                                    bg.getCRC8(),
                                    bg.getLRC(),
                )),
                1400,
                260,
                30,
                Colors.BLACK
        );

        // cheesy "seranyl" vertical text to fill up space
        DrawTextPro(
                GetFontDefault(),
                cast(const(char)*) toStringz("seranyl"),
                Vector2(1530, 350),
                Vector2(1530, 350),
                -90,
                128,
                1.0,
                Colors.LIGHTGRAY
        );


        bg.render(screen);

        // draw cursor
        DrawRectangleLinesEx(Rectangle(300, 0, 1080, 90), 5, Colors.DARKGRAY);
        DrawRectangleLinesEx(Rectangle(300, 0, 1080 / packetSize, 90), 5, Colors.BLACK);


        EndDrawing();
	}
}
