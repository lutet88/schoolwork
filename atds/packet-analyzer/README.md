# seranyl packet analyzer
### ATDS linked list project

## Introduction
Since the very beginning of freshman year at SAS, I've been a highly committed member of the robotics program, becoming an EECS mentor in sophomore year and overall captain of the MATE program by junior year. In robotics, serial communication between a backend program on a computer and a microcontroller is one of the easiest and most effective ways to control a robot. Commonly, either the CAN bus or UART is used for this purpose; CAN bus is generally proprietary with its protocols, so for the purpose of teaching new MATE members basic serial communications, I've always stuck to UART. 

One major problem with new members developing packet structures is that they often don't know what the problem is. For example, take a look at this excerpt from [one of the EECS capstone projects this year](https://github.com/one-degree-north/mate-2021-capstone-lightfan/blob/main/HardwareInterface/HardwareInterface.ino):
```c
// header
Serial.write(0x7f);

// byte 1
uint16_t photoresistor = analogRead(A1);

// map it to 0-255
uint8_t photoresistorMapped = map(photoresistor, 0, 1023, 0, 255);
Serial.write(photoresistor);

// byte 2
uint8_t rpm = emc.getFanRPM() / 50;
Serial.write(rpm);

// byte 3
uint8_t temp = emc.getExternalTemperature();
Serial.write(temp);
```
This is a really simple problem: byte 1 is sending the 16-bit unsigned integer rather than the mapped version, which results in some interesting behavior with Arduino (`Serial.write` may send 1 or 2 bytes). However, this was not very clear to my team members, who were introduced to serial communication and packets just days before. This team spent an entire 3pm-6pm session trying to figure out why their packet success rate was so low.

In order to address this problem, we can provide students with a visual aid, in order to provide a way to visually debug problems with the packet structure.

## Market Analysis
The market for a free serial packet analysis software is pretty sparse, with just a few options and possibilities. The market is dominated by hardware companies, providing their own integrated solution on their own platform. However, solutions do exist, though they are primarily targeted at developers. 

* [Free Packet Analyzer](https://freeserialanalyzer.com/) - Free Trial, $5.00/mo
	* ![Free Serial Protocol Analyzer Screenshot](https://freeserialanalyzer.com/images/products/screenshots/index-free-serial-analyzer-monitoring.png)
	* I've personally used Free Packet Analyzer over the summer to diagnose problems with packets over the summer: it is a confusing, unhelpful mess. The software generates a text-style layout of each individual byte, plus a table of hex values. It's not convenient to shift packets and bytes around, and is not user-friendly enough for a introductory audience.
* [SerialMon](https://www.serialmon.com/)(Windows only) - Freeware
	* SerialMon provides a simple Windows 98-esque interface that allows packet analysis on Windows COM ports, supporting UART and RS232. However, it doesn't seem to work anymore (Windows 11?), though it held high regard in forum posts from the early 2000s.
* [PuTTY](https://www.putty.org/)(Windows) or `screen`(Linux) - Open Source, permissive
	* It's possible to analyze packets through a text-based interface by connecting a serial window to the tty port. This is probably the traditional way to debug packets, given no special tools. However, it is simply too much of a hassle and does not provide easy visual feedback; you're stuck between viewing hex codes or ASCII characters.


## Rationale
A serial packet analyzer targeted at introductory firmware developers should be highly visual and present communications concepts in a simplistic way. However, the target audience should  have some knowledge of how their system works and basic communications principles: mainly how serial ports are listed on their operating system and some understanding of baud rate. 

A cross-platform serial port library must be used to allow compatibility on the big 3 operating systems (Windows, Mac, Linux). The program would make sense both as a script and a compiled program, but due to limitations of various GUI libraries, a compiled program should be used. The byte stream can be represented as a linked list, and packets can be represented as such also; each packet contains pointers to its first and last byte, plus its length and needed methods. Using a 2D array is inefficient as the whole data structure must be regenerated whenever a byte must be shifted. Instead, with the byte/packet linked lists, only the packets must be regenerated only when a byte is entirely deleted or the packet size changes. 

Although the ATDS curriculum informally requires the use of Java, Java's virtual machine makes accessing system slots (such as serial ports) very difficult. Although attempts to create such a library exist ([jSerialComm](https://fazecast.github.io/jSerialComm/)), its connection to a system port is inconsistent and fails entirely during a hardware change. Due to this, I was left with few options: C++ with Qt, .NET, or D with raygui. I chose the latter since it would guarantee maximum portability and that I've recently done two other projects with the framework.

## Testing
Due to the nature of my program, my testing solution was to make a device that can send packets of all sorts to my program.
![device](https://i.imgur.com/YTcjtnX.png)The device takes data from a BNO055 accelerometer, and outputs a variety of testing modes:
|Mode|Function|
|--|--|
|0|Simple packet - 3 bytes cyclic|
|1|Orientation float + LRC - 15 bytes|
|2|Orientation float + CRC8 - 15 bytes|
|3|Rainbow packets|
|4|"Problematic circuit" - 250Hz sine wave|
|5|Orientation + Acceleration + Magnetic Field + Temperature + LRC - 48 bytes|
Since the goal is to be able to intuitively analyze each of these situations, the pass conditions for each test can be manually assessed with each version of the program.


## Data Structures & Diagrams
![UML](https://i.imgur.com/MRokku1.png)UML Diagram, excluding Application (GUI) and Serial

### Application Procedure
![app](https://i.imgur.com/ve6kEJ4.png)
Once all objects are created, the application consists of an application loop, going between three logical blocks: `SerialInterface.update()`, updating the `ByteGrid`, the object containing parameters for where the current cursor is, the current packet size, etc., and `ByteGrid.render()`, a method that renders all bytes in a central grid based on color, packet size, and lots of other parameters previously defined, calling `raylib` and `raygui` APIs. Additionally, side GUI elements are simply part of the `main()` loop, since I didn't want to define render methods for each individual GUI element.

### Serial Communications
![Displaying 2021-12-14_11-34.png](https://i.imgur.com/D7jrMZf.png)
Since the serial port must be constantly refreshed in order to keep the system slot alive, I launch a secondary thread using `std.concurrency.spawn`. This thread simply runs a while loop trying to constantly read from the `SerialPort` object, sending all bytes into the message queue with the main thread. The main thread reads the entire queue and adds each bytes every time `update()` is called. Communication the other way, from the main thread to the worker thread is also used to halt the worker when Serial needs to stop, although a 1-second delay is added to safely halt the thread.

### GUI Interface
![GUI](https://i.imgur.com/JeJsphu.png)
The GUI is designed to be simple and straight-forward. Using `raygui`, the GUI presents all information a novice user might want. At the top, the current packet and byte are selected in dark gray and black outlines respectively, where the delete operations are performed.

## Video demonstration
[Link to video](https://drive.google.com/file/d/1hnv5lTrq2gvsLQFgZUzYbbBeXMrtWiQ0/view?usp=sharing)

## Limitations
- CRC and LRC are only calculated on one byte, this should be selectable.
- CRC8 isn't implemented since I don't have an intuitive way to input a polynome for the the operation.
- The GUI looks bad... I'm not a graphic designer, at all, though.

## Next Steps
- add customizable top labels so it's more intuitive
- redo the GUI to make text more readable
- properly implement CRC and LRC
