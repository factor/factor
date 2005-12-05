! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien arrays assembler compiler inference kernel
kernel-internals lists math memory namespaces sequences words ;

M: %slot generate-node ( vop -- )
    drop
    ! turn tagged fixnum slot # into an offset, multiple of 4
    0 input-operand 1 SHR
    ! compute slot address in 0 vop-out
    0 output-operand 0 input-operand ADD
    ! load slot value in 0 vop-out
    0 output-operand dup 1array MOV ;

M: %fast-slot generate-node ( vop -- )
    drop
    0 output-operand 1 input-operand 0 input 2array MOV ;

: card-offset 1 getenv ;

M: %write-barrier generate-node ( vop -- )
    #! Mark the card pointed to by vreg.
    drop
    0 input-operand dup card-bits SHR
    card-offset 2array card-mark OR
    0 rel-cards ;

M: %set-slot generate-node ( vop -- )
    drop
    ! turn tagged fixnum slot # into an offset, multiple of 4
    2 input-operand 1 SHR
    ! compute slot address in 1 vop-in
    2 input-operand 1 input-operand ADD
    ! store new slot value
    0 output-operand 1 input-operand 1array MOV ;

M: %fast-set-slot generate-node ( vop -- )
    drop
    1 input-operand 2 input 2array 0 output-operand MOV ;

: userenv@ ( n -- addr ) cell * "userenv" f dlsym + ;

M: %getenv generate-node ( vop -- )
    drop
    0 output-operand 0 input userenv@ 1array MOV
    0 input 0 rel-userenv ;

M: %setenv generate-node ( vop -- )
    drop
    1 input userenv@ 1array 0 input-operand MOV
    1 input rel-userenv ;
