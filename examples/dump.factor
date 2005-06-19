! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: dump
USING: alien assembler generic kernel kernel-internals lists
math memory sequences io strings unparser ;

: cell. >hex cell 2 * CHAR: 0 pad write ;

: slot@ ( address n -- n ) cell * swap 7 bitnot bitand + ;

: dump-line ( address n value -- )
    >r slot@ cell. ": " write r> cell. terpri ;

: (dump) ( address list -- )
    0 swap [ >r 2dup r> dump-line 1 + ] each 2drop ;

: integer-slots ( obj -- list )
    dup size cell / [ integer-slot ] project-with ;

: dump ( obj -- )
    #! Dump an object's memory.
    dup address swap integer-slots (dump) ;

: alien-slots ( address length -- list )
    cell / [ cell * alien-unsigned-4 ] project-with ;

: dump* ( alien len -- )
    #! Dump an alien's memory.
    dup string? [ c-size ] when 
    >r [ alien-address ] keep r> alien-slots (dump) ;
