| Author     | Version | Status   | Modified    |
| ---------- | ------- | -------- | ----------- |
| J.Stolberg | 0.6     | Proposal | 24 Jan 2023 |
| J.Stolberg | 0.7     | Proposal | 16 Sep 2023 |
| J.Stolberg | 0.8     | Proposal | 31 May 2024 |



# BEP 005: Techage Commands

### Send Command / Trigger Action

See [Techage related functions](https://github.com/joe7575/beduino/blob/main/manual/techage.md).

| Command                    | Topic (num) | Payload (array/string) | Remarks                                                      |
| -------------------------- | ----------- | ---------------------- | ------------------------------------------------------------ |
| Turn on/off                | 1           | [num]                  | Turn block (lamp, machine, button...) on/off<br />*num* is the state: 0 = "off", 1 = "on" |
| Signal Tower               | 2           | [num]                  | Set Signal Tower color<br />*num* is the color: 0 = "off", 1 = "green", 2 = "amber", 3 = "red" |
| Traffic Light              | 2           | [num]                  | Set Traffic Light color<br />*num* is the color: 0 = "off", 1 = "green", 2 = "amber", 3 = "red" |
| Signal Lamp                | 3           | [idx, num]             | Set the lamp color for "TA4 2x" and "TA4 4x" Signal Lamps<br />*idx* is the lamp number (1..4)<br />*num* is the color: 0 = "off", 1 = "green", 2 = "amber", 3 = "red" |
| Distri. Filter Slot        | 4           | [idx, num]             | Enable/disable a Distributor filter slot.<br />*idx* is the slot number: 1 = "red", 2 = "green", 3 = "blue", 4 = "yellow"<br />*num* is the state: 0 = "off", 1 = "on" |
| Detector Block Countdown   | 5           | [num]                  | Set countdown counter of the TA4 Item Detector block to the given value and<br />start countdown mode. |
| Detector Block Reset       | 6           | -                      | Reset the item counter of the TA4 Item Detector block        |
| TA3 Sequenzer              | 7           | [num]                  | Turn the TA3 Sequencer on/off<br />*num* is the state: 0 = "off", 1 = "on", 2 = "pause" |
| DC2 Exchange Block         | 9           | [0, idx]               | TA3 Door Controller II (techage:ta3_doorcontroller2)<br />Exchange a block in the world with the block in the inventory.<br />*idx* is the inventory slot number (1..n) of/for the block to be exchanged |
| DC2 Reset                  | 9           | [3]                    | TA3 Door Controller II (techage:ta3_doorcontroller2). Using the reset command,<br />all blocks are reset to their initial state after learning. |
| DC2 Set to1                | 9           | [4, idx]               | TA3 Door Controller II (techage:ta3_doorcontroller2). Swaps a block in the inventory <br />with the block in the world, provided the position was in state 2 (Exchange state).<br/>`idx` is the inventory slot number (1..n) |
| DC2 Dig to2                | 9           | [5, idx]               | TA3 Door Controller II (techage:ta3_doorcontroller2). Swaps a block in the inventory <br />with the block in the world, provided the position was in state 1 (Initial state).<b<br />`idx` is the inventory slot number (1..n) |
| Autocrafter                | 10          | [num1, num2, idx]      | Set the TA4 Autocrafter recipe with a recipe from a TA4 Recipe Block.<br/>*num1/num2* is the TA4 Recipe Block number (num1 * 65536 + num2)<br/>*idx* is the number of the recipe in the TA4 Recipe Block |
| Autocrafter                | 11          | -                      | Move all items from input inventory to output inventory. Returns 1 if the input inventory was emptied in the process. Otherwise return 0 |
| Move Contr. 1              | 11          | [1]                    | TA4 Move Controller command to move the block(s) from position A to B |
| Move Contr. 2              | 11          | [2]                    | TA4 Move Controller command to move the block(s) from position B to A |
| Move Contr. 3              | 11          | [3]                    | TA4 Move Controller command to move the block(s) to the opposite position |
| Move Contr.<br /> move xyz | 18          | [x, y, z]              | TA4 Move Controller command to move the block(s) by the given<br /> x/y/z-distance. Valid ranges for x, y, and z are -100 to 100. <br />(Note: `65536 - 100 = 65425` with corresponds to `-100`) |
| Move Contr. `moveto`       | 24          | [x, y, z]              | TA4 Move Controller / TA4 Move Controller II  command to move the block(s) to the given<br /> absolute x/y/z-position. (Note: `-1000 = 65536 - 1000 = 64536`) |
| Move Contr. `reset`        | 19          | -                      | Reset TA4 Move Controller / TA4 Move Controller II  (move block(s) to start position) |
| Turn Contr. 1              | 12          | [1]                    | TA4 Turn Controller command to turn the block(s) to the left |
| Turn Contr. 2              | 12          | [2]                    | TA4 Turn Controller command to turn the block(s) to the right |
| Turn Contr. 3              | 12          | [3]                    | TA4 Turn Controller command to turn the block(s) 180 degrees |
| TA4 Sequenzer 1            | 13          | [slot]                 | Start/goto command for the TA4 Sequencer. <br />*slot* is the time slot (1..n) where the execution starts. |
| TA4 Sequenzer 2            | 13          | [0]                    | Stop command for the TA4 Sequencer.                          |
| Sound 1                    | 14          | [1, volume]            | Set volume of the sound block<br />*volume* is a value from 1 to 5 |
| Sound 2                    | 14          | [2, index]             | Select sound sample of the sound block<br />*index* is the sound sample number |
| [PDP-13] 7-Segment         | 15          | [num]                  | Ouput value (0-15) to the 7-segment block (values > 15 will turn off the block) |
| [PDP-13] 14-Segment        | 16          | [num]                  | Ouput value (0-0x3FFF) to the 14-segment block<br />See: [PDP-13 Manual](https://github.com/joe7575/pdp13/blob/main/manuals/manualXL_EN.md#pdp-13-14-segment) |
| Display Clear              | 17          | -                      | Clear the display                                            |
| TA4 Pusher Limit           | 20          | [limit]                | Configure a TA4 Pusher with the number of items that are allowed to be pushed ("flow limiter" mode)<br />limit = 0 turns off the "flow limiter" mode |
| TA4 Pump Limit             | 21          | [limit]                | Configure a TA4 Pump with the number of liquid units that are allowed to be pumped ("flow limiter" mode)<br />limit = 0 turns off the "flow limiter" mode |
| Color                      | 22          | [color]                | Set the color of the TechAge Color Lamp and TechAge Color Lamp 2 (color = 0..255) |
| Multi Button               | 23          | [num, state]           | Turn button (TA4 2x Button, TA4 4x Button) on/off<br />*num* is the button number (1..4), *state* is the state: 0 = "off", 1 = "on" |
| Move Contr. `moveto`       | 24          | [x, y, z]              | TA4 Move Controller command to move the block(s) to the given<br /> x/y/z-position. (Note: `-1000 = 65536 - 1000 = 64536`) |
|                            |             |                        |                                                              |
| **=============**          | **====**    | **========**           | **For Topics >=64 the payload is a string**                  |
|                            | 64          |                        |                                                              |
|                            | 65          |                        |                                                              |
|                            | 66          |                        |                                                              |
| Display Add Line           | 67          | "text string"          | Add a new line to the display                                |
| Display Write Line         | 68          | "\<num>text string"    | Overwrite a text line with the given string. <br />The first string character is the line number (1..5)<br />Examples: "1Hello World", "2Minetest" |
| Config TA4 Pusher          | 65          | "\<item name>"         | Configure the TA4 pusher.<br/>Example: `wool:blue`           |
| Sensor Chest Text          | 66          | "text string"          | Text to be used for the Sensor Chest menu                    |
| Distri. Filter Config      | 67          | "\<slot> \<item list>" | Configure a Distributor filter slot, like: "red default:dirt dye:blue" |
|                            |             |                        |                                                              |
|                            |             |                        |                                                              |
|                            |             |                        |                                                              |



### Request Data

See [Techage related functions](https://github.com/joe7575/beduino/blob/main/manual/techage.md).

| Command                    | Topic (num) | Payload (array/string) | Response (array/string) | Remarks to the response                                      |
| -------------------------- | ----------- | ---------------------- | ----------------------- | ------------------------------------------------------------ |
| Identify                   | 128         | -                      | "\<node name>"          | Node name as string like "techage:ta3_akku"                  |
| State for Techage Machines | 129         | -                      | [num]                   | RUNNING = 1, BLOCKED = 2,<br /> STANDBY = 3, NOPOWER = 4,<br />FAULT = 5, STOPPED = 6,<br />UNLOADED = 7, INACTIVE = 8 |
| Signal Tower Color         | 130         | -                      | [num]                   | OFF = 0, GREEN = 1, AMBER = 2, RED = 3                       |
| Traffic Light Color        | 130         | -                      | [num]                   | OFF = 0, GREEN = 1, AMBER = 2, RED = 3                       |
| Chest State                | 131         | -                      | [num]                   | State of a TA3/TA4 chest or Sensor Chest<br />EMPTY = 0, LOADED = 1, FULL = 2 |
| TA3/TA4 Button State       | 131         | -                      | [num]                   | OFF = 0, ON = 1                                              |
| Fuel Level                 | 132         | -                      | [num]                   | Fuel level of a fuel consuming block (0..65535)              |
| Quarry Depth               | 133         | -                      | [num]                   | Current depth value of a quarry block (1..80)                |
| Load Percent               | 134         | [1]                    | [num]                   | Load value in percent  (0..100) of a tank, silo, accu, fuelcell, or battery block. |
| Load Absolute              | 134         | [2]                    | [num]                   | Absolute value in units for silos and tanks                  |
| Storage Percent            | 134         | -                      | [num]                   | Read the grid storage amount (state of charge) in percent  (0..100) from a TA3 Power Terminal. |
| Consumer Current           | 135         | -                      | [num]                   | TA3 Power Terminal: Total power consumption (current) of all consumers |
| Delivered Power            | 135         | -                      | [num]                   | Current providing power value of a generator block           |
| Total Flow Rate            | 137         | -                      | [num]                   | Total flow rate in liquid units for TA4 Pumps (0..65535)     |
| Sensor Chests State 1      | 138         | [1]                    | [num]                   | Last action: NONE = 0 PUT = 1, TAKE = 2                      |
| Sensor Chests State 2      | 138         | [2]                    | "\<player name>"        | Player name of last action                                   |
| Sensor Chests State 3      | 138         | [3, idx]               | "\<node name>"          | Inventory Stack node name, or "none". <br />*idx* is the inventory stack number (1..n) |
| Sensor Chests State 4      | 138         | [4, idx]               | [num]                   | Number of inventory stack items (0..n)<br />*idx* is the inventory stack number (1..n) |
| Item Counter               | 139         |                        | [num]                   | Item counter of the TA4 Item Detector block (0..n)           |
| Inventory Item Count       | 140         | [1, idx]               | [num]                   | Amount of TA4 8x2000 Chest items<br />*idx* is the inventory slot number <br />(1..8 from left to right, or 0 for the total number) |
| Inventory Item Name        | 140         | [2, idx]               | "\<node name>"          | Name of TA4 8x2000 Chest items<br />*idx* is the inventory slot number <br />(1..8 from left to right) |
| Inventory Store Size       | 140         | [3]                    | [num]                   | Size of one of the eight stores of the TA4 8x2000 Chest.<br />Returns e.g. 6000 |
| Furnace Output             | 141         | -                      | "\<node name>"          | Node name of the Industrial Furnace output. <br />Returns "none", if no recipe is active |
| Binary State               | 142         | -                      | [num]                   | Current block state: OFF = 0, ON = 1                         |
| Light Level                | 143         | -                      | [num]                   | Light level value between 0  and 15 (15 is high)             |
| Player Name                | 144         | -                      | "\<player name>"        | Player name of the TA3/TA4 Player Detector or TA4 Button     |
| Solar Cell State           | 145         | -                      | [num]                   | 0 = UNUSED, 1 = CHARGING, 2 = UNCHARGING                     |
| Consumption                | 146         | [0]                    | [num]                   | TA4 Electric Meter: Amount of electrical energy passed through |
| Countdown                  | 146         | [1]                    | [num]                   | TA4 Electric Meter: Countdown value for the amount of electrical energy passed through |
| Current                    | 146         | [2]                    | [num]                   | TA4 Electric Meter: Current flow of electricity (current)    |
| DC2 Block Name             | 147         | [idx]                  | "\<node name>"          | Name of the placed block<br />*idx* is the inventory slot number (1..n) of the related the block position |
| Distri. Filter Get         | 148         | [idx]                  | "\<item list>"          | *idx* is the slot number: <br />1 = "red", 2 = "green", 3 = "blue", 4 = "yellow"<br />Return a string like: "default:dirt dye:blue" |
| Time Stamp                 | 149         | -                      | [time]                  | Time in system ticks (norm. 100 ms) when the TA4 Button is clicked |
| TA4 Pusher Counter         | 150         | -                      | [num]                   | Read the number of pushed items for a TA4 Pusher in "flow limiter" mode |
| TA4 Pump Counter           | 151         | -                      | [num]                   | Read the number of pumped liquid units for a TA4 Pump in "flow limiter" mode |
| Multi Button State         | 152         | [num]                  | [state]                 | Read the button state (TA4 2x Button, TA4 4x Button)<br />*num* is the button number (1..4), *state* is the state: 0 = "off", 1 = "on" |
| Water Remover Depth        | 153         | -                      | [depth}                 | Current depth value of a remover (1..80)                     |
|                            |             |                        |                         |                                                              |
|                            |             |                        |                         |                                                              |
| **=============**          | **====**    | **========**           | **========**            | **For Topics >= 192 the payload is a string**                |
| Chest Item Count           | 192         | "\<item name>"         | [num]                   | For TA3/TA4/TA5 chest or shop<br />Read the number of items of the given item name.<br /> `<item name>` can be a substring of the item name. |
|                            |             |                        |                         |                                                              |



### Nodes and Commands

| Technical Node Name | Supported Commands |
| ------------------- | ------------------ |
| techage:chest_cart | 131 |
| techage:chest_ta2 | 131, 192 |
| techage:chest_ta3 | 131, 192 |
| techage:chest_ta4 | 131, 192 |
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
| techage:ta3_button_off | 1, 131 |
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
| techage:ta3_repeater | 1 |
| techage:ta3_rinser_pas | 1, 128, 129 |
| techage:ta3_sequencer | 7 |
| techage:ta3_sieve_pas | 1, 128, 129 |
| techage:ta3_silo | 131, 134 |
| techage:ta3_tank | 128, 134 |
| techage:ta3_soundblock | 1, 14 |
| techage:ta3_valve_open | 1, 142 |
| techage:ta3_power_terminal | 134 |
| techage:ta4_battery | 134 |
| techage:ta4_button_2x, techage:ta4_button_4x | 23, 152 |
| techage:ta4_button_off | 1, 131, 144, 149 |
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
| techage:ta4_tank | 128, 134 |
| techage:ta4_solar_inverter | 1, 128, 129, 135 |
| techage:ta4_solar_minicell | 145 |
| techage:ta4_transformer | 1, 128, 129 |
| techage:ta4_turncontroller | 12 |
| techage:ta4_wind_turbine | 1, 129, 135 |
| techage:ta5_flycontroller | 11, 129 |
| techage:ta5_flycontroller | 129 |
| techage:ta5_fr_controller_pas | 1, 128, 129 |
| techage:ta5_heatexchanger2 | 1, 128, 129, 135 |
| techage:ta5_hl_chest | 131, 192 |
| techage:ta5_pump | 1, 128, 129 |
| techage:ta5_tele_pipe | 1, 128, 129 |
| techage:ta5_tele_tube | 1, 128, 129 |
| techage:ta5_generator | 1, 128, 129, 135 |
| techage:tiny_generator | 1, 128, 129, 132, 135 |
| pdp13:14segment | 16 |
| pdp13:7segment | 15 |


