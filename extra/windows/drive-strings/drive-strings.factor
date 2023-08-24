! Copyright (C) 2019 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays io.encodings.string io.encodings.utf16
kernel math sequences splitting windows.kernel32 ;
IN: windows.drive-strings

: logical-drive-strings ( -- seq )
    30 4 2 * * dup <byte-array> [ GetLogicalDriveStrings ] keep
    utf16le decode swap head "\0" split harvest ;
