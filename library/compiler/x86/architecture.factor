! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays assembler generic kernel kernel-internals
math memory namespaces sequences words ;
IN: compiler

! x86 register assignments
! EAX, ECX, EDX vregs
! ESI datastack
! EBX callstack

! AMD64 redefines these four
: ds-reg ESI ; inline
: cs-reg EBX ; inline
: remainder-reg EDX ; inline
: vregs { EAX ECX EDX } ; inline

: reg-stack ( n reg -- op ) swap cells neg [+] ;

M: ds-loc v>operand ds-loc-n ds-reg reg-stack ;

M: cs-loc v>operand cs-loc-n cs-reg reg-stack ;

: %alien-invoke ( symbol dll -- )
    2dup dlsym CALL rel-relative rel-dlsym ;

: compile-c-call* ( symbol dll args -- operands )
    reverse-slice
    [ [ PUSH ] each %alien-invoke ] keep
    [ drop EDX POP ] each ;

! On x86, parameters are never passed in registers.
M: int-regs return-reg drop EAX ;
M: int-regs fastcall-regs drop { } ;

M: float-regs fastcall-regs drop { } ;

: address-operand ( address -- operand )
    #! On x86, we can always use an address as an operand
    #! directly.
    ; inline

: fixnum>slot@ 1 SHR ; inline

: prepare-division CDQ ; inline

M: immediate load-literal ( literal vreg -- )
    v>operand swap address MOV ;

M: object load-literal ( literal vreg -- )
    v>operand swap
    add-literal [] MOV rel-absolute-cell rel-address ;

: (%call) ( label -- label )
    dup postpone-word dup primitive? [ address-operand ] when ;

: %call ( label -- ) (%call) CALL ;

: %jump ( label -- ) %epilogue (%call) JMP ;

: %jump-label ( label -- ) JMP ;

: %jump-t ( label -- ) "flag" operand f v>operand CMP JNE ;

: %dispatch ( -- )
    #! Compile a piece of code that jumps to an offset in a
    #! jump table indexed by the fixnum at the top of the stack.
    #! The jump table must immediately follow this macro.
    <label> "end" set
    ! Untag and multiply to get a jump table offset
    "n" operand fixnum>slot@
    ! Add to jump table base. We use a temporary register since
    ! on AMD4 we have to load a 64-bit immediate. On x86, this
    ! is redundant.
    "scratch" operand HEX: ffffffff MOV "end" get absolute-cell
    "n" operand "scratch" operand ADD
    ! Jump to jump table entry
    "n" operand [] JMP
    ! Align for better performance
    compile-aligned
    ! Fix up jump table pointer
    "end" get save-xt ;

: %return ( -- ) %epilogue RET ;

: %peek ( vreg loc -- ) [ v>operand ] 2apply MOV ;

: %replace ( vreg loc -- ) swap %peek ;

: (%inc) swap cells dup 0 > [ ADD ] [ neg SUB ] if ;

: %inc-d ( n -- ) ds-reg (%inc) ;

: %inc-r ( n -- ) cs-reg (%inc) ;
