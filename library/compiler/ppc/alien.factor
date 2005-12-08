! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler kernel math ;

M: %alien-invoke generate-node ( vop -- )
    drop 0 input 1 input load-library compile-c-call ;

GENERIC: store-insn
GENERIC: load-insn
GENERIC: return-reg

M: int-regs store-insn drop stack@ STW ;
M: int-regs return-reg drop 3 ;
M: int-regs load-insn drop 3 + 1 rot stack@ LWZ ;

M: float-regs store-insn
    >r stack@ r> float-regs-size 4 = [ STFS ] [ STFD ] if ;
M: float-regs return-reg drop 1 ;
M: float-regs load-insn
    >r 1+ 1 rot stack@ r> 
    float-regs-size 4 = [ LFS ] [ LFD ] if ;

M: stack-params load-insn ( from to reg-class -- )
    drop >r 0 1 rot stack@ LWZ 0 1 r> stack@ STW ;

M: %unbox generate-node ( vop -- )
    drop
    1 input f compile-c-call
    2 input return-reg
    1 0 input 2 input store-insn ;

M: %parameter generate-node ( vop -- )
    drop 0 input 1 input 2 input load-insn ;

M: %box generate-node ( vop -- ) drop 0 input f compile-c-call ;

M: %cleanup generate-node ( vop -- ) drop ;
