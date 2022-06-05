| Author     | Version | Status   | Modified    |
| ---------- | ------- | -------- | ----------- |
| J.Stolberg | 0.2     | Proposal | 30 May 2022 |



# BEP 005: Techage Commands

### Send Command / Trigger Action

```c
sts = send_cmnd(port, topic, payload);
```

The function `send_cmnd` sends a command to the node specified by *port* .

- *port* is the I/O module port number
- *topic* specifies the command. *topic* is a numeric value.
- *payload* is used for additional data. If not needed, you can provide an empty string (`""`).
  - *topic* < 64: *payload* is an array
  - *topic* >= 64:  *payload* is a string

`send_cmnd` returns:

- `0` if successful
- `1` if destination is unknown
- `2` if *topic* or *payload*  is unknown or invalid
- `3` if command failed for other reasons



| Command              | Topic (num) | Payload (array/string) | Remarks                                                      |
| -------------------- | ----------- | ---------------------- | ------------------------------------------------------------ |
| Turn on/off          | 1           | [num]                  | Turn block (lamp, machine, ...) on/off<br />*num* is the state: 0 = "off", 1 = "on" |
| Signal Tower         | 2           | [num]                  | Set Signal Tower color<br />*num* is the color: 0 = "off", 1 = "green", 2 = "amber", 3 = "red" |
| Signal Lamp          | 3           | [idx, num]             | Set the lamp color for "TA4 2x" and "TA4 4x" Signal Lamps<br />*idx* is the lamp number (1..4)<br />*num* is the color: 0 = "off", 1 = "green", 2 = "amber", 3 = "red" |
| Distri. Filter Slot  | 4           | [idx, num]             | Enable/disable a Distributor filter slot.<br />*idx* is the slot number: 1 = "red", 2 = "green", 3 = "blue", 4 = "yellow"<br />*num* is the state: 0 = "off", 1 = "on" |
| Detector Block Reset | 6           | -                      | Reset the item counter of the TA4 Item Detector block        |
| Exchange Block       | 9           | [idx]                  | Place/remove/exchange an block by means of the TA3 Door Controller II (techage:ta3_doorcontroller2)<br />*idx* is the inventory slot number (1..n) |
| Autocrafter          | 10          | [num1, num2, idx]      | Set the TA4 Autocrafter recipe with a recipe from a TA4 Recipe Block.<br/>*num1/num2* is the TA4 Recipe Block number (num1 * 65536 + num2)<br/>*idx* is the number of the recipe in the TA4 Recipe Block |
| Move Contr. 1        | 11          | [1]                    | TA4 Move Controller command to move the block(s) from position A to B |
| Move Contr. 2        | 11          | [2]                    | TA4 Move Controller command to move the block(s) from position B to A |
| Move Contr. 3        | 11          | [3]                    | TA4 Move Controller command to move the block(s) to the opposite position |
| Turn Contr. 1        | 12          | [1]                    | TA4 Turn Controller command to turn the block(s) to the left |
| Turn Contr. 2        | 12          | [2]                    | TA4 Turn Controller command to turn the block(s) to the right |
| Turn Contr. 3        | 12          | [3]                    | TA4 Turn Controller command to turn the block(s) 180 degrees |
| Sequenzer 1          | 13          | [slot]                 | Start command for the TA4 Sequencer. <br />*slot* is the time slot (1..n) where the execution starts. |
| Sequenzer 2          | 13          | [0]                    | Stop command for the TA4 Sequencer.                          |
| Sound 1              | 14          | [1, volume]            | Set volume of the sound block<br />*volume* is a value from 1 to 5 |
| Sound 2              | 14          | [2, index]             | Select sound sample of the sound block<br />*index* is the sound sample number |
| Display Clear        | 17          | -                      | Clear the display                                            |
| Display Add Line     | 67          | "text string"          | Add a new line to the display                                |
| Display Write Line   | 68          | "<num>text string"     | Overwrite a text line with the given string. <br />The first string character is the line number (1..5)<br />Examples: "1Hello World", "2Minetest" |
| Start TA4 Pusher     | 64          | "<item name>"          | Start the TA4 pusher to pull/push items.<br />Example: `default:dirt 8` |
| Config TA4 Pusher    | 65          | "<item name>"          | Configure the TA4 pusher.<br/>Example: `wool:blue`           |
| Sensor Chest Text    | 66          | "text string"          | Text to be used for the Sensor Chest menu                    |



