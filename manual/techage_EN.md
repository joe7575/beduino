# Beduino for Techage

Beduino is a 16-bit microcontroller system inspired by Arduino boards and kits.
Beduino can be programmed in the C-like programming language Cipol.
In order to be able to use Beduino, basic knowledge of
programming languages is an advantage.

Beduino is fully integrated into the Mod Techage and
can be used as an alternative to the Lua controller.

Further information about Beduino, the programming language and
the techage commands can be found here: https://github.com/joe7575/beduino/wiki

[beduino_controller|image]

## First Steps

- Craft the four blocks "VM16 Programmer", "VM16 File Server", "Beduino Controller" and "Beduino I/O Module"
- Place controller and I/O module next to or on top of each other (maximum distance is 3 blocks)
- A base address must be entered for the I/O module
- Place the server anywhere
- Pair the programmer with the server and controller by clicking on both blocks with the programmer
- Last place the programmer in front of the controller (in reality the programmer can be placed anywhere since it is already connected to the controller by pairing)

## I/O Module

Each I/O module requires its own base address. Derived from the base address,
each I/O module has 8 ports to the techage blocks. Up to 8 I/O modules 
can be used per controller. 
The techage block address must be entered for each port. 
If the addresses are entered correctly, the block name is displayed under Description.

The I/O block has a help menu that shows some techage commands 
that can be used directly, such as:

```c
val = input(2); // Read in a value from port #2
output(0, IO_ON); // Turn on a block on port #0
output(1, IO_GREEN); // Set signal tower on port #1 to green
sts = read(3, IO_STATE); // Reading a machine status
```

`input(port)` only reads the value from the port. 
To do this, for example, a switch must be connected to the I/O module
(enter both numbers mutually). 
`read(port, IO_STATE)`, on the other hand, requests the state from the machine.

Every signal that is sent to an I/O module triggers an event on the controller. 
Events can be queried using the `event()` function. 
If the function returns the value `1`, one or more signals have been received. 
Calling `event()` resets the event flag.

## Techage Commands

The following commands are used for more complex commands to control techage machines. 
For this, too, there must be a connection from the I/O module to the techage block, 
since a port is always required for addressing:

```c
send_cmnd(port, topic, payload);
request_data(port, topic, payload, resp);
```

- *port* is the I/O module port number
- *topic* is a number from the list of [Beduino commands](https://github.com/joe7575/beduino/blob/main/BEPs/bep-005_ta_cmnd.md)
- *payload* is an array or a string with additional information, depending on the command. If no additional commands are required, `""` can be used
- *resp* is an array for the response data. The array must be defined large enough to hold the response data

