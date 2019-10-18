! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io
USING: kernel math sequences strings ;

: be> ( seq -- x ) 0 [ swap 8 shift bitor ] reduce ;
: le> ( seq -- x ) <reversed> be> ;

: mask-byte ( x -- y ) HEX: ff bitand ; inline

: nth-byte ( x n -- b ) -8 * shift mask-byte ;

: >le ( x n -- str ) [ nth-byte ] map-with >string ;
: >be ( x n -- str ) >le dup reverse-here ;
