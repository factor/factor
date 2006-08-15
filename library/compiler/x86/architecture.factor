! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays assembler generic kernel kernel-internals
math memory namespaces sequences words ;
IN: compiler

: code-format 1 ; inline

! x86 register assignments
! EAX, ECX, EDX integer vregs
! XMM0 - XMM7 float vregs
! ESI datastack
! EDI callstack

! AMD64 redefines a lot of words in this file

: ds-reg ESI ; inline
: cs-reg EDI ; inline
: remainder-reg EDX ; inline
: alloc-tmp-reg EBX ; inline
: stack-reg ESP ; inline
: stack@ stack-reg swap [+] ;

: reg-stack ( n reg -- op ) swap cells neg [+] ;

M: ds-loc v>operand ds-loc-n ds-reg reg-stack ;
M: cs-loc v>operand cs-loc-n cs-reg reg-stack ;

: %alien-invoke ( symbol dll -- ) (CALL) rel-dlsym ;

: with-aligned-stack ( n quot -- )
    #! On Linux, there is no requirement to align stack frames,
    #! so this is mostly a no-op.
    swap slip stack-reg swap ADD ; inline

: compile-c-call* ( symbol dll args -- operands )
    dup length cells [
        <reversed> [ PUSH ] each %alien-invoke
    ] with-aligned-stack ;

GENERIC: push-return-reg ( reg-class -- )
GENERIC: pop-return-reg ( reg-class -- )
GENERIC: load-return-reg ( stack@ reg-class -- )
GENERIC: store-return-reg ( stack@ reg-class -- )

! On x86, parameters are never passed in registers.
M: int-regs return-reg drop EAX ;
M: int-regs fastcall-regs drop { } ;
M: int-regs vregs drop { EAX ECX EDX } ;
M: int-regs %freg>stack drop >r stack@ r> MOV ;
M: int-regs %stack>freg drop swap stack@ MOV ;
M: int-regs push-return-reg return-reg PUSH ;
M: int-regs pop-return-reg return-reg POP ;
: load/store-int-return return-reg stack-reg rot [+] ;
M: int-regs load-return-reg load/store-int-return MOV ;
M: int-regs store-return-reg load/store-int-return swap MOV ;

: MOVSS/D float-regs-size 4 = [ MOVSS ] [ MOVSD ] if ;

M: float-regs fastcall-regs drop { } ;
M: float-regs vregs drop { XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7 } ;
M: float-regs %freg>stack >r >r stack@ r> r> MOVSS/D ;
M: float-regs %stack>freg >r swap stack@ r> MOVSS/D ;

: FSTP 4 = [ FSTPS ] [ FSTPL ] if ;

M: float-regs push-return-reg
    stack-reg swap reg-size [ SUB  stack-reg [] ] keep FSTP ;

: FLD 4 = [ FLDS ] [ FLDL ] if ;

: drop-return-reg stack-reg swap reg-size ADD ;

M: float-regs pop-return-reg
    stack-reg [] over reg-size FLD drop-return-reg ;

: load/store-float-return reg-size >r stack-reg swap [+] r> ;
M: float-regs load-return-reg load/store-float-return FLD ;
M: float-regs store-return-reg load/store-float-return FSTP ;

: address-operand ( address -- operand )
    #! On x86, we can always use an address as an operand
    #! directly.
    ; inline

: fixnum>slot@ 1 SHR ; inline

: prepare-division CDQ ; inline

M: immediate load-literal
    v>operand swap v>operand MOV ;

: load-indirect ( literal reg -- )
    0 [] MOV rel-absolute-cell rel-literal ;

M: object load-literal
    v>operand load-indirect ;

: (%call) ( label -- label )
    dup (compile) dup primitive? [ address-operand ] when ;

: %call ( label -- ) (%call) CALL ;

: %jump ( label -- ) %epilogue (%call) JMP ;

: %jump-label ( label -- ) JMP ;

: %jump-t ( label -- ) "flag" operand f v>operand CMP JNE ;

: compile-aligned ( -- )
    compiled-offset [ 8 align ] keep - 0 <array> % ;

: %dispatch ( -- )
    #! Compile a piece of code that jumps to an offset in a
    #! jump table indexed by the fixnum at the top of the stack.
    #! The jump table must immediately follow this macro.
    ! Untag and multiply to get a jump table offset
    "end" define-label
    "n" operand fixnum>slot@
    ! Add to jump table base. We use a temporary register since
    ! on AMD64 we have to load a 64-bit immediate. On x86, this
    ! is redundant.
    "scratch" operand HEX: ffffffff MOV
    "end" get rel-absolute-cell rel-label
    "n" operand "scratch" operand ADD
    ! Jump to jump table entry
    "n" operand [] JMP
    ! Align for better performance
    compile-aligned
    ! Fix up jump table pointer
    "end" get resolve-label ;

: %target ( label -- ) 0 cell, rel-absolute-cell rel-label ;

: %return ( -- ) %epilogue RET ;

: %move-int>int ( dst src -- )
    [ v>operand ] 2apply MOV ;

: %move-int>float ( dst src -- )
    [ v>operand ] 2apply float-offset [+] MOVSD ;

M: int-regs (%peek) drop %move-int>int ;

M: int-regs (%replace) drop swap %move-int>int ;

: (%inc) swap cells dup 0 > [ ADD ] [ neg SUB ] if ;

: %inc-d ( n -- ) ds-reg (%inc) ;

: %inc-r ( n -- ) cs-reg (%inc) ;

M: object %stack>freg 3drop ;

M: object %freg>stack 3drop ;
