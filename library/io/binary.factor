! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: stdio
USING: kernel lists math sequences strings ;

: be> ( seq -- x ) 0 swap [ >r 8 shift r> bitor ] each ;
: le> ( seq -- x ) reverse be> ;

: nth-byte ( x n -- b ) -8 * shift HEX: ff bitand ;

: >le ( x n -- string ) [ nth-byte ] project-with >string ;
: >be ( x n -- string ) >le reverse ;
