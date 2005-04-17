! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: dump
USING: alien assembler generic kernel kernel-internals math
memory sequences stdio strings unparser ;

: cell. >hex cell 2 * CHAR: 0 pad write ;

TUPLE: integer-slot-seq object ;

M: integer-slot-seq length
    integer-slot-seq-object size cell / ;

M: integer-slot-seq nth
    integer-slot-seq-object swap >fixnum integer-slot ;

: slot@ ( address n -- n ) cell * swap 7 bitnot bitand + ;

: dump-line ( address n value -- )
    >r slot@ cell. ": " write r> cell. terpri ;

: (dump) ( address sequence -- )
    0 swap [ 2dup dump-line 1 + ] seq-each 2drop ;

TUPLE: alien-seq alien length ;

M: alien-seq length
    alien-seq-length ;

M: alien-seq nth
    alien-seq-alien swap cell * alien-unsigned-4 ;

: dump ( obj -- )
    #! Dump an object's memory.
    dup address <integer-slot-seq> (dump) ;

: dump* ( alien len -- )
    #! Dump an alien's memory.
    dup string? [ c-size ] when 
    >r [ alien-address ] keep r> <alien-seq> (dump) ;
