| Author     | Version | Status   | Modified    |
| ---------- | ------- | -------- | ----------- |
| J.Stolberg | 0.1     | Proposal | 23 May 2022 |



# RFC 005: Techage Commands

### Write Data / Trigger Action

These commands do not return a any result.

- *Topic* specifies the command. *Topic* is a numeric value.
- *Payload* is an array and is used for additional data. If not needed, you can provide `NULL`.



| Command              | Topic (num) | Payload (array/string) | Remarks                                                      |
| -------------------- | ----------- | ---------------------- | ------------------------------------------------------------ |
| Turn on/off          | 1           | [num]                  | Turn block (lamp, machine, ...) on/off<br />*num* is the state: 0 = "off", 1 = "on" |
| Signal Tower         | 2           | [num]                  | Set Signal Tower color<br />*num* is the color: 0 = "off", 1 = "green", 2 = "amber", 3 = "red" |
| Signal Lamp          | 3           | [idx, num]             | Set the lamp color for "TA4 2x" and "TA4 4x" Signal Lamps<br />*idx* is the lamp number (1..4)<br />*num* is the color: 0 = "off", 1 = "green", 2 = "amber", 3 = "red" |
| Distri. Filter Slot  | 4           | [idx, num]             | Enable/disable a Distributor filter slot.<br />*idx* is the slot number: 1 = "red", 2 = "green", 3 = "blue", 4 = "yellow"<br />*num* is the state: 0 = "off", 1 = "on" |
| Sensor Chest Text    | 5           | "text string"          | Text to be used for the Sensor Chest menu                    |
| Detector Block Reset | 6           | -                      | Reset the item counter of the TA4 Item Detector block        |
| Start TA4 Pusher     | 7           | "<item name>"          | Start the TA4 pusher to pull/push items.<br />Example: `default:dirt 8` |
| Config TA4 Pusher    | 8           | "<item name>"          | Configure the TA4 pusher.<br/>Example: `wool:blue`           |
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
|                      |             |                        |                                                              |

### Read Data

These commands request a response in form of an array or string.

- *Topic* specifies the data to be read. *Topic* is a numeric value.
- *Payload* is an array and is used for additional data. If not needed, you can provide `NULL`.
- *Response* is the result is of type array or string (see table below).

| Command                    | Topic (num) | Payload (array/string) | Response (array/string) | Remarks to the response                                      |
| -------------------------- | ----------- | ---------------------- | ----------------------- | ------------------------------------------------------------ |
| Identify                   | 128         | -                      | "\<node name>"          | Node name as string like "default:dirt"                      |
| State for Techage Machines | 129         | -                      | [num]                   | RUNNING = 1, BLOCKED = 2,<br /> STANDBY = 3, NOPOWER = 4,<br />FAULT = 5, STOPPED = 6,<br />UNLOADED = 7 |
| Signal Tower Color         | 130         | -                      | [num]                   | OFF = 0, GREEN = 1, AMBER = 2, RED = 3                       |
| Chest State                | 131         | -                      | [num]                   | State of a TA3/TA4 chest or Sensor Chest<br />EMPTY = 0, LOADED = 1, FULL = 2 |
| Fuel Level                 | 132         | -                      | [num]                   | Fuel level of a fuel consuming block (0..65535)              |
| Quarry Depth               | 133         | -                      | [num]                   | Current depth value of a quarry block (1..80)                |
| Tank Load Percent          | 134         | [1]                    | [num]                   | Load value in percent  (0..100) of a tank, silo, accu, or battery block. |
| Tank Load Absolute         | 134         | [2]                    | [num]                   | Absolute value in units for silos and tanks                  |
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



