module seranyl.ui;

import std.stdio;
import std.conv;
import std.string;
import std.algorithm;
import std.math;

import raylib;
import serial.device;

import seranyl.comms;
import seranyl.data;
import seranyl.rendering;


class ByteGrid : Renderable {
    private int packetSize;
    private Packets packets;
    private Bytes* bytes;
    private int offset;

    this(int packetSize, int offset, Bytes* bytes) {
        this.packetSize = packetSize;
        this.offset = offset;
        this.bytes = bytes;

        packets = new Packets(bytes, packetSize);
    }

    private Byte* offsetPointer() {
        Byte* currentPtr = bytes.first;

        for (int i = 0; i < offset; i ++) {
            currentPtr = currentPtr.next;
            if (currentPtr.next == null) return currentPtr;
        }

        return currentPtr;
    }

    public void nextByte() {
        offset = min(offset + 1, packets.byteCount);
    }

    public void prevByte() {
        offset = max(offset - 1, 0);
    }

    public void nextPacket() {
        offset = offset + packetSize <= packets.byteCount ? offset + packetSize : offset;
    }

    public void prevPacket() {
        offset = offset - packetSize >= 0 ? offset - packetSize : offset;
    }

    public ubyte getLRC() {
        ubyte lrc = 0;
        Byte* ptr = offsetPointer();
        if (ptr == null) return 0x00;
        for (int i = 0; i < packetSize - 2; i ++) {
            lrc += ptr.value;
            lrc &= 0xFF;
            ptr = ptr.next;
            if (ptr == null) break;
        }
        lrc = ((lrc ^ 0xFF) + 1) & 0xFF;
        return lrc;
    }

    public ubyte getCRC8() {
        // need to properly implement (placeholder)
        // since we also need to be able to input the polynome
        return 0x00;
    }

    public void deleteByte() {
        Byte* currentPtr = offsetPointer();
        if (currentPtr.prev != null) currentPtr.prev.next = currentPtr.next;
        if (currentPtr.next != null) currentPtr.next.prev = currentPtr.prev;
        if (currentPtr.next != null) currentPtr = currentPtr.next;

        // regenerate packets
        packets = new Packets(bytes, packetSize);
    }

    public void deletePacket() {
        Byte* currentPtr = offsetPointer();
        Byte* joinPtr = currentPtr;
        for (int i = 0; i < packetSize; i ++) {
            if (joinPtr == null) break;
            joinPtr = joinPtr.next;
        }

        if (currentPtr.prev != null) currentPtr.prev.next = joinPtr;
        if (joinPtr != null) joinPtr.prev = currentPtr.prev;
        currentPtr = joinPtr;

        // regenerate packets
        packets = new Packets(bytes, packetSize);
    }

    public void resetBytes(Bytes* bytes) {
        offset = 0;
        this.bytes = bytes;
        this.packets = new Packets(bytes, packetSize);
    }

    public void addByte(byte val) {
        packets.addByte(val);
    }

    public int getOffset() {
        return offset;
    }

    public int getByteCount() {
        if (packets is null) return 0;
        return packets.byteCount;
    }

    public int getPacketCount() {
        if (packets is null) return 0;
        return packets.packetCount;
    }

    public int getPacketOffset() {
        return offset / packetSize;
    }

    override void render(Screen screen) {
        Byte* temp = offsetPointer();
        for (int i = 0; i < packetSize * 12; i ++) {
            if (temp != null) {
                temp.render(screen, i % packetSize, i / packetSize, packetSize, 12);
                temp = temp.next;
            } else {
                new Byte(0).render(screen, i % packetSize, i / packetSize, packetSize, 12);
            }
        }
    }
}
