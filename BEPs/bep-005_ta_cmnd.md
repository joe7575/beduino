| Author     | Version | Status   | Modified    |
| ---------- | ------- | -------- | ----------- |
| J.Stolberg | 0.5     | Proposal | 16 Jan 2023 |



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



| Command                  | Topic (num) | Payload (array/string) | Remarks                                                      |
| ------------------------ | ----------- | ---------------------- | ------------------------------------------------------------ |
| Turn on/off              | 1           | [num]                  | Turn block (lamp, machine, ...) on/off<br />*num* is the state: 0 = "off", 1 = "on" |
| Signal Tower             | 2           | [num]                  | Set Signal Tower color<br />*num* is the color: 0 = "off", 1 = "green", 2 = "amber", 3 = "red" |
| Signal Lamp              | 3           | [idx, num]             | Set the lamp color for "TA4 2x" and "TA4 4x" Signal Lamps<br />*idx* is the lamp number (1..4)<br />*num* is the color: 0 = "off", 1 = "green", 2 = "amber", 3 = "red" |
| Distri. Filter Slot      | 4           | [idx, num]             | Enable/disable a Distributor filter slot.<br />*idx* is the slot number: 1 = "red", 2 = "green", 3 = "blue", 4 = "yellow"<br />*num* is the state: 0 = "off", 1 = "on" |
| Detector Block Countdown | 5           | [num]                  | Set countdown counter of the TA4 Item Detector block to the given value and<br />start countdown mode. |
| Detector Block Reset     | 6           | -                      | Reset the item counter of the TA4 Item Detector block        |
| TA3 Sequenzer            | 7           | [num]                  | Turn the TA3 Sequencer on/off<br />*num* is the state: 0 = "off", 1 = "on", 2 = "pause" |
| DC2 Exchange Block       | 9           | [0, idx]               | TA3 Door Controller II (techage:ta3_doorcontroller2)<br />Exchange a block<br />*idx* is the inventory slot number (1..n) of/for the block to be exchanged |
| DC2 Set Block            | 9           | [1, idx]               | TA3 Door Controller II (techage:ta3_doorcontroller2)<br />Set/add a block<br />*idx* is the inventory slot number (1..n) with the block to be set |
| DC2 Dig Block            | 9           | [2, idx]               | TA3 Door Controller II (techage:ta3_doorcontroller2)<br />Dig/remove a block<br />*idx* is the empty inventory slot number (1..n) for the block |
| Autocrafter              | 10          | [num1, num2, idx]      | Set the TA4 Autocrafter recipe with a recipe from a TA4 Recipe Block.<br/>*num1/num2* is the TA4 Recipe Block number (num1 * 65536 + num2)<br/>*idx* is the number of the recipe in the TA4 Recipe Block |
| Move Contr. 1            | 11          | [1]                    | TA4 Move Controller command to move the block(s) from position A to B |
| Move Contr. 2            | 11          | [2]                    | TA4 Move Controller command to move the block(s) from position B to A |
| Move Contr. 3            | 11          | [3]                    | TA4 Move Controller command to move the block(s) to the opposite position |
| MC move xyz              | 18          | [x, y, z]              | TA4 Move Controller command to move the block(s) by the given<br /> x/y/z-distance. Valid ranges for x, y, and z are -100 to 100. <br />(Note: `65536 - 100 = 65425` with corresponds to `-100`) |
| MC reset                 | 19          | -                      | Reset TA4 Move Controller (move block(s) to start position)  |
| Turn Contr. 1            | 12          | [1]                    | TA4 Turn Controller command to turn the block(s) to the left |
| Turn Contr. 2            | 12          | [2]                    | TA4 Turn Controller command to turn the block(s) to the right |
| Turn Contr. 3            | 12          | [3]                    | TA4 Turn Controller command to turn the block(s) 180 degrees |
| TA4 Sequenzer 1          | 13          | [slot]                 | Start/goto command for the TA4 Sequencer. <br />*slot* is the time slot (1..n) where the execution starts. |
| TA4 Sequenzer 2          | 13          | [0]                    | Stop command for the TA4 Sequencer.                          |
| Sound 1                  | 14          | [1, volume]            | Set volume of the sound block<br />*volume* is a value from 1 to 5 |
| Sound 2                  | 14          | [2, index]             | Select sound sample of the sound block<br />*index* is the sound sample number |
| [PDP-13] 7-Segment       | 15          | [num]                  | Ouput value (0-15) to the 7-segment block (values > 15 will turn off the block) |
| [PDP-13] 14-Segment      | 16          | [num]                  | Ouput value (0-0x3FFF) to the 14-segment block<br />See: [PDP-13 Manual](https://github.com/joe7575/pdp13/blob/main/manuals/manualXL_EN.md#pdp-13-14-segment) |
| Display Clear            | 17          | -                      | Clear the display                                            |
| TA4 Pusher Limit         | 20          | [limit]                | Configure a TA4 Pusher with the number of items that are allowed to be pushed ("flow limiter" mode)<br />limit = 0 turns off the "flow limiter" mode |
| TA4 Pump Limit           | 21          | [limit]                | Configure a TA4 Pump with the number of liquid units that are allowed to be pumped ("flow limiter" mode)<br />limit = 0 turns off the "flow limiter" mode |
| Color                    | 22          | [color]                | Set the color of the TechAge Color Lamp and TechAge Color Lamp 2 (color = 0..255) |
|                          |             |                        |                                                              |
|                          |             |                        |                                                              |
| **=============**        | **====**    | **========**           | **For Topics >=64 the payload is a string**                  |
|                          | 64          |                        |                                                              |
|                          | 65          |                        |                                                              |
|                          | 66          |                        |                                                              |
| Display Add Line         | 67          | "text string"          | Add a new line to the display                                |
| Display Write Line       | 68          | "\<num>text string"    | Overwrite a text line with the given string. <br />The first string character is the line number (1..5)<br />Examples: "1Hello World", "2Minetest" |
| Config TA4 Pusher        | 65          | "\<item name>"         | Configure the TA4 pusher.<br/>Example: `wool:blue`           |
| Sensor Chest Text        | 66          | "text string"          | Text to be used for the Sensor Chest menu                    |
| Distri. Filter Config    | 67          | "\<slot> \<item list>" | Configure a Distributor filter slot, like: "red default:dirt dye:blue" |
|                          |             |                        |                                                              |
|                          |             |                        |                                                              |
|                          |             |                        |                                                              |



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
| TA4 Button State           | 131         | -                      | [num]                   | OFF = 0, ON = 1                                              |
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
| Binary State               | 142         | -                      | [num]                   | Current block state: OFF = 0, ON = 1                         |
| Light Level                | 143         | -                      | [num]                   | Light level value between 0  and 15 (15 is high)             |
| Player Name                | 144         | -                      | "\<player name>"        | Player name of the TA3/TA4 Player Detector or TA4 Button     |
| Solar Cell State           | 145         | -                      | [num]                   | 0 = UNUSED, 1 = CHARGING, 2 = UNCHARGING                     |
| Consumption                | 146         | -                      | [num]                   | TA4 Electric Meter total power consumption                   |
| DC2 Block Name             | 147         | [idx]                  | "\<node name>"          | Name of the placed block<br />*idx* is the inventory slot number (1..n) of the related the block position |
| Distri. Filter Get         | 148         | "\<slot>"              | "\<item list>"          | *idx* is the slot number: <br />1 = "red", 2 = "green", 3 = "blue", 4 = "yellow"<br />Return a string like: "default:dirt dye:blue" |
| Time Stamp                 | 149         | -                      | [time]                  | Time in system ticks (norm. 100 ms) when the TA4 Button is clicked |
| TA4 Pusher Counter         | 150         | -                      | [num]                   | Read the number of pushed items for a TA4 Pusher in "flow limiter" mode |
| TA4 Pump Counter           | 151         | -                      | [num]                   | Read the number of pumped liquid units for a TA4 Pump in "flow limiter" mode |



### Nodes and Commands

| Technical Node Name | Supported Commands |
| ------------------- | ------------------ |
| techage:chest_cart | 131 |
| techage:chest_ta2 | 131 |
| techage:chest_ta3 | 131 |
| techage:chest_ta4 | 131 |
| techage:coalfirebox | 128, 129, 132 |
| techage:furnace_firebox | 128, 129, 132 |
| techage:generator | 1, 128, 129, 135 |
| techage:heatexchanger2 | 1, 128, 129, 134, 135 |
| techage:oilfirebox | 128, 129, 132 |
| techage:powerswitch, techage:powerswitchsmall | 1, 142 |
| techage:color_lamp_off, techage:color_lamp2_off | 1, 70 |
| techage:t4_pump | 1, 128, 129, 137 |
| techage:t4_waterpump | 1, 128, 129 |
| techage:ta3_akku | 1, 128, 129, 134 |
| techage:ta3_cartdetector_off | 1, 142 |
| techage:ta3_cartdetector_off | 142 |
| techage:ta3_distributor_pas | 1, 4, 67, 128, 129,148 |
| techage:ta3_doorcontroller | 1 |
| techage:ta3_doorcontroller2 | 1, 9, 147 |
| techage:ta3_drillbox_pas | 1, 128, 129 |
| techage:ta3_electronic_fab_pas | 1, 128, 129 |
| techage:ta3_furnace_pas | 1, 128, 129, 141 |
| techage:ta3_grinder_pas | 1, 128, 129 |
| techage:ta3_injector_pas | 1, 128, 129 |
| techage:ta3_lightdetector_off | 142, 143 |
| techage:ta3_liquidsampler_pas | 1, 128, 129 |
| techage:ta3_logic | 1 |
| techage:ta3_logic2 | 1 |
| techage:ta3_nodedetector_off | 142 |
| techage:ta3_playerdetector_off | 142, 144 |
| techage:ta3_pusher_pas | 1, 64, 65 |
| techage:ta3_quarry_pas | 1, 128, 129, 133 |
| techage:ta3_recycler_pas | 1, 128, 129 |
| techage:ta3_rinser_pas | 1, 128, 129 |
| techage:ta3_sequencer | 7 |
| techage:ta3_sieve_pas | 1, 128, 129 |
| techage:ta3_silo | 129, 134 |
| techage:ta3_soundblock | 1, 14 |
| techage:ta3_valve_open | 1, 142 |
| techage:ta4_battery | 134 |
| techage:ta4_button_off | 144, 149 |
| techage:ta4_chest | 131, 140 |
| techage:ta4_collector | 129 |
| techage:ta4_detector_off | 6, 139 |
| techage:ta4_display | 17, 67, 68 |
| techage:ta4_displayXL | 17, 67, 68 |
| techage:ta4_distributor_pas | 1, 4, 67, 128, 129, 148 |
| techage:ta4_doser | 1, 128, 129 |
| techage:ta4_electricmeter | 1, 128, 129, 146 |
| techage:ta4_electrolyzer | 1, 128, 129, 134, 135 |
| techage:ta4_electronic_fab_pas | 1, 128, 129 |
| techage:ta4_fuelcell | 1, 128, 129, 134, 135 |
| techage:ta4_grinder_pas | 1, 128, 129 |
| techage:ta4_icta_controller | 1, 129 |
| techage:ta4_injector_pas | 1, 128, 129 |
| techage:ta4_laser_emitter | 142 |
| techage:ta4_liquidsampler_pas | 1, 128, 129 |
| techage:ta4_lua_controller | 1, 142 |
| techage:ta4_mbadetector | 142 |
| techage:ta4_movecontroller | 11, 18, 19, 129 |
| techage:ta4_playerdetector_off | 142, 144 |
| techage:ta4_pumpjack_pas | 134 |
| techage:ta4_pusher_pas | 1, 64, 65 |
| techage:ta4_quarry_pas | 1, 128, 129, 133 |
| techage:ta4_recycler_pas | 1, 128, 129 |
| techage:ta4_rinser_pas | 1, 128, 129 |
| techage:ta4_sensor_chest | 66, 131, 138 |
| techage:ta4_sequencer | 13 |
| techage:ta4_sieve_pas | 1, 128, 129 |
| techage:ta4_signallamp_2x | 3 |
| techage:ta4_signallamp_4x | 3 |
| techage:ta4_signaltower | 2, 13 |
| techage:ta4_signaltower | 2, 130 |
| techage:ta4_silo | 131, 134 |
| techage:ta4_solar_inverter | 1, 128, 129, 135 |
| techage:ta4_solar_minicell | 145 |
| techage:ta4_transformer | 1, 128, 129 |
| techage:ta4_turncontroller | 12 |
| techage:ta4_wind_turbine | 1, 129, 135 |
| techage:ta5_flycontroller | 11, 129 |
| techage:ta5_flycontroller | 129 |
| techage:ta5_fr_controller_pas | 1, 128, 129 |
| techage:ta5_heatexchanger2 | 1, 128, 129, 135 |
| techage:ta5_hl_chest | 131 |
| techage:ta5_pump | 1, 128, 129 |
| techage:ta5_tele_pipe | 1, 128, 129 |
| techage:ta5_tele_tube | 1, 128, 129 |
| techage:tiny_generator | 1, 128, 129, 132, 135 |
| pdp13:14segment | 16 |
| pdp13:7segment | 15 |



### Examples

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
import "sys/stdlib.asm"
import "lib/techage.c"

var response[1];

func init() {
  var sts;

  setstdout(1);  // use terminal windows for stdout

  sts = request_data(2, 129, 0, response);
  if(sts == 0) {
    putnum(response[0]);
  } else{
    putstr("err ");
    putnum(sts);
  }
  putstr("\n");
}

func loop() {
  halt();
}
```

