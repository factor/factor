! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.compiler arrays
cpu.x86.assembler cpu.architecture kernel kernel.private math
math.functions memory namespaces sequences words generator
generator.registers generator.fixup system layouts combinators ;
IN: cpu.x86.architecture

TUPLE: x86-backend cell ;

HOOK: ds-reg compiler-backend
HOOK: rs-reg compiler-backend
HOOK: stack-reg compiler-backend
HOOK: xt-reg compiler-backend
HOOK: stack-save-reg compiler-backend

: stack@ stack-reg swap [+] ;

: reg-stack ( n reg -- op ) swap cells neg [+] ;

M: ds-loc v>operand ds-loc-n ds-reg reg-stack ;
M: rs-loc v>operand rs-loc-n rs-reg reg-stack ;

M: int-regs %save-param-reg drop >r stack@ r> MOV ;
M: int-regs %load-param-reg drop swap stack@ MOV ;

: MOVSS/D float-regs-size 4 = [ MOVSS ] [ MOVSD ] if ;

M: float-regs %save-param-reg >r >r stack@ r> r> MOVSS/D ;
M: float-regs %load-param-reg >r swap stack@ r> MOVSS/D ;

GENERIC: push-return-reg ( reg-class -- )
GENERIC: load-return-reg ( stack@ reg-class -- )
GENERIC: store-return-reg ( stack@ reg-class -- )

HOOK: address-operand compiler-backend ( address -- operand )

HOOK: fixnum>slot@ compiler-backend

HOOK: prepare-division compiler-backend

M: immediate load-literal v>operand swap v>operand MOV ;

M: x86-backend stack-frame ( n -- i )
    3 cells + 16 align cell - ;

M: x86-backend %save-xt ( -- )
    xt-reg compiling-label get MOV ;

: factor-area-size 4 cells ;

M: x86-backend %prologue ( n -- )
    xt-reg PUSH
    xt-reg stack-reg pick factor-area-size + neg [+] LEA
    xt-reg PUSH
    stack-reg swap 2 cells - SUB ;

M: x86-backend %epilogue ( n -- )
    stack-reg swap ADD ;

: %alien-global ( symbol dll register -- )
    [ 0 MOV rc-absolute-cell rel-dlsym ] keep dup [] MOV ;

M: x86-backend %prepare-alien-invoke
    #! Save Factor stack pointers in case the C code calls a
    #! callback which does a GC, which must reliably trace
    #! all roots.
    "stack_chain" f temp-reg v>operand %alien-global
    temp-reg v>operand [] stack-reg MOV
    temp-reg v>operand 2 cells [+] ds-reg MOV
    temp-reg v>operand 3 cells [+] rs-reg MOV ;

M: x86-backend %profiler-prologue ( word -- )
    "end" define-label
    "profiling" f temp-reg v>operand %alien-global
    temp-reg v>operand 0 CMP
    "end" get JE
    temp-reg load-literal
    temp-reg v>operand profile-count-offset [+] 1 v>operand ADD
    "end" resolve-label ;

M: x86-backend %call-label ( label -- ) CALL ;

M: x86-backend %jump-label ( label -- ) JMP ;

: %prepare-primitive ( word -- operand )
    ! Save stack pointer to stack_chain->callstack_top, load XT
    ! in register
    stack-save-reg stack-reg MOV address-operand ;

M: x86-backend %call-primitive ( word -- )
    stack-save-reg stack-reg cell neg [+] LEA
    address-operand CALL ;

M: x86-backend %jump-primitive ( word -- )
    stack-save-reg stack-reg MOV
    address-operand JMP ;

M: x86-backend %jump-t ( label -- )
    "flag" operand f v>operand CMP JNE ;

