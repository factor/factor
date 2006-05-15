! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assembler ;
IN: compiler

: generate-write-barrier ( -- )
    #! Mark the card pointed to by vreg.
    "obj" operand card-bits SHR
    "obj" operand R13 [+] card-mark OR ;
