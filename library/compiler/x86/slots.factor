! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien arrays assembler compiler inference kernel
kernel-internals lists math memory namespaces sequences words ;

M: %slot generate-node ( vop -- )
    drop
    ! turn tagged fixnum slot # into an offset, multiple of 4
    0 input-operand fixnum>slot@
    ! compute slot address
    dest/src ADD
    ! load slot value
    0 output-operand dup 1array MOV ;

M: %fast-slot generate-node ( vop -- )
    drop 0 output-operand 1 input-operand 0 input 2array MOV ;

: card-offset 1 getenv ; inline

M: %write-barrier generate-node ( vop -- )
    #! Mark the card pointed to by vreg. This could be a tad
    #! shorter on x86 (use indirect addressing instead of a
    #! scratch register) however on AMD64, you cannot do this
    #! with a 64-bit immediate. So we avoid code duplication by
    #! sacrificing a few bytes of generated code size.
    drop
    0 input-operand card-bits SHR
    0 scratch card-offset MOV rel-absolute-cell rel-cards
    0 scratch 0 input-operand ADD
    0 scratch 1array card-mark OR ;

M: %set-slot generate-node ( vop -- )
    drop
    ! turn tagged fixnum slot # into an offset
    2 input-operand fixnum>slot@
    ! compute slot address
    2 input-operand 1 input-operand ADD
    ! store new slot value
    2 input-operand 1array 0 input-operand MOV ;

M: %fast-set-slot generate-node ( vop -- )
    drop 1 input-operand 2 input 2array 0 input-operand MOV ;

: userenv@ ( n -- addr ) cells "userenv" f dlsym + ;

M: %getenv generate-node ( vop -- )
    drop
    0 output-operand 0 input userenv@ MOV
    0 input rel-absolute-cell rel-userenv
    0 output-operand dup 1array MOV ;

M: %setenv generate-node ( vop -- )
    drop
    0 scratch 1 input userenv@ MOV
    1 input rel-absolute-cell rel-userenv
    0 scratch 1array 0 input-operand MOV ;
