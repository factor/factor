! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: alien arrays assembler inference kernel
kernel-internals lists math memory namespaces sequences words ;

M: %write-barrier generate-node ( vop -- )
    #! Mark the card pointed to by vreg.
    drop
    0 input-operand card-bits SHR
    0 input-operand R13 [+] card-mark OR ;