### Request Data

```c
sts = request_data(port, topic, payload, response);
```

The function `request_data` request a response from a node specified by *port*. The response is return by reference in form of an array or string.

- *port* is the I/O module port number

- *topic* specifies the data to be read. *Topic* is a numeric value.
- *payload* is an array and is used for additional data. If not needed, you can provide `NULL`.
- *response* is a buffer for the result. It is returned as array or as string (see table below).

`request_data` returns:

- `0` if successful
- `1` if destination is unknown
- `2` if *topic* or *payload*  is unknown or invalid
- `3` if command failed for other reasons

| Command                    | Topic (num) | Payload (array/string) | Response (array/string) | Remarks to the response                                      |
| -------------------------- | ----------- | ---------------------- | ----------------------- | ------------------------------------------------------------ |
| Identify                   | 128         | -                      | "\<node name>"          | Node name as string like "default:dirt"                      |
| State for Techage Machines | 129         | -                      | [num]                   | RUNNING = 1, BLOCKED = 2,<br /> STANDBY = 3, NOPOWER = 4,<br />FAULT = 5, STOPPED = 6,<br />UNLOADED = 7, INACTIVE = 8 |
| Signal Tower Color         | 130         | -                      | [num]                   | OFF = 0, GREEN = 1, AMBER = 2, RED = 3                       |
| Chest State                | 131         | -                      | [num]                   | State of a TA3/TA4 chest or Sensor Chest<br />EMPTY = 0, LOADED = 1, FULL = 2 |
| Fuel Level                 | 132         | -                      | [num]                   | Fuel level of a fuel consuming block (0..65535)              |
| Quarry Depth               | 133         | -                      | [num]                   | Current depth value of a quarry block (1..80)                |
| Load Percent               | 134         | [1]                    | [num]                   | Load value in percent  (0..100) of a tank, silo, accu, fuelcell, or battery block. |
| Load Absolute              | 134         | [2]                    | [num]                   | Absolute value in units for silos and tanks                  |
| Delivered Power            | 135         | -                      | [num]                   | Current providing power value of a generator block           |
| Accu Power                 | 136         | -                      | [providing, charging]   | Current providing/charging power value of an accu block<br />(byte 0: providing, byte 1: charging) |
| Total Flow Rate            | 137         | -                      | [num]                   | Total flow rate in liquid units for TA4 Pumps (0..65535)     |
| Sensor Chests State 1      | 138         | [1]                    | [num]                   | Last action: NONE = 0 PUT = 1, TAKE = 2                      |
| Sensor Chests State 2      | 138         | [2]                    | "\<player name>"        | Player name of last action                                   |
| Sensor Chests State 3      | 138         | [3, idx]               | "\<node name>"          | Inventory Stack node name, or "none". <br />*idx* is the inventory stack number (1..n) |
| Sensor Chests State 4      | 138         | [4, idx]               | [num]                   | Number of inventory stack items (0..n)<br />*idx* is the inventory stack number (1..n) |
| Item Counter               | 139         |                        | [num]                   | Item counter of the TA4 Item Detector block (0..n)           |
| Inventory Item Count       | 140         | [1, idx]               | [num]                   | Amount of TA4 8x2000 Chest items<br />*idx* is the inventory slot number <br />(1..8 from left to right, or 0 for the total number) |
| Inventory Item Name        | 140         | [2, idx]               | "\<node name>"          | Name of TA4 8x2000 Chest items<br />*idx* is the inventory slot number <br />(1..8 from left to right) |
| Furnace Output             | 141         | -                      | "\<node name>"          | Node name of the Industrial Furnace output. <br />Returns "none", if no recipe is active |
|                            |             |                        |                         |                                                              |



### Examples

> **Note**
>
> Octal strings can be used as alternative to an array: `"\001\002"` corresponds to `{1, 2}`

#### Signal Tower

Signal tower on port #1:

```c
import "ta_iom.c"

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
import "ta_iom.c"
import "stdlib.asm"

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
import "ta_iom.c"
import "stdlib.asm"

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
import "ta_iom.c"
import "stdio.asm"
import "stdlib.asm"

var response[1];

func init() {
  var sts;

  sts = request_data(2, 129, 0, response);
  if(sts) {
    putnum(response[0]);
  } else{
    putstr("err");
  }
}

func loop() {
  halt();
}
```

