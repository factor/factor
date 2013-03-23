! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: checksums grouping io.binary kernel math sequences ;

IN: checksums.internet

SINGLETON: internet ! RFC 1071

INSTANCE: internet checksum

M: internet checksum-bytes
    drop 0 swap 2 <groups> [ le> + ] each
    [ -16 shift ] [ 0xffff bitand ] bi +
    [ -16 shift ] keep + bitnot 2 >le ;