: (%dispatch) ( word-table# -- )
    ! Untag and multiply to get a jump table offset
    "n" operand fixnum>slot@
    ! Add to jump table base. We use a temporary register
    ! since on AMD64 we have to load a 64-bit immediate. On
    ! x86, this is redundant.
    "scratch" operand HEX: ffffffff MOV rc-absolute-cell rel-dispatch
    "n" operand "scratch" operand ADD ;

: dispatch-template ( word-table# quot -- )
    [
        >r (%dispatch) "n" operand [] r> call
    ] H{
        { +input+ { { f "n" } } }
        { +scratch+ { { f "scratch" } } }
    } with-template ; inline

M: x86-backend %call-dispatch ( word-table# -- )
    [ CALL ] dispatch-template ;

M: x86-backend %jump-dispatch ( word-table# -- )
    [ %epilogue-later JMP ] dispatch-template ;

M: x86-backend %unbox-float ( dst src -- )
    [ v>operand ] 2apply float-offset [+] MOVSD ;

M: x86-backend %peek [ v>operand ] 2apply MOV ;

M: x86-backend %replace swap %peek ;

: (%inc) swap cells dup 0 > [ ADD ] [ neg SUB ] if ;

M: x86-backend %inc-d ( n -- ) ds-reg (%inc) ;

M: x86-backend %inc-r ( n -- ) rs-reg (%inc) ;

M: x86-backend fp-shadows-int? ( -- ? ) f ;

M: x86-backend value-structs? t ;

M: x86-backend small-enough? ( n -- ? )
    HEX: -80000000 HEX: 7fffffff between? ;

: %untag ( reg -- ) tag-mask get bitnot AND ;

: %untag-fixnum ( reg -- ) tag-bits get SAR ;

: %tag-fixnum ( reg -- ) tag-bits get SHL ;

: temp@ stack-reg \ stack-frame get rot - [+] ;

: struct-return@ ( size n -- n )
    [
        stack-frame* cell + +
    ] [
        \ stack-frame get swap -
    ] ?if ;

HOOK: %unbox-struct-1 compiler-backend ( -- )

HOOK: %unbox-struct-2 compiler-backend ( -- )

M: x86-backend %unbox-small-struct ( size -- )
    #! Alien must be in EAX.
    cell align cell / {
        { 1 [ %unbox-struct-1 ] }
        { 2 [ %unbox-struct-2 ] }
    } case ;

M: x86-backend struct-small-enough? ( size -- ? )
    { 1 2 4 8 } member?
    os { "linux" "solaris" } member? not and ;

M: x86-backend %return ( -- ) 0 %unwind ;

! Alien intrinsics
M: x86-backend %unbox-byte-array ( dst src -- )
    [ v>operand ] 2apply byte-array-offset [+] LEA ;

M: x86-backend %unbox-alien ( dst src -- )
    [ v>operand ] 2apply alien-offset [+] MOV ;

M: x86-backend %unbox-f ( dst src -- )
    drop v>operand 0 MOV ;

M: x86-backend %unbox-any-c-ptr ( dst src -- )
    { "is-byte-array" "end" "start" } [ define-label ] each
    ! Address is computed in ds-reg
    ds-reg PUSH
    ds-reg 0 MOV
    ! Object is stored in ds-reg
    rs-reg PUSH
    rs-reg swap v>operand MOV
    ! We come back here with displaced aliens
    "start" resolve-label
    ! Is the object f?
    rs-reg f v>operand CMP
    "end" get JE
    ! Is the object an alien?
    rs-reg header-offset [+] alien type-number tag-header CMP
    "is-byte-array" get JNE
    ! If so, load the offset and add it to the address
    ds-reg rs-reg alien-offset [+] ADD
    ! Now recurse on the underlying alien
    rs-reg rs-reg underlying-alien-offset [+] MOV
    "start" get JMP
    "is-byte-array" resolve-label
    ! Add byte array address to address being computed
    ds-reg rs-reg ADD
    ! Add an offset to start of byte array's data
    ds-reg byte-array-offset ADD
    "end" resolve-label
    ! Done, store address in destination register
    v>operand ds-reg MOV
    ! Restore rs-reg
    rs-reg POP
    ! Restore ds-reg
    ds-reg POP ;
