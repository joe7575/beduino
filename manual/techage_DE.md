# Beduino für Techage

Beduino ist ein 16-Bit-Mikrocontrollersystem, das von Arduino-Boards und -Kits
inspiriert ist.
Beduino kann in der C-ähnlichen Programmiersprache Cipol programmiert werden.
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

Jedes I/O Modul benötigt eine eigene Basisadresse.
Von der Basisadresse abgeleitet besitzt jedes I/O Modul 8 Ports zu den techage Blöcken.
Es können bis zu 8 I/O Module pro Controller verwendet werden.
Für jeden Port muss die techage Block-Adresse eingegeben werden.
Sind die Adressen korrekt eingegeben, wird unter Description der Blockname angezeigt.

Der I/O Block hat ein Hilfe-Menü, welches einige techage Kommandos zeigt,
die direkt genutzt werden können, wie bspw.:

```c
val = input(2);           // Einlesen eines Wertes von Port #2
output(0, IO_ON);         // Einschalten eines Blockes am Port #0
output(1, IO_GREEN);      // Signal Tower am Port #1 auf grün stellen
sts = read(3, IO_STATE);  // Einlesen eines Maschinen Status
```

`input(port)` liest nur den Wert vom Port. Dazu muss bspw. ein Schalter
mit dem I/O Modul verbunden werden (beide Nummern gegenseitig eintragen).
`read(port, IO_STATE)` fordert dagegen den Status von der Maschine an.

Jedes Signal, das an ein I/O Modul gesendet wird, löst auf dem Controller
einen Event aus. Events können über die Funktion `event()` abgefragt werden.
Liefert die Funktion den Wert `1` zurück, wurden ein oder mehrere Signale empfangen.
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
- *payload* ist je nach Kommando ein Array oder ein String mit zusätzlichen Informationen Werden keine zusätzlichen Kommandos benötigt, kann `""` angegeben werden
- *resp* ist ein Array für die Antwortdaten. Das Array muss groß genug definiert werden, so dass es die Antwortdaten aufnehmen kann

