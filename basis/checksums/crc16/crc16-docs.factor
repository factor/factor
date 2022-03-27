USING: help.markup help.syntax ;
IN: checksums.crc16

HELP: crc16
{ $class-description "The crc16 checksum algorithm." } ;

ARTICLE: "checksums.crc16" "CRC16 checksum"
"The crc16 checksum algorithm provides a quick but unreliable way to detect changes in data. Also known as CRC-16 and CRC-16-ANSI. Used in Bisync, Modbus, USB, ANSI X3.28 and many other protocols."
{ $subsections crc16 } ;

ABOUT: "checksums.crc16"
