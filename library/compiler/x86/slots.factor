! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien arrays assembler compiler inference kernel
kernel-internals lists math memory namespaces sequences words ;

M: %slot generate-node ( vop -- )
    dest/src
    ! turn tagged fixnum slot # into an offset, multiple of 4
    dup 1 SHR
    ! compute slot address in 0 vop-out
    dupd ADD
    ! load slot value in 0 vop-out
    dup 1array MOV ;

M: %fast-slot generate-node ( vop -- )
    dup 0 vop-in swap 0 vop-out v>operand tuck >r 2array r>
    swap MOV ;

: card-offset 1 getenv ;

M: %write-barrier generate-node ( vop -- )
    #! Mark the card pointed to by vreg.
    0 vop-in v>operand
    dup card-bits SHR
    card-offset 2array card-mark OR
    0 rel-cards ;

M: %set-slot generate-node ( vop -- )
    dup 2 vop-in v>operand over 1 vop-in v>operand
    ! turn tagged fixnum slot # into an offset, multiple of 4
    over 1 SHR
    ! compute slot address in 1 vop-in
    dupd ADD
    ! store new slot value
    >r 0 vop-in v>operand r> 1array swap MOV ;

M: %fast-set-slot generate-node ( vop -- )
    dup 2 vop-in over 1 vop-in v>operand
    swap 2array swap 0 vop-in v>operand MOV ;

: userenv@ ( n -- addr )
    cell * "userenv" f dlsym + ;

M: %getenv generate-node ( vop -- )
    dup 0 vop-out v>operand swap 0 vop-in
    [ userenv@ 1array MOV ] keep 0 rel-userenv ;

M: %setenv generate-node ( vop -- )
    dup 1 vop-in
    [ userenv@ 1array swap 0 vop-in v>operand MOV ] keep
    0 rel-userenv ;
