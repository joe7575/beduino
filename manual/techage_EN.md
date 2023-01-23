# Beduino for Techage

Beduino is a 16-bit microcontroller system inspired by Arduino boards and kits.
Beduino can be programmed in the C-like programming language mC.
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
- A base port number must be entered for the I/O module
- Place the server anywhere
- Pair the programmer with the server and controller by clicking on both blocks with the programmer
- Last place the programmer in front of the controller (in reality the programmer can be placed anywhere since 
  it is already connected to the controller by pairing)

## I/O Module

The main purpose of an I/O module is to convert Techage block numbers to Beduino port numbers and vice versa.
This is necessary as Beduino numbers only have a limited range from 0 to 65535 and Techage block numbers
can be much larger.

Each I/O module requires its own base port number. Derived from the base port number, each I/O module
has 8 ports to the techage blocks. 

Up to 8 I/O modules can be used per controller. 

In order to establish a connection from a Techage Block to the I/O Module, the Techage Block number must
be entered in the I/O Module menu. If the Techage Block number is entered correctly, the block name
is displayed under Description.

To communicate with techage blocks, the I/O module supports the following commands:

```c
// Send a command to a techage block
send_cmnd(port, topic, payload);

// Read data from a techage block
request_data(port, topic, payload, resp);
```

See [Beduino commands](https://github.com/joe7575/beduino/blob/main/BEPs/bep-005_ta_cmnd.md) for details.

## Input Module

Input modules are only used to receive commands from other techage blocks (switches, detectors, etc.).

Each input module requires its own base port number. Derived from the base port number
each input module again 8 ports to the techage blocks.

The ports are necessary to convert Techage block numbers to Beduino port numbers.
This is necessary because Beduino numbers only have a limited range from 0 to 65535
and Techage block numbers can be much larger.

In addition, when a command is received, an event with the port number is sent to the CPU.

This makes it very easy for the controller to query whether commands have been received:


```c
port = get_next_inp_port();  // Read next port number
if(port != 0xffff) {
    val = input(port);       // Read input value
    ...
}
```

The controller saves up to 8 events from up to 16 input modules, each with up to 8 occupied ports.
