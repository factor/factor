! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler compiler inference kernel
kernel-internals lists math memory namespaces sequences words ;

M: %slot generate-node ( vop -- )
    #! the untagged object is in vop-dest, the tagged slot
    #! number is in vop-source.
    dest/src
    ! turn tagged fixnum slot # into an offset, multiple of 4
    dup 1 SHR
    ! compute slot address in vop-dest
    dupd ADD
    ! load slot value in vop-dest
    dup unit MOV ;

M: %fast-slot generate-node ( vop -- )
    #! the tagged object is in vop-dest, the pointer offset is
    #! in vop-literal. the offset already takes the type tag
    #! into account, so its just one instruction to load.
    dup vop-literal swap vop-dest v>operand tuck >r 2list r>
    swap MOV ;

! : card-bits 5 ;
! 
! : card-offset ( -- n )
!     #! We add this to an address that was shifted by card-bits
!     #! to get the address of its card.
!     
!     ;
! 
! : write-barrier ( vreg -- )
!     #! Mark the card pointed to by vreg.
!     
!     ;

M: %set-slot generate-node ( vop -- )
    #! the untagged object is in vop-dest, the new value is in
    #! vop-source, the tagged slot number is in vop-literal.
    dup vop-literal v>operand over vop-dest v>operand
    ! turn tagged fixnum slot # into an offset, multiple of 4
    over 1 SHR
    ! compute slot address in vop-dest
    dupd ADD
    ! store new slot value
    >r vop-source v>operand r> unit swap MOV ;

M: %fast-set-slot generate-node ( vop -- )
    #! the tagged object is in vop-dest, the new value is in
    #! vop-source, the pointer offset is in vop-literal. the
    #! offset already takes the type tag into account, so its
    #! just one instruction to load.
    dup vop-literal over vop-dest v>operand swap 2list
    swap vop-source v>operand MOV ;
