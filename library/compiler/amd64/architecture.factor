IN: compiler-backend
USING: assembler compiler-backend kernel sequences ;

! AMD64 register assignments
! RAX RCX RDX RSI RDI R8 R9 R10 R11 vregs
! R14 datastack
! R15 callstack

: fixnum-imm? ( -- ? )
    #! Can fixnum operations take immediate operands?
    f ; inline

: ds-reg R14 ; inline
: cs-reg R15 ; inline
: return-reg RAX ; inline
: remainder-reg RDX ; inline

: vregs { RAX RCX RDX RSI RDI R8 R9 R10 R11 } ; inline

: param-regs { R9 R8 RCX RDX RSI RDI } ;

DEFER: compile-c-call

: compile-c-call* ( symbol dll -- operands )
    param-regs swap [ MOV ] 2each compile-c-call ;

! FIXME
M: int-regs fastcall-regs drop 0 ;
M: int-regs reg-class-size drop 4 ;
M: float-regs fastcall-regs drop 0 ;

: dual-fp/int-regs? f ;

: address-operand ( address -- operand )
    #! On AMD64, we have to load 64-bit addresses into a
    #! scratch register first. The usage of R11 here is a hack.
    #! We cannot write '0 scratch' since scratch registers are
    #! not permitted inside basic-block VOPs.
    R11 [ swap MOV ] keep ; inline

: fixnum>slot@ drop ; inline

: prepare-division CQO ; inline
