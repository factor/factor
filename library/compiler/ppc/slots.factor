! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler compiler inference kernel
kernel-internals lists math memory namespaces sequences words ;

: generate-slot ( size quot -- )
    >r >r
    ! turn tagged fixnum slot # into an offset, multiple of 4
    0 input-operand dup tag-bits r> - SRAWI
    ! compute slot address
    0 output-operand dup 0 input-operand ADD
    ! load slot value
    0 output-operand dup r> call ; inline

M: %slot generate-node ( vop -- )
    drop cell log2 [ 0 LWZ ] generate-slot ;

M: %fast-slot generate-node ( vop -- )
    drop 0 output-operand dup 0 input LWZ ;

: generate-set-slot ( size quot -- )
    >r >r
    ! turn tagged fixnum slot # into an offset, multiple of 4
    2 input-operand dup tag-bits r> - SRAWI
    ! compute slot address in 1st input
    2 input-operand dup 1 input-operand ADD
    ! store new slot value
    0 input-operand 2 input-operand r> call ; inline

M: %set-slot generate-node ( vop -- )
    drop cell log2 [ 0 STW ] generate-set-slot ;

M: %fast-set-slot generate-node ( vop -- )
    drop 0 input-operand 1 input-operand 2 input STW ;

M: %write-barrier generate-node ( vop -- )
    #! Mark the card pointed to by vreg.
    drop
    0 input-operand dup card-bits SRAWI
    0 input-operand dup 16 ADD
    0 scratch 0 input-operand 0 LBZ
    0 scratch dup card-mark ORI
    0 scratch 0 input-operand 0 STB ;

: string-offset cell 3 * object-tag - ;

M: %char-slot generate-node ( vop -- )
    drop 1 [ string-offset LHZ ] generate-slot
    0 output-operand dup tag-fixnum ;

M: %set-char-slot generate-node ( vop -- )
    ! untag the new value in 0th input
    drop 0 input-operand dup untag-fixnum
    1 [ string-offset STH ] generate-set-slot ;

: userenv ( reg -- )
    #! Load the userenv pointer in a virtual register.
    "userenv" f dlsym swap LOAD32 0 rel-2/2 rel-userenv ;

M: %getenv generate-node ( vop -- )
    drop 0 output-operand dup dup userenv 0 input cell * LWZ ;

M: %setenv generate-node ( vop -- )
    drop 0 scratch userenv
    0 input-operand 0 scratch 1 input cell * STW ;
