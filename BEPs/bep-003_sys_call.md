| Author              | Version | Status   | Modified    |
| ------------------- | ------- | -------- | ----------- |
| J.Stolberg          | 0.2     | Draft    | 09 Jun 2022 |



# BEP 003: Numbers for system calls



| Number range (hex) | Number | Provided for                     | Remarks                       |
| ------------------ | ------ | -------------------------------- | ----------------------------- |
| 000 - 01F          | 32     | vm16 internal                    | mainly reserved               |
| 020 - 03F          | 32     | Beduino generic OS calls         | like `get_time()`             |
| 040 - 05F          | 32     | Beduino COM calls                | for router, broker, ...       |
| 060 - 0FF          | 160    | reserved                         | for future use                |
| 100 - 11F          | 32     | Mod techage (defined by beduino) | common to techage and tubelib |
| 120 - 13F          | 32     | Mod tubelib (defined by beduino) | common to techage and tubelib |
| 140 - 17F          | 64     | Mod techage (defined by techage) | external                      |
|                    |        |                                  |                               |
|                    |        |                                  |                               |

