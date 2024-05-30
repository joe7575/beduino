# Techage/Beduino Functions



## I/O Module

The I/O module supports the following functions:

### send_cmnd

Send a command to a techage block via the I/O module (see [commands](https://github.com/joe7575/beduino/blob/main/BEPs/bep-005_ta_cmnd.md)).

- *port* is the I/O module port number
- *topic* specifies the data to be sent and is a numeric value.
- *payload* is used for additional data. 
If not needed, you can provide an empty string (`""`).
  - *topic* < 64: *payload* is an array

  - *topic* >= 64:  *payload* is a string

```c
send_cmnd(port, topic, payload)
```

`send_cmnd` returns:

- `0` if successful
- `1` if destination is unknown
- `2` if *topic* or *payload*  is unknown or invalid
- `3` if command failed for other reasons



### request_data

Request information from a techage block.
The response is return by reference in form of an array or string.
See [commands](https://github.com/joe7575/beduino/blob/main/BEPs/bep-005_ta_cmnd.md).

- *port* is the I/O module port number
- *topic* specifies the data to be read and is a numeric value.
- *payload* is an array and is used for additional data.
  If not needed, you can provide `NULL`.
- *response* is an array for the response data.
  The array must be defined large enough to hold the response data.

```c
request_data(port, topic, payload, response)
```

`request_data` returns:

- `0` if successful
- `1` if destination is unknown
- `2` if *topic* or *payload*  is unknown or invalid
- `3` if command failed for other reasons



## Input Module

The Input module supports the following functions:

###  get_next_inp_port

Read the port number of the input module that received a command. 
Each command sent to an input module triggers an event on the controller and
provides the port number of the received command.

```c
get_next_inp_port()
```

The function returns a port number or `0xffff` if there is no pending event.

### input

Read an input value from the given port.

- *port* is the Input Module port number

```c
input(port)
```

The function returns the received value.



## TA4 Display and TA4 Display XL

###  clear_screen

Clear the display.

- *port* is the I/O module port number

```c
clear_screen(port)
```

### append_line

Add a new line to the display.
- *port* is the I/O module port number
- *text* is the text for one line

```c
append_line(port, text)
```


### write_line

Overwrite a text line with the given string.

- *port* is the I/O module port number
- *row* ist the display line/row (1-5)
- *text* is the text for one line

```c
write_line(port, row, text)
```



## Some basic Examples

The following examples require ine I/O Module connected to the Beduino controller.

> **Note**
>
> Octal strings can be used as alternative to an array: `"\001\002"` corresponds to `{1, 2}`

#### Signal Tower

Signal tower on port #1:

```c
import "lib/techage.c"

func init() {
}

func loop() {
  send_cmnd(1, 2, "\000");  // off
  sleep(5);                 // sleep 5 cycles
  send_cmnd(1, 2, "\001");  // green
  sleep(5);
  send_cmnd(1, 2, "\002");  // amber
  sleep(5);
  send_cmnd(1, 2, "\003");  // red
  sleep(5);
}
```



#### Sound Block

Example to play a sound with Sound Block on port #0:

```c
import "sys/stdlib.asm"
import "lib/techage.c"

const CMD_SOUND_BLOCK = 14;
const CMD_START_STOP = 1;

var sound[] = {2, 36};
var volume[] = {1, 5};
var start[] = {1};

func init() {
  send_cmnd(0, CMD_SOUND_BLOCK, sound);
  send_cmnd(0, CMD_SOUND_BLOCK, volume);
  send_cmnd(0, CMD_START_STOP,  start);
}

func loop() {
  halt();
}
```



The same example in compact form (based on octal strings):

```c
import "sys/stdlib.asm"
import "lib/techage.c"

func init() {
  send_cmnd(0, 14, "\002\044"); // select sound file
  send_cmnd(0, 14, "\001\005"); // set volume
  send_cmnd(0, 1,  "\001");     // play sound
}

func loop() {
  halt();
}
```



#### Machine State

 Example to read the machine state on port #2:

```c
import "sys/stdio.asm"
import "lib/techage.c"

func init() {
  setstdout(1);  // use terminal windows for stdout
}

func loop() {
  var resp;
  var sts;

  sts = request_data(2, 129, 0, &resp);
  if(sts == 0) {
    putnum(resp);
  } else{
    putstr("err ");
    putnum(sts);
  }
  putstr("\n");
  sleep(5);
}
```


