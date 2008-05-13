! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io kernel math.parser sequences ;
IN: ftp

SINGLETON: active
SINGLETON: passive

: ftp-send ( string -- ) write "\r\n" write flush ;
