! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
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
    0 output-operand dup [] MOV ;

M: %fast-slot generate-node ( vop -- )
    drop 0 output-operand 1 input-operand 0 input [+] MOV ;

: card-offset 1 getenv ; inline

M: %write-barrier generate-node ( vop -- )
    #! Mark the card pointed to by vreg.
    drop
    0 input-operand card-bits SHR
    0 input-operand card-offset ADD rel-absolute-cell rel-cards
    0 input-operand [] card-mark OR ;

M: %set-slot generate-node ( vop -- )
    drop
    ! turn tagged fixnum slot # into an offset
    2 input-operand fixnum>slot@
    ! compute slot address
    2 input-operand 1 input-operand ADD
    ! store new slot value
    2 input-operand [] 0 input-operand MOV ;

M: %fast-set-slot generate-node ( vop -- )
    drop 1 input-operand 2 input [+] 0 input-operand MOV ;

: >register-16 ( reg -- reg )
    "register" word-prop { AX CX DX } nth ;

: scratch-16 ( n -- reg ) scratch >register-16 ;

M: %char-slot generate-node ( vop -- )
    drop
    0 input-operand 2 SHR
    0 scratch dup XOR
    dest/src ADD
    0 scratch-16 0 output-operand string-offset [+] MOV
    0 scratch tag-bits SHL
    0 output-operand 0 scratch MOV ;

M: %set-char-slot generate-node ( vop -- )
    drop
    0 input-operand tag-bits SHR
    2 input-operand 2 SHR
    2 input-operand 1 input-operand ADD
    2 input-operand string-offset [+]
    0 input-operand >register-16 MOV ;

: userenv@ ( n -- addr ) cells "userenv" f dlsym + ;

M: %getenv generate-node ( vop -- )
    drop
    0 output-operand 0 input userenv@ MOV
    0 input rel-absolute-cell rel-userenv
    0 output-operand dup [] MOV ;

M: %setenv generate-node ( vop -- )
    drop
    0 scratch 1 input userenv@ MOV
    1 input rel-absolute-cell rel-userenv
    0 scratch [] 0 input-operand MOV ;
