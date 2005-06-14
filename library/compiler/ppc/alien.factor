! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: assembler
USING: alien compiler compiler-backend inference kernel
kernel-internals lists math memory namespaces words ;

M: %alien-invoke generate-node ( vop -- )
    dup vop-in-1 swap vop-in-2 load-library compile-c-call ;

: stack-size 8 + 16 align ;
: stack@ 3 + cell * ;

M: %parameters generate-node ( vop -- )
    vop-in-1 dup 0 = [ drop ] [ stack-size 1 1 rot SUBI ] ifte ;

GENERIC: store-insn
GENERIC: return-reg

M: int-regs store-insn drop STW ;
M: int-regs return-reg drop 3 ;

M: float-regs store-insn drop STFS ;
M: float-regs return-reg drop 1 ;

M: double-regs store-insn drop STFD ;
M: double-regs return-reg drop 1 ;

M: %unbox generate-node ( vop -- )
    [ vop-in-2 f compile-c-call ] keep
    [ vop-in-3 return-reg 1 ] keep
    [ vop-in-1 stack@ ] keep
    vop-in-3 store-insn ; 

M: %parameter generate-node ( vop -- )
    vop-in-1 dup 3 + 1 rot stack@ LWZ ;

M: %box generate-node ( vop -- )
    vop-in-1 f compile-c-call ;

M: %cleanup generate-node ( vop -- )
    vop-in-1 dup 0 = [ drop ] [ stack-size 1 1 rot ADDI ] ifte ;
