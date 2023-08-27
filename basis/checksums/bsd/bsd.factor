! Copyright (C) 2013 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: checksums kernel math sequences ;
IN: checksums.bsd

SINGLETON: bsd

M: bsd checksum-bytes
    drop 0 [
        [ [ -1 shift ] [ 1 bitand 15 shift ] bi + ] dip
        + 0xffff bitand
    ] reduce ;

INSTANCE: bsd checksum
