# Beduino

Beduino is a 16-bit micro-controller system inspired by Arduino boards and kits. It can be programmed in the C like programming language [Cipol](https://github.com/joe7575/vm16/wiki/Cipol-Language-Reference).

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



## Standard Library

see [Cipol Language Reference](https://github.com/joe7575/vm16/wiki/Cipol-Language-Reference)



## Further Information

- [Cipol Language Reference](https://github.com/joe7575/vm16/wiki/Cipol-Language-Reference)
- [VM16 Instruction Set](https://github.com/joe7575/vm16/blob/master/doc/introduction.md)

- [Assembler Manual](https://github.com/joe7575/vm16/blob/master/doc/asm.md)

