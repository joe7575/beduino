techage.add_to_manual('DE', {
  "1,Beduino für Techage",
  "2,Erste Schritte",
  "2,I/O Modul",
  "2,Input Modul",
  "2,IOT Sensor",
}, {
  "Beduino ist ein 16-Bit-Mikrocontrollersystem\\, das von Arduino-Boards und -Kits\n"..
  "inspiriert ist.\n"..
  "Beduino kann in der C-ähnlichen Programmiersprache mC programmiert werden.\n"..
  "Um Beduino nutzen zu können\\, sind Grundkenntnisse in Programmiersprachen von Vorteil.\n"..
  "\n"..
  "Beduino ist komplett in die Mod Techage integriert und\n"..
  "kann alternativ zum Lua-Controller verwendet werden.\n"..
  "\n"..
  "Weitere Hinweise zu Beduino\\, der Programmiersprache und den techage Kommandos\n"..
  "findest du hier: https://github.com/joe7575/beduino/wiki\n"..
  "\n"..
  "\n"..
  "\n",
  "  - Crafte die vier Blöcke \"VM16 Programmer\"\\, \"VM16 File Server\"\\, \"Beduino Controller\"\nund \"Beduino I/O Module\"\n"..
  "  - Platziere Controller und I/O Modul neben- oder übereinander (maximaler Abstand sind 3 Blöcke)\n"..
  "  - Beim I/O Modul muss eine Basis-Port-Nummer eingegeben werden\n"..
  "  - Platziere den Server irgendwo\n"..
  "  - Paare den Programmer mit Server und Controller\\, indem du mit dem Programmer auf\nbeide Blöcke klickst\n"..
  "  - Zuletzt platziere den Programmierer vor dem Controller (in Wirklichkeit kann der\nProgrammierer überall platziert werden\\, da er bereits durch das Pairing mit dem\nController verbunden ist)\n"..
  "\n",
  "Der Hauptzweck eines I/O-Moduls besteht darin\\, Techage-Blocknummern in Beduino-Portnummern\n"..
  "umzuwandeln und umgekehrt. Dies ist notwendig\\, da Beduino-Nummern nur einen begrenzten\n"..
  "Bereich von 0 bis 65535 haben und Techage-Blocknummern viel größer sein können.\n"..
  "\n"..
  "Jedes I/O Modul benötigt eine eigene Basis-Portnummer. Von der Basis-Portnummer abgeleitet\n"..
  "besitzt jedes I/O Modul 8 Ports zu den techage Blöcken.\n"..
  "\n"..
  "Es können bis zu 8 I/O Module pro Controller verwendet werden.\n"..
  "\n"..
  "Um eine Verbindung von einem Techage Block zum I/O Modul herzustellen\\, muss die\n"..
  "Techage Block Nummer im Menü des I/O Moduls eingegeben werden. Ist die Techage Block Nummer\n"..
  "korrekt eingegeben\\, wird unter Description der Blockname angezeigt.\n"..
  "\n"..
  "Um mit Techage-Blöcken zu kommunizieren\\, unterstützt das I/O-Modul die folgenden Befehle:\n"..
  "\n"..
  "    // Sende ein Kommando zu einem techage Block\n"..
  "    send_cmnd(port\\, topic\\, payload)\\;\n"..
  "    \n"..
  "    // Lese Daten von einem techage Block\n"..
  "    request_data(port\\, topic\\, payload\\, resp)\\;\n"..
  "\n"..
  "Für Details siehe Techage Funktionen.\n"..
  "\n"..
  "\n"..
  "\n",
  "Input Module dienen zum Empfang von Kommandos anderer Techage Blöcke (Schalter\\, Detektoren\\, usw.).\n"..
  "\n"..
  "Jedes Input Modul benötigt eine eigene Basis-Portnummer. Von der Basis-Portnummer abgeleitet besitzt\n"..
  "jedes Input Modul wieder 8 Ports zu den techage Blöcken.\n"..
  "\n"..
  "Die Ports sind notwendig\\, um Techage-Blocknummern in Beduino-Portnummern umzuwandeln. \n"..
  "Dies ist notwendig\\, da Beduino-Nummern nur einen begrenzten Bereich von 0 bis 65535 haben\n"..
  "und Techage-Blocknummern viel größer sein können.\n"..
  "\n"..
  "Zusätzlich wird bei Empfang eines Kommandos ein Event mit der Port-Nummer an den Controller gesendet.\n"..
  "\n"..
  "Damit kann vom Controller sehr einfach abgefragt werden\\, ob Kommandos empfangen wurden:\n"..
  "\n"..
  "    port = get_next_inp_port()\\;  // Read next port number\n"..
  "    if(port != 0xffff) {\n"..
  "        val = input(port)\\;       // Read input value\n"..
  "        ...\n"..
  "    }\n"..
  "\n"..
  "Der Controller speichert bis zu 8 Events von bis zu 16 Input Modulen mit jeweils bis zu 8 belegten Ports.\n"..
  "\n"..
  "\n"..
  "\n",
  "Der IOT Sensor ist ein kleiner Mikrocontroller\\, der direkt an einer Techage Maschine platziert werden kann. \n"..
  "\n"..
  "Er kann wie der Beduino Controller programmiert werden. Es gibt aber auch Unterschiede:\n"..
  "\n"..
  "  - Der IOT Sensor besitzt weniger Programmspeicher (512 Worte). Den Programmspeicher kann man auch nicht erweitern. Für typische Anwendungen\\, wie bspw. den Status einer Maschine zu überprüfen und bei Bedarf einen Alarm abzusetzen\\, reicht es aber.\n"..
  "  - Der IOT Sensor unterstützt keine IO Module\\, Input Module oder Router. Er hat aber intern ein \"Kombi\" Modul\\, so dass er wie Beduino Controller mit Maschinen\\, Brokern und andern Controllern kommunizieren kann.\n"..
  "  - Der IOT Sensor hat 5 I/O Ports für 5 Positionen in seinem Umfeld. Der Block direkt hinter dem IOT Sensor hat die Portnummer 0\\, die 4 Positionen über\\, unter\\, links unbd rechts des Blocks haben die Portnummern 1 bis 4. Die Nummern sind als Punkte auf dem IOT Sensor abgebildet.\n"..
  "  - OT Sensor speichert seinen Code intern und kann ohne Programmverlust an eine andere Position gesetzt werden werden. Dies kann bspw. für Steinbrecher sinnvoll sein\\, da diese regelmäßig weiter gesetzt werden müssen. Der Code läuft automatisch wieder an\\, man benötigt daher keinen Programmer.\n"..
  "  - Um dem IOT Sensor einen Namen geben zu können\\, unterstützt der Sensor das Schraubenschlüsselmenü . Der eingegebene Name wird dann als Info zum Item im Inventar angezeigt.\n"..
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
