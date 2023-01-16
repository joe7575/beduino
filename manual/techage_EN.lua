techage.add_to_manual('EN', {
  "1,Beduino for Techage",
  "2,First Steps",
  "2,I/O Module",
  "2,Input Module",
  "2,Techage Commands",
}, {
  "Beduino is a 16-bit microcontroller system inspired by Arduino boards and kits.\n"..
  "Beduino can be programmed in the C-like programming language mC.\n"..
  "In order to be able to use Beduino\\, basic knowledge of\n"..
  "programming languages is an advantage.\n"..
  "\n"..
  "Beduino is fully integrated into the Mod Techage and\n"..
  "can be used as an alternative to the Lua controller.\n"..
  "\n"..
  "Further information about Beduino\\, the programming language and\n"..
  "the techage commands can be found here: https://github.com/joe7575/beduino/wiki\n"..
  "\n"..
  "\n"..
  "\n",
  "  - Craft the four blocks \"VM16 Programmer\"\\, \"VM16 File Server\"\\, \"Beduino Controller\" and \"Beduino I/O Module\"\n"..
  "  - Place controller and I/O module next to or on top of each other (maximum distance is 3 blocks)\n"..
  "  - A base address must be entered for the I/O module\n"..
  "  - Place the server anywhere\n"..
  "  - Pair the programmer with the server and controller by clicking on both blocks with the programmer\n"..
  "  - Last place the programmer in front of the controller (in reality the programmer can be placed anywhere since it is already connected to the controller by pairing)\n"..
  "\n",
  "Each I/O module requires its own base address. Derived from the base address\\,\n"..
  "each I/O module has 8 ports to the techage blocks. Up to 8 I/O modules \n"..
  "can be used per controller. \n"..
  "The techage block address must be entered for each port. \n"..
  "If the addresses are entered correctly\\, the block name is displayed under Description.\n"..
  "\n"..
  "The I/O block has a help menu that shows some techage commands \n"..
  "that can be used directly\\, such as:\n"..
  "\n"..
  "    val = input(2)\\; // Read in a value from port #2\n"..
  "    output(0\\, IO_ON)\\; // Turn on a block on port #0\n"..
  "    output(1\\, IO_GREEN)\\; // Set signal tower on port #1 to green\n"..
  "    sts = read(3\\, IO_STATE)\\; // Reading a machine status\n"..
  "\n"..
  "'input(port)' only reads the value from the port. \n"..
  "To do this\\, for example\\, a switch must be connected to the I/O module\n"..
  "(enter both numbers mutually). \n"..
  "'read(port\\, IO_STATE)'\\, on the other hand\\, requests the state from the machine.\n"..
  "\n"..
  "Every signal that is sent to an I/O module triggers an event on the controller. \n"..
  "Events can be queried using the 'event()' function. \n"..
  "If the function returns the value '1'\\, one or more signals have been received. \n"..
  "Calling 'event()' resets the event flag.\n"..
  "\n",
  "Each input module also requires its own base address\\, but has only one \n"..
  "port where all incoming commands arrive. This has the advantage that only \n"..
  "one port needs to be queried from the Beduino controller. \n"..
  "\n"..
  "The first command received is saved by the module and an event is triggered \n"..
  "on the Beduino controller. Events can be queried using the 'event()' function. \n"..
  "\n"..
  "All further commands are discarded until the value has been read from the \n"..
  "Beduino controller via 'input()' and the input register has thus been deleted.\n"..
  "\n"..
  "Calling 'event()' resets the event flag.\n"..
  "\n",
  "The following commands are used for more complex commands to control techage machines. \n"..
  "For this\\, too\\, there must be a connection from the I/O module to the techage block\\, \n"..
  "since a port is always required for addressing:\n"..
  "\n"..
  "    send_cmnd(port\\, topic\\, payload)\\;\n"..
  "    request_data(port\\, topic\\, payload\\, resp)\\;\n"..
  "\n"..
  "  - *port* is the I/O module port number\n"..
  "  - *topic* is a number from the list of Beduino commands\n"..
  "  - *payload* is an array or a string with additional information\\, depending on the command. If no additional commands are required\\, \"\" can be used\n"..
  "  - *resp* is an array for the response data. The array must be defined large enough to hold the response data\n"..
  "\n",
}, {
  "beduino_controller",
  "",
  "",
  "",
  "",
}, {
  "",
  "",
  "",
  "",
  "",
})
