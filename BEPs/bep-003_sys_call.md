| Author              | Version | Status   | Modified    |
| ------------------- | ------- | -------- | ----------- |
| J.Stolberg          | 0.1     | Draft    | 18 Apr 2022 |



# RFC 003: Numbers for system calls



| Number range (hex) | Number | Provided for             | Remarks                 |
| ------------------ | ------ | ------------------------ | ----------------------- |
| 000 - 01F          | 32     | vm16 internal            | mainly reserved         |
| 020 - 03F          | 32     | Beduino generic OS calls | like `get_time()`       |
| 040 - 05F          | 32     | Beduino COM calls        | for router, broker, ... |
| 060 - 0FF          | 160    | reserved                 | for future use          |
| 100 - 11F          | 32     | Mod techage              |                         |
| 120 - 13F          | 32     | Mod tubelib              |                         |
|                    |        |                          |                         |
|                    |        |                          |                         |
|                    |        |                          |                         |

