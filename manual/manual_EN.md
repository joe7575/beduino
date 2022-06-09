# Beduino

Beduino is a 16-bit micro-controller system inspired by Arduino boards and kits. It can be programmed in a C like programming language [Cipol](https://github.com/joe7575/vm16/wiki/Cipol-Language-Reference).

To be able to use Beduino, a basic knowledge of programming languages would be useful.

The mod `beduino` is based on the mod [vm16](https://github.com/joe7575/vm16), which provides the development environment with editor, file system, compiler, assembler, and debugger.

Apart from vm16, `beduino` has no other mod dependencies. But to be useful, other technology oriented mods or games are necessary.

This manual describes the standard functionality that applies to all use cases. Mod/game specific features/extensions are not covered here.



## Technical Data

The mod `beduino`  uses the virtual machine from `vm16`. The performance default values for the CPU are:

- call cycle_time = 200 ms
- instructions per cycle = 10000
- input costs in number of instructions = 1000
- output costs in number of instructions = 5000
- system costs in number of instructions = 2000
- memory size in words = 2048

The means that the CPU can execute up to 100,000 instructions per second, but e.g. each call of the function `output` costs 5000 instructions (max. 20 `output`calls per second). 

Beduino CPU registers are 16-bit wide. The CPU memory is also organized in 16-bit words. 8-bit addressing is not supported. This means, all variables are 16-bit wide and can store values between 0 and 65535. For more info to the CPU, see [VM16 Instruction Set](https://github.com/joe7575/vm16/blob/master/doc/introduction.md).	



## First Steps

- Craft the three blocks "VM16 Programmer", "VM16 File Server", "Beduino Controller".
- Place the server and the controller.
- Left-click with the programmer on both blocks to connect the programmer with server and controller.
- Place the programmer in front of the controller (in reality, the programmer can be placed anywhere since it is already connected).
- Open the programmer menu and press the "Init" button. This will initialize the controller and connect any existing I/O module to the controller.
- Open the file "example1.c" with a double-click on the file name. 
- Translate the example into machine language with the button "Debug" and start the program with "Run". The program will send some ASCII characters to the programmers terminal. If the terminal window is not open, the text will be placed on the status line of the programmer.

If you see characters like "@ABCDEFG..." then you did everything right, congratulations!



## Hello World

The "Hello world" program is probably the most famous program. In the Beduino programming language, it looks like this:

```c
import "stdio.asm"
import "stdlib.asm"

func init() {
  putstr("Hello world!");
}

func loop() {
  halt(); // abort program execution
}
```

- `import` instructions allow to use external functions and variables (here: `putstr` and `halt`)
- the function `init`  is called only once and is typically used for initializing purposes. We use this to output the text string "Hello world!"
- the  function `loop` is cyclically called, typically every 200 ms. If you code is to huge and needs more time, the next call of `loop` will be delayed. Because the program is about to end, the function `halt`  is used. Without the `halt` function the program will run endless.

To test this program:

- Generate a new file "test.c" by typing the file name into the text field in the button row and click on the button "New".
- Open the new generated file with a double-click on the file name.
- Copy the text from this manual into the editor window.
- Start the program with the buttons "Debug" and "Run"

**Hints:**

- Program source files have to have the ending ".c". Files with other endings can be generated, but can't be translated/compiled.
- To delete a file, open the file with the editor, delete the text, and save the file again.
- The "ro" behind the file names means "read-only". "read-only" files can't be changed or deleted. They are used for examples and for standard library functions and definitions.



## Debugger

tbd.



## Router

Routers are used to send messages from one to another controller. Each controller needs its own router. Each router automatically gets an unique number/address, which is used for the addressing. The 16 bit address allows up to 65535 router.

```c
// Send a message via router.
// `address` is the router destination address
func send_msg(address, msg);

// Receive a message via router.
// Function returns the sender address or 0.
func recv_msg(buff, size);
```

The maximum messages length is 64 words. 

> **Note**
> Word 0 of each messages buffer is the msg size, which is the number of words without the size itself (see example `tx_demo.c`).

The router comes with two example programs to demonstrate the message communication:

- `tx_demo.c`  to cyclically send a message to router #2
- `rx_demo.c` to receive and output messages

Copy the code from `tx_demo.c` into your own file and adapt the router address to your needs.

#### Address Filter

Router allow to set an address filter. By default, messages from all other controllers are received. By means of the address list (white list) the number of valid addresses can be limited. Enter the addresses of the allowed routers in the router menu. Addresses must be separated by spaces, e.g.: "123 234 235".



## Broker

The broker is used for a server/broker based communication between controllers. The broker will store received messages and provides the messages to other controllers, even if the original message source/sender is not available anymore.

Messages for the broker have to have a topic value. The topic is used to publish and request a dedicated messages.

Each broker automatically gets an unique number/address, which is used for the addressing.

```c
// Send a message to the broker.
// `address` is the router destination address
// `topic` value is used as message identifier
func publish_msg(address, topic, msg);
    
// Read a message from the broker.
// Function returns 1 (success) or 0 (no msg).
// `buff` is a buffer, used for the received message
// `size` ist the buffer size in words
func request_msg(address, topic, buff, size);
```

The maximum messages length is 64 words. Valid values for a topic are 1..100.

> **Note**
> Word 0 of each messages buffer is the msg size, which is the number of words without the size itself (see example pub_demo.c`).

The broker comes with two example programs to demonstrate the publish/request process:

- `pub_demo.c`  to cyclically publish/send a message to broker #5
- `req_demo.c` to request/receive a messages from broker #5

Copy the demo code into your own files and adapt the broker address to your needs.

#### Address Filter

Broker (like router) allow to set an address filter. By default, messages from all controllers are received. By means of the address list (white list) the number of valid addressed can be limited. Enter the addresses of the allowed publishing controllers in the broker menu. Addresses must be separated by spaces, e.g.: "123 234 235".

Only the receipt of messages can be restricted, requesting a message from the broker is always allowed (if the topic number is known).



## Further Information

- [Cipol Language Reference](https://github.com/joe7575/vm16/wiki/Cipol-Language-Reference)
- [VM16 Instruction Set](https://github.com/joe7575/vm16/blob/master/doc/introduction.md)
- [Assembler Manual](https://github.com/joe7575/vm16/blob/master/doc/asm.md)

