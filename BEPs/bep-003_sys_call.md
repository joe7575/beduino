| Author              | Version | Status   | Modified    |
| ------------------- | ------- | -------- | ----------- |
| J.Stolberg          | 0.2     | Draft    | 09 Jun 2022 |



# BEP 003: Numbers for system calls



| Number range (hex) | Number | Provided for                     | Remarks                       |
| ------------------ | ------ | -------------------------------- | ----------------------------- |
| 000 - 01F          | 32     | vm16 internal                    | mainly reserved               |
| 020 - 03F          | 32     | Beduino generic OS calls         | like `get_time()`             |
| 040 - 05F          | 32     | Beduino COM calls                | for router, broker, ...       |
| 060 - 06F          | 16     | Beduino EEPROM calls             | read/write functions          |
| 070 - 0FF          | 144    | reserved                         | for future use                |
| 100 - 11F          | 32     | Mod techage (defined by beduino) | common to techage and tubelib |
| 120 - 13F          | 32     | Mod tubelib (defined by beduino) | common to techage and tubelib |
| 140 - 17F          | 64     | Mod techage (defined by techage) | external                      |
|                    |        |                                  |                               |
|                    |        |                                  |                               |

## VM16 internal system calls

| Number (hex) | val1    | val2 | val3 | Remarks                                                      |
| ------------ | ------- | ---- | ---- | ------------------------------------------------------------ |
| 0            | char    | -    | -    | output char on stdout                                        |
| 1            | channel | -    | -    | set output channel for 'stdout':<br />0 = Programmer debug line (default)<br />1 = Programmer terminal window |
| 2            | -       | -    | -    | get char from stdin (to be implemented from application)     |