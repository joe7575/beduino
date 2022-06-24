techage.add_to_manual('DE', {
  "1,Beduino für Techage",
  "2,Erste Schritte",
  "2,I/O Modul",
  "2,Input Modul",
  "2,Techage Kommandos",
}, {
  "Beduino ist ein 16-Bit-Mikrocontrollersystem\\, das von Arduino-Boards und -Kits\n"..
  "inspiriert ist.\n"..
  "Beduino kann in der C-ähnlichen Programmiersprache Cipol programmiert werden.\n"..
  "Um Beduino nutzen zu können\\, sind Grundkenntnisse in Programmiersprachen von Vorteil.\n"..
  "\n"..
  "Beduino ist komplett in die Mod Techage integriert und\n"..
  "kann alternativ zum Lua-Controller verwendet werden.\n"..
  "\n"..
  "Weiter Hinweise zu Beduino\\, der Programmiersprache und den techage Kommandos\n"..
  "findest du hier: https://github.com/joe7575/beduino/wiki\n"..
  "\n"..
  "\n"..
  "\n",
  "  - Crafte die vier Blöcke \"VM16 Programmer\"\\, \"VM16 File Server\"\\, \"Beduino Controller\" und \"Beduino I/O Module\"\n"..
  "  - Platziere Controller und I/O Modul neben- oder übereinander (maximaler Abstand sind 3 Blöcke)\n"..
  "  - Beim  I/O Modul muss eine Basisadresse eingegeben werden\n"..
  "  - Platziere den Server irgendwo\n"..
  "  - Paare den Programmer mit Server und Controller\\, indem du mit dem Programmer auf beide Blöcke klickst\n"..
  "  - Zuletzt platziere den Programmierer vor dem Controller (in Wirklichkeit kann der Programmierer überall platziert werden\\, da er bereits durch das Pairing mit dem Controller verbunden ist)\n"..
  "\n",
  "Jedes I/O Modul benötigt eine eigene Basisadresse.\n"..
  "Von der Basisadresse abgeleitet besitzt jedes I/O Modul 8 Ports zu den techage Blöcken.\n"..
  "Es können bis zu 8 I/O Module pro Controller verwendet werden.\n"..
  "Für jeden Port muss die techage Block-Adresse eingegeben werden.\n"..
  "Sind die Adressen korrekt eingegeben\\, wird unter Description der Blockname angezeigt.\n"..
  "\n"..
  "Der I/O Block hat ein Hilfe-Menü\\, welches einige techage Kommandos zeigt\\,\n"..
  "die direkt genutzt werden können\\, wie bspw.:\n"..
  "\n"..
  "    val = input(2)\\;           // Einlesen eines Wertes von Port #2\n"..
  "    output(0\\, IO_ON)\\;         // Einschalten eines Blockes am Port #0\n"..
  "    output(1\\, IO_GREEN)\\;      // Signal Tower am Port #1 auf grün stellen\n"..
  "    sts = read(3\\, IO_STATE)\\;  // Einlesen eines Maschinen Status\n"..
  "\n"..
  "'input(port)' liest nur den Wert vom Port. Dazu muss bspw. ein Schalter\n"..
  "mit dem I/O Modul verbunden werden (beide Nummern gegenseitig eintragen).\n"..
  "'read(port\\, IO_STATE)' fordert dagegen den Status von der Maschine an.\n"..
  "\n"..
  "Jedes Signal\\, das an ein I/O Modul gesendet wird\\, löst auf dem Controller\n"..
  "einen Event aus. Events können über die Funktion 'event()' abgefragt werden.\n"..
  "Liefert die Funktion den Wert '1' zurück\\, wurden ein oder mehrere Signale empfangen.\n"..
  "Der Aufruf von 'event()' setzt das Event-Flag zurück.\n"..
  "\n",
  "Auch jedes Input Modul benötigt eine eigene Basisadresse\\,\n"..
  "hat aber nur einen Port\\, an dem alle eingehenden Kommandos ankommen.\n"..
  "Dies hat den Vorteil\\, dass vom Beduino Controller aus nur ein Port abgefragt werden muss.\n"..
  "\n"..
  "Das erste empfangene Kommando wird vom Modul gespeichert und ein Event\n"..
  "wird an den Beduino Controller ausgelöst. Events können über die \n"..
  "Funktion 'event()' abgefragt werden.\n"..
  "\n"..
  "Alle weiteren Kommandos werden solange verworfen\\, bis der Wert vom \n"..
  "Beduino Controller über 'input()' ausgelesen und das Input-Register damit gelöscht wurde.\n"..
  "\n"..
  "Der Aufruf von 'event()' setzt das Event-Flag zurück.\n"..
  "\n",
  "Für komplexere Kommandos zur Steuerung von techage Maschinen dienen\n"..
  "folgende Kommandos. Auch hierfür muss eine Verbindung vom I/O Modul\n"..
  "zum techage Block vorhanden sein\\, da für die Addressierung immer\n"..
  "auch ein Port benötigt wird:\n"..
  "\n"..
  "    send_cmnd(port\\, topic\\, payload)\\;\n"..
  "    request_data(port\\, topic\\, payload\\, resp)\\;\n"..
  "\n"..
  "  - *port* ist die I/O Modul Port Nummer\n"..
  "  - *topic* ist eine Nummer aus der Liste der\n"..
  "  - *payload* ist je nach Kommando ein Array oder ein String mit zusätzlichen Informationen Werden keine zusätzlichen Kommandos benötigt\\, kann \"\" angegeben werden\n"..
  "  - *resp* ist ein Array für die Antwortdaten. Das Array muss groß genug definiert werden\\, so dass es die Antwortdaten aufnehmen kann\n"..
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
