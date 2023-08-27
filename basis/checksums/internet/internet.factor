! Copyright (C) 2010 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: checksums endian grouping kernel math sequences ;

IN: checksums.internet

SINGLETON: internet ! RFC 1071

INSTANCE: internet checksum

M: internet checksum-bytes
    drop 2 <groups> [ le> ] map-sum
    [ -16 shift ] [ 0xffff bitand ] bi +
    [ -16 shift ] keep + bitnot 2 >le ;
