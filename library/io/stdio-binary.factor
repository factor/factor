! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: stdio
USING: kernel lists math sequences strings ;

: be> ( seq -- x ) 0 swap [ >r 8 shift r> bitor ] each ;
: le> ( seq -- x ) reverse be> ;

: nth-byte ( x n -- b ) -8 * shift HEX: ff bitand ;

: >le ( x n -- string ) [ nth-byte ] project-with >string ;
: >be ( x n -- string ) >le reverse ;

: read-le2 ( -n) 2 read le> ; : read-be2 ( -n) 2 read be> ;
: read-le4 ( -n) 4 read le> ; : read-be4 ( -n) 4 read be> ;
: read-le8 ( -n) 8 read le> ; : read-be8 ( -n) 8 read be> ;

: write-le2 ( n-) 2 >le write ; : write-be2 ( n-) 2 >be write ;
: write-le4 ( n-) 4 >le write ; : write-be4 ( n-) 4 >be write ;
: write-le8 ( n-) 8 >le write ; : write-be8 ( n-) 8 >be write ;
