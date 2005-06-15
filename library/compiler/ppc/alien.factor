! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler kernel math ;

M: %alien-invoke generate-node ( vop -- )
    dup vop-in-1 swap vop-in-2 load-library compile-c-call ;

: stack-reserve 8 + 16 align ;
: stack@ 12 + ;

M: %parameters generate-node ( vop -- )
    vop-in-1 dup 0 =
    [ drop ] [ stack-reserve 1 1 rot SUBI ] ifte ;

GENERIC: store-insn
GENERIC: load-insn
GENERIC: return-reg

M: int-regs store-insn drop STW ;
M: int-regs return-reg drop 3 ;
M: int-regs load-insn drop 3 + 1 rot LWZ ;

M: float-regs store-insn
    float-regs-size 4 = [ STFS ] [ STFD ] ifte ;
M: float-regs return-reg drop 1 ;
M: float-regs load-insn
    >r 1 + 1 rot r> float-regs-size 4 = [ LFS ] [ LFD ] ifte ;

M: %unbox generate-node ( vop -- )
    [ vop-in-2 f compile-c-call ] keep
    [ vop-in-3 return-reg 1 ] keep
    [ vop-in-1 stack@ ] keep
    vop-in-3 store-insn ; 

M: %parameter generate-node ( vop -- )
    dup vop-in-1 stack@
    over vop-in-2
    rot vop-in-3 load-insn ;

M: %box generate-node ( vop -- )
    vop-in-1 f compile-c-call ;

M: %cleanup generate-node ( vop -- )
    vop-in-1 dup 0 =
    [ drop ] [ stack-reserve 1 1 rot ADDI ] ifte ;
