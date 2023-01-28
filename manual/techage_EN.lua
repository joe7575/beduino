techage.add_to_manual('EN', {
  "1,Beduino for Techage",
  "2,First Steps",
  "2,I/O Module",
  "2,Input Module",
  "2,IOT Sensor",
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
  "  - A base port number must be entered for the I/O module\n"..
  "  - Place the server anywhere\n"..
  "  - Pair the programmer with the server and controller by clicking on both blocks with the programmer\n"..
  "  - Last place the programmer in front of the controller (in reality the programmer can be placed anywhere since \nit is already connected to the controller by pairing)\n"..
  "\n",
  "The main purpose of an I/O module is to convert Techage block numbers to Beduino port numbers and vice versa.\n"..
  "This is necessary as Beduino numbers only have a limited range from 0 to 65535 and Techage block numbers\n"..
  "can be much larger.\n"..
  "\n"..
  "Each I/O module requires its own base port number. Derived from the base port number\\, each I/O module\n"..
  "has 8 ports to the techage blocks. \n"..
  "\n"..
  "Up to 8 I/O modules can be used per controller. \n"..
  "\n"..
  "In order to establish a connection from a Techage Block to the I/O Module\\, the Techage Block number must\n"..
  "be entered in the I/O Module menu. If the Techage Block number is entered correctly\\, the block name\n"..
  "is displayed under Description.\n"..
  "\n"..
  "To communicate with techage blocks\\, the I/O module supports the following commands:\n"..
  "\n"..
  "    // Send a command to a techage block\n"..
  "    send_cmnd(port\\, topic\\, payload)\\;\n"..
  "    \n"..
  "    // Read data from a techage block\n"..
  "    request_data(port\\, topic\\, payload\\, resp)\\;\n"..
  "\n"..
  "See Techage Functions. for details.\n"..
  "\n"..
  "\n"..
  "\n",
  "Input modules are used to receive commands from other techage blocks (switches\\, detectors\\, etc.).\n"..
  "\n"..
  "Each input module requires its own base port number. Derived from the base port number\n"..
  "each input module has 8 ports to the techage blocks.\n"..
  "\n"..
  "The ports are necessary to convert Techage block numbers to Beduino port numbers.\n"..
  "This is necessary because Beduino numbers only have a limited range from 0 to 65535\n"..
  "and Techage block numbers can be much larger.\n"..
  "\n"..
  "In addition\\, when a command is received\\, an event with the port number is sent to the controller.\n"..
  "\n"..
  "This makes it very easy for the controller to query whether commands have been received:\n"..
  "\n"..
  "    port = get_next_inp_port()\\;  // Read next port number\n"..
  "    if(port != 0xffff) {\n"..
  "        val = input(port)\\;       // Read input value\n"..
  "        ...\n"..
  "    }\n"..
  "\n"..
  "The controller saves up to 8 events from up to 16 input modules\\, each with up to 8 occupied ports.\n"..
  "\n"..
  "\n"..
  "\n",
  "The IOT Sensor is a small microcontroller that can be placed directly on a Techage machine. \n"..
  "\n"..
  "It can be programmed like the Beduino controller. However\\, there are also differences:\n"..
  "\n"..
  "  - The IOT sensor has less program memory (512 words). The program memory can also not be extended.\nHowever\\, it is sufficient for typical applications\\, such as checking the status of a machine\nand sending an alarm if necessary.\n"..
  "  - The IOT sensor does not support IO modules\\, input modules or routers. However\\, it has a\n\"combi\" module internally\\, so it can communicate with machines\\, brokers and other controllers\nlike Beduino controllers.\n"..
  "  - The IOT Sensor has 5 I/O ports for 5 positions in its environment. The block directly\nbehind the IOT sensor has port number 0\\, the 4 positions above\\, below\\, left and right\nof the block have port numbers 1 to 4. The numbers are mapped as dots on the IOT sensor.\n"..
  "  - OT sensor stores its code internally and can be set to another position without program loss.\nThis can be useful\\, for example\\, for quarries\\, since these must be regularly set further.\nThe code restarts automatically\\, so you do not need a programmer.\n"..
  "  - To give the IOT sensor a name\\, the sensor supports the wrench menu .\nThe entered name is then displayed as info to the item in the inventory.\n"..
  "\n"..
  "\n"..
  "\n",
}, {
  "beduino_controller",
  "",
  "beduino_io_module",
  "beduino_input_module",
  "beduino_iot_sensor",
}, {
  "",
  "",
  "",
  "",
  "",
})
