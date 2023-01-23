# Techage/Beduino Functions



## I/O Module

The I/O module supports the following functions:

### send_cmnd

Send a command to a techage block (see [commands](https://github.com/joe7575/beduino/blob/main/BEPs/bep-005_ta_cmnd.md)).

- *port* is the I/O module port number

- *topic* is a number from the list of [Beduino commands](https://github.com/joe7575/beduino/blob/main/BEPs/bep-005_ta_cmnd.md)

- *payload* is an array or a string with additional information, depending on the command. If no additional commands are required, "" can be used.

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

Request information from a techage block (see [commands](https://github.com/joe7575/beduino/blob/main/BEPs/bep-005_ta_cmnd.md)).

- *port* is the I/O module port number
- *topic* is a number from the list of [Beduino commands](https://github.com/joe7575/beduino/blob/main/BEPs/bep-005_ta_cmnd.md)
- *payload* is an array or a string with additional information, depending on the command. If no additional commands are required, "" can be used.
- *resp* is an array for the response data. The array must be defined large enough to hold the response data.

```c
request_data(port, topic, payload, resp)
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
