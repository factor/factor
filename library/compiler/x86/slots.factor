! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler compiler inference kernel
kernel-internals lists math memory namespaces sequences words ;

M: %slot generate-node ( vop -- )
    dest/src
    ! turn tagged fixnum slot # into an offset, multiple of 4
    dup 1 SHR
    ! compute slot address in vop-out-1
    dupd ADD
    ! load slot value in vop-out-1
    dup unit MOV ;

M: %fast-slot generate-node ( vop -- )
    dup vop-in-1 swap vop-out-1 v>operand tuck >r 2list r>
    swap MOV ;

: card-offset 1 getenv ;

: write-barrier ( reg -- )
    #! Mark the card pointed to by vreg.
    dup card-bits SHR
    card-offset 2list card-mark OR
    0 rel-cards ;

M: %set-slot generate-node ( vop -- )
    dup vop-in-3 v>operand over vop-in-2 v>operand
    ! turn tagged fixnum slot # into an offset, multiple of 4
    over 1 SHR
    ! compute slot address in vop-in-2
    2dup ADD
    ! store new slot value
    >r >r vop-in-1 v>operand r> unit swap MOV r>
    write-barrier ;

M: %fast-set-slot generate-node ( vop -- )
    dup vop-in-3 over vop-in-2 v>operand
    [ swap 2list swap vop-in-1 v>operand MOV ] keep
    write-barrier ;

: userenv@ ( n -- addr )
    cell * "userenv" f dlsym + ;

M: %getenv generate-node ( vop -- )
    dup vop-out-1 v>operand swap vop-in-1
    [ userenv@ unit MOV ] keep 0 rel-userenv ;

M: %setenv generate-node ( vop -- )
    dup vop-in-2
    [ userenv@ unit swap vop-in-1 v>operand MOV ] keep
    0 rel-userenv ;
