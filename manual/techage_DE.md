# Beduino für Techage

Beduino ist ein 16-Bit-Mikrocontrollersystem, das von Arduino-Boards und -Kits
inspiriert ist.
Beduino kann in der C-ähnlichen Programmiersprache mC programmiert werden.
Um Beduino nutzen zu können, sind Grundkenntnisse in Programmiersprachen von Vorteil.

Beduino ist komplett in die Mod Techage integriert und
kann alternativ zum Lua-Controller verwendet werden.

Weitere Hinweise zu Beduino, der Programmiersprache und den techage Kommandos
findest du hier: https://github.com/joe7575/beduino/wiki

[beduino_controller|image]

## Erste Schritte

- Crafte die vier Blöcke "VM16 Programmer", "VM16 File Server", "Beduino Controller"
  und "Beduino I/O Module"
- Platziere Controller und I/O Modul neben- oder übereinander (maximaler Abstand sind 3 Blöcke)
- Beim I/O Modul muss eine Basis-Port-Nummer eingegeben werden
- Platziere den Server irgendwo
- Paare den Programmer mit Server und Controller, indem du mit dem Programmer auf
  beide Blöcke klickst
- Zuletzt platziere den Programmierer vor dem Controller (in Wirklichkeit kann der
  Programmierer überall platziert werden, da er bereits durch das Pairing mit dem
  Controller verbunden ist)

## I/O Modul

Der Hauptzweck eines I/O-Moduls besteht darin, Techage-Blocknummern in Beduino-Portnummern
umzuwandeln und umgekehrt. Dies ist notwendig, da Beduino-Nummern nur einen begrenzten
Bereich von 0 bis 65535 haben und Techage-Blocknummern viel größer sein können.

Jedes I/O Modul benötigt eine eigene Basis-Portnummer. Von der Basis-Portnummer abgeleitet
besitzt jedes I/O Modul 8 Ports zu den techage Blöcken.

Es können bis zu 8 I/O Module pro Controller verwendet werden.

Um eine Verbindung von einem Techage Block zum I/O Modul herzustellen, muss die
Techage Block Nummer im Menü des I/O Moduls eingegeben werden. Ist die Techage Block Nummer
korrekt eingegeben, wird unter Description der Blockname angezeigt.

Um mit Techage-Blöcken zu kommunizieren, unterstützt das I/O-Modul die folgenden Befehle:

```c
// Sende ein Kommando zu einem techage Block
send_cmnd(port, topic, payload);

// Lese Daten von einem techage Block
request_data(port, topic, payload, resp);
```

Für Details siehe [Techage Funktionen](https://github.com/joe7575/beduino/blob/main/manual/techage.md).

[beduino_io_module|image]

## Input Modul

Input Module dienen zum Empfang von Kommandos anderer Techage Blöcke (Schalter, Detektoren, usw.).

Jedes Input Modul benötigt eine eigene Basis-Portnummer. Von der Basis-Portnummer abgeleitet besitzt
jedes Input Modul wieder 8 Ports zu den techage Blöcken.

Die Ports sind notwendig, um Techage-Blocknummern in Beduino-Portnummern umzuwandeln. 
Dies ist notwendig, da Beduino-Nummern nur einen begrenzten Bereich von 0 bis 65535 haben
und Techage-Blocknummern viel größer sein können.

Zusätzlich wird bei Empfang eines Kommandos ein Event mit der Port-Nummer an den Controller gesendet.

Damit kann vom Controller sehr einfach abgefragt werden, ob Kommandos empfangen wurden:

```c
port = get_next_inp_port();  // Read next port number
if(port != 0xffff) {
    val = input(port);       // Read input value
    ...
}
```

Der Controller speichert bis zu 8 Events von bis zu 16 Input Modulen mit jeweils bis zu 8 belegten Ports.

[beduino_input_module|image]

## IOT Sensor

Der IOT Sensor ist ein kleiner Mikrocontroller, der direkt an einer Techage Maschine platziert werden kann. 

Er kann wie der Beduino Controller programmiert werden. Es gibt aber auch Unterschiede:

- Der IOT Sensor besitzt weniger Programmspeicher (512 Worte). Den Programmspeicher kann man auch nicht erweitern. Für typische Anwendungen, wie bspw. den Status einer Maschine zu überprüfen und bei Bedarf einen Alarm abzusetzen, reicht es aber.
- Der IOT Sensor unterstützt keine IO Module, Input Module oder Router. Er hat aber intern ein "Kombi" Modul, so dass er wie Beduino Controller mit Maschinen, Brokern und andern Controllern kommunizieren kann.
- Der IOT Sensor hat 5 I/O Ports für 5 Positionen in seinem Umfeld. Der Block direkt hinter dem IOT Sensor hat die Portnummer 0, die 4 Positionen über, unter, links unbd rechts des Blocks haben die Portnummern 1 bis 4. Die Nummern sind als Punkte auf dem IOT Sensor abgebildet.
- Der IOT Sensor speichert seinen Code intern und kann ohne Programmverlust an eine andere Position gesetzt werden werden. Dies kann bspw. für Steinbrecher sinnvoll sein, da diese regelmäßig weiter gesetzt werden müssen. Der Code läuft automatisch wieder an, man benötigt daher keinen Programmer.
- Um dem IOT Sensor einen Namen geben zu können, unterstützt der Sensor das Schraubenschlüsselmenü . Der eingegebene Name wird dann als Info zum Item im Inventar angezeigt. 

[beduino_iot_sensor|image]