# Beduino für Techage

Beduino ist ein 16-Bit-Mikrocontrollersystem, das von Arduino-Boards und -Kits
inspiriert ist.
Beduino kann in der C-ähnlichen Programmiersprache mC programmiert werden.
Um Beduino nutzen zu können, sind Grundkenntnisse in Programmiersprachen von Vorteil.

Beduino ist komplett in die Mod Techage integriert und
kann alternativ zum Lua-Controller verwendet werden.

Weiter Hinweise zu Beduino, der Programmiersprache und den techage Kommandos
findest du hier: https://github.com/joe7575/beduino/wiki

[beduino_controller|image]

## Erste Schritte

- Crafte die vier Blöcke "VM16 Programmer", "VM16 File Server", "Beduino Controller" und "Beduino I/O Module"
- Platziere Controller und I/O Modul neben- oder übereinander (maximaler Abstand sind 3 Blöcke)
- Beim  I/O Modul muss eine Basisadresse eingegeben werden
- Platziere den Server irgendwo
- Paare den Programmer mit Server und Controller, indem du mit dem Programmer auf beide Blöcke klickst
- Zuletzt platziere den Programmierer vor dem Controller (in Wirklichkeit kann der Programmierer überall platziert werden, da er bereits durch das Pairing mit dem Controller verbunden ist)

## I/O Modul

Der Hauptzweck eines I/O-Moduls besteht darin, Techage-Blocknummern in Beduino-Portnummern umzuwandeln und umgekehrt. Dies ist notwendig, da Beduino-Nummern nur einen begrenzten Bereich von 0 bis 65535 haben und Techage-Blocknummern viel größer sein können.

Jedes I/O Modul benötigt eine eigene Basis-Portnummer. Von der Basis-Portnummer abgeleitet besitzt jedes I/O Modul 8 Ports zu den techage Blöcken.

Es können bis zu 8 I/O Module pro Controller verwendet werden.

Um eine Verbindung von einem Techage Block zum I/O Modul herzustellen, muss die Techage Block Nummer im Menü des I/O Moduls eingegeben werden. Ist die Techage Block Nummer korrekt eingegeben, wird unter Description der Blockname angezeigt.

Um mit Techage-Blöcken zu kommunizieren, unterstützt das I/O-Modul die folgenden Befehle:

```c
// Sende ein Kommando zu einem techage Block
send_cmnd(port, topic, payload);

// Lese Daten von einem techage Block
request_data(port, topic, payload, resp);
```

Für Details siehe [Beduino commands](https://github.com/joe7575/beduino/blob/main/BEPs/bep-005_ta_cmnd.md).

# Input Modul

Auch jedes Input Modul benötigt eine eigene Basisadresse,
hat aber nur einen Port, an dem alle eingehenden Kommandos ankommen.
Dies hat den Vorteil, dass vom Beduino Controller aus nur ein Port abgefragt werden muss.

Das erste empfangene Kommando wird vom Modul gespeichert und ein Event
wird an den Beduino Controller ausgelöst. Events können über die 
Funktion `event()` abgefragt werden.

Alle weiteren Kommandos werden solange verworfen, bis der Wert vom 
Beduino Controller über `input()` ausgelesen und das Input-Register damit gelöscht wurde.

Der Aufruf von `event()` setzt das Event-Flag zurück.



## Techage Kommandos

Für komplexere Kommandos zur Steuerung von techage Maschinen dienen
folgende Kommandos. Auch hierfür muss eine Verbindung vom I/O Modul
zum techage Block vorhanden sein, da für die Addressierung immer
auch ein Port benötigt wird:

```c
send_cmnd(port, topic, payload);
request_data(port, topic, payload, resp);
```

- *port* ist die I/O Modul Port Nummer
- *topic* ist eine Nummer aus der Liste der [Beduino Kommandos](https://github.com/joe7575/beduino/blob/main/BEPs/bep-005_ta_cmnd.md)
- *payload* ist je nach Kommando ein Array oder ein String mit zusätzlichen Informationen Werden keine zusätzlichen Kommandos benötigt, kann "" angegeben werden
- *resp* ist ein Array für die Antwortdaten. Das Array muss groß genug definiert werden, so dass es die Antwortdaten aufnehmen kann

