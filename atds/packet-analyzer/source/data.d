module seranyl.data;

import std.stdio;
import std.math;
import std.algorithm;
import std.string;
import std.format;
import std.conv;

import raylib;

import seranyl.ui;
import seranyl.rendering;


class Byte {
    byte value;
    Byte* next;
    Byte* prev;

    this(byte b) {
        value = b;
    }

    this(byte b, Byte* next) {
        value = b;
        this.next = next;
    }

    this(byte b, Byte* next, Byte* prev) {
        value = b;
        this.next = next;
        this.prev = prev;
    }

    override string toString() {
        return format("0x%x", value);
    }

    string toChar() {
        return to!string(cast(char) value);
    }

    private string formatValue() {
        return format("0x%x\n%c\n%d", cast(char) value, cast(char) value, cast(ubyte) value % 0xFF);
    }

    private Color valueColor() {
        // generate a color based on the value

        if (value == 0x00) return Colors.GRAY;


        float hue = value * (360 / 255.0);

        // pretty standard algorithm for HSV -> RGB
        float c = 0.8; // = value
        float x = 0.8 * (1 - abs(fmod(hue / 60.0, 2) - 1));

        float r, g, b;
        if (hue >= 0 && hue < 60) {
            r = c,g = x,b = 0;
        }
        else if (hue >= 60 && hue < 120) {
            r = x,g = c,b = 0;
        }
        else if (hue >= 120 && hue < 180) {
            r = 0,g = c,b = x;
        }
        else if (hue >= 180 && hue < 240) {
            r = 0,g = x,b = c;
        }
        else if (hue >= 240 && hue < 300) {
            r = x,g = 0,b = c;
        }
        else {
            r = c,g = 0,b = x;
        }

        return Color(cast(ubyte) (r * 255), cast(ubyte) (g * 255), cast(ubyte) (b * 255), 255);
    }

    private Color textColor() {
        // return white if it's too dark, otherwise return black
        Color vc = valueColor();

        int value = max(vc.r, max(vc.g, vc.b));

        if (value > 128) {
            return Colors.BLACK;
        }
        return Colors.WHITE;
    }

    public void render(Screen screen, int col, int row, int cols, int rows) {
        DrawRectangle(
                            cast(int) (col * screen.size.x / cols + 300),
                            cast(int) (row * screen.size.y / rows),
                            cast(int) (screen.size.x / cols),
                            cast(int) (screen.size.y / rows),
                            valueColor()
                     );

        DrawRectangleLines(
                            cast(int) (col * screen.size.x / cols + 300),
                            cast(int) (row * screen.size.y / rows),
                            cast(int) (screen.size.x / cols),
                            cast(int) (screen.size.y / rows),
                            Colors.BLACK
                          );

        DrawText(
                cast(const(char)*) toStringz(formatValue()),
                cast(int) (screen.size.x / cols * (col + 0.5) + 300 - 25),
                cast(int) (screen.size.y / rows * (row + 0.5) - 40),
                20,
                textColor()
                );

    }
}


const int MAX_BYTES = 256 * 256;

class Bytes {
    Byte* first;
    Byte* last;

    ByteGrid* bg;

    int size;

    this() {
        size = 0;
    }

    override string toString() {
        string s = "";
        s ~= "[";
        Byte* ptr = first;
        while(ptr != null) {
            s ~= (*ptr).toString();
            s ~= " ";
            ptr = (*ptr).next;
        }
        s ~= "]";
        return s;
    }

    public Byte* addByte(byte val) {
        // really don't know why I need to do this
        // blah blah blah, memory safety
        // treat these three lines as one: Byte* b = &(new Byte(val));
        Byte[] temp = new Byte[1];
        temp[0] = new Byte(val);
        Byte* b = &temp[0];
        if (first == null || last == null) {
            first = b;
            last = b;
        }
        last.next = b;
        b.prev = last;
        last = b;

        if (size >= MAX_BYTES) {
            first = first.next;
            size --;
        }
        size ++;

        return b;
    }
}

class Packet {
    Byte* start;
    Byte* end;
    Packet* prev;
    Packet* next;
    int length;
    int packetSize;

    this(int packetSize) {
        this.packetSize = packetSize;
        this.length = 0;
    }

    // assume b is pre-connected
    // addByte returns whether it is full
    public bool addByte(Byte* b) {
        if (start == null || end == null) {
            start = b;
            end = b;
            length = 1;
        } else {
            end = b;
            length ++;
        }
        if (length >= packetSize) {
            return true;
        }
        return false;
    }

    override string toString() {
        if (start == null || end == null) return "[]";
        string s = "";
        s ~= "[";
        Byte* ptr = start;
        while(ptr != end) {
            s ~= (*ptr).toString();
            s ~= " ";
            ptr = (*ptr).next;
        }
        s ~= (*end).toString();
        s ~= "]";
        return s;
    }
}

class Packets {
    Packet* first;
    Packet* last;
    Bytes* bytes;
    int packetSize;
    int packetCount = 0;
    int byteCount = 0;

    this(int packetSize) {
        this.packetSize = packetSize;
    }

    this(Bytes* bytes, int packetSize) {
        this.packetSize = packetSize;
        this.bytes = bytes;
        Byte* ptr = bytes.first;
        while (ptr != null) {
           addByte(ptr);
           ptr = ptr.next;
        }
    }

    public void addByte(byte val) {

        if (first == null || last == null) {
            // memory safety trick
            Packet[] temp = new Packet[1];
            temp[0] = new Packet(packetSize);
            first = &temp[0];
            last = &temp[0];

            packetCount ++;
        }

        Byte* b = bytes.addByte(val);

        bool generateNewPacket = last.addByte(b);


        if (generateNewPacket) {
            // memory safety trick
            Packet[] temp = new Packet[1];
            temp[0] = new Packet(packetSize);
            temp[0].prev = last;
            last.next = &temp[0];
            last = &temp[0];
            packetCount ++;
        }
        byteCount ++;
    }

     public void addByte(Byte* b) {

        if (first == null || last == null) {
            // memory safety trick
            Packet[] temp = new Packet[1];
            temp[0] = new Packet(packetSize);
            first = &temp[0];
            last = &temp[0];

            packetCount ++;
        }

        bool generateNewPacket = last.addByte(b);

        if (generateNewPacket) {
            Packet[] temp = new Packet[1];
            temp[0] = new Packet(packetSize);
            temp[0].prev = last;
            last.next = &temp[0];
            last = &temp[0];
            packetCount ++;
        }

        byteCount ++;
    }

    override string toString() {
        if (first == null || last == null) return "[[]]";
        string s = "";
        s ~= "[\n\t";
        Packet* ptr = first;
        while(ptr != last) {
            s ~= (*ptr).toString();
            s ~= "\n\t";
            ptr = (*ptr).next;
        }
        s ~= (*last).toString();
        s ~= "\n]";
        return s;
    }
}
