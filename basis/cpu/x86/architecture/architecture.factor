! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.compiler arrays
cpu.x86.assembler cpu.x86.assembler.private cpu.architecture
kernel kernel.private math memory namespaces sequences words
generator generator.registers generator.fixup system layouts
combinators compiler.constants math.order ;
IN: cpu.x86.architecture

HOOK: ds-reg cpu ( -- reg )
HOOK: rs-reg cpu ( -- reg )
HOOK: stack-reg cpu ( -- reg )
HOOK: stack-save-reg cpu ( -- reg )

: stack@ ( n -- op ) stack-reg swap [+] ;

: reg-stack ( n reg -- op ) swap cells neg [+] ;

M: ds-loc v>operand ds-loc-n ds-reg reg-stack ;
M: rs-loc v>operand rs-loc-n rs-reg reg-stack ;

M: int-regs %save-param-reg drop >r stack@ r> MOV ;
M: int-regs %load-param-reg drop swap stack@ MOV ;

GENERIC: MOVSS/D ( dst src reg-class -- )

M: single-float-regs MOVSS/D drop MOVSS ;

M: double-float-regs MOVSS/D drop MOVSD ;

M: float-regs %save-param-reg >r >r stack@ r> r> MOVSS/D ;
M: float-regs %load-param-reg >r swap stack@ r> MOVSS/D ;

GENERIC: push-return-reg ( reg-class -- )
GENERIC: load-return-reg ( stack@ reg-class -- )
GENERIC: store-return-reg ( stack@ reg-class -- )

! Only used by inline allocation
HOOK: temp-reg-1 cpu ( -- reg )
HOOK: temp-reg-2 cpu ( -- reg )

HOOK: address-operand cpu ( address -- operand )

HOOK: fixnum>slot@ cpu ( op -- )

HOOK: prepare-division cpu ( -- )

M: immediate load-literal v>operand swap v>operand MOV ;

M: x86 stack-frame ( n -- i )
    3 cells + 16 align cell - ;

M: x86 %save-word-xt ( -- )
    temp-reg v>operand 0 MOV rc-absolute-cell rel-this ;

: factor-area-size ( -- n ) 4 cells ;

M: x86 %prologue ( n -- )
    dup cell + PUSH
    temp-reg v>operand PUSH
    stack-reg swap 2 cells - SUB ;

M: x86 %epilogue ( n -- )
    stack-reg swap ADD ;

HOOK: %alien-global cpu ( symbol dll register -- )

M: x86 %prepare-alien-invoke
    #! Save Factor stack pointers in case the C code calls a
    #! callback which does a GC, which must reliably trace
    #! all roots.
    "stack_chain" f temp-reg v>operand %alien-global
    temp-reg v>operand [] stack-reg MOV
    temp-reg v>operand [] cell SUB
    temp-reg v>operand 2 cells [+] ds-reg MOV
    temp-reg v>operand 3 cells [+] rs-reg MOV ;

M: x86 %call ( label -- ) CALL ;

M: x86 %jump-label ( label -- ) JMP ;

M: x86 %jump-f ( label -- )
    "flag" operand f v>operand CMP JE ;

: code-alignment ( -- n )
    building get length dup cell align swap - ;

: align-code ( n -- )
    0 <repetition> % ;

M: x86 %dispatch ( -- )
    [
        %epilogue-later
        ! Load jump table base. We use a temporary register
        ! since on AMD64 we have to load a 64-bit immediate. On
        ! x86, this is redundant.
        ! Untag and multiply to get a jump table offset
        "n" operand fixnum>slot@
        ! Add jump table base
        "offset" operand HEX: ffffffff MOV rc-absolute-cell rel-here
        "n" operand "offset" operand ADD
        "n" operand HEX: 7f [+] JMP
        ! Fix up the displacement above
        code-alignment dup bootstrap-cell 8 = 15 9 ? +
        building get dup pop* push
        align-code
    ] H{
        { +input+ { { f "n" } } }
        { +scratch+ { { f "offset" } } }
        { +clobber+ { "n" } }
    } with-template ;

M: x86 %dispatch-label ( word -- )
    0 cell, rc-absolute-cell rel-word ;

M: x86 %unbox-float ( dst src -- )
    [ v>operand ] bi@ float-offset [+] MOVSD ;

M: x86 %peek [ v>operand ] bi@ MOV ;

M: x86 %replace swap %peek ;

: (%inc) ( n reg -- ) swap cells dup 0 > [ ADD ] [ neg SUB ] if ;

M: x86 %inc-d ( n -- ) ds-reg (%inc) ;

M: x86 %inc-r ( n -- ) rs-reg (%inc) ;

M: x86 fp-shadows-int? ( -- ? ) f ;

M: x86 value-structs? t ;

M: x86 small-enough? ( n -- ? )
    HEX: -80000000 HEX: 7fffffff between? ;

: %untag ( reg -- ) tag-mask get bitnot AND ;

: %untag-fixnum ( reg -- ) tag-bits get SAR ;

: %tag-fixnum ( reg -- ) tag-bits get SHL ;

: temp@ ( n -- op ) stack-reg \ stack-frame get rot - [+] ;

: struct-return@ ( size n -- n )
    [
        stack-frame* cell + +
    ] [
        \ stack-frame get swap -
    ] ?if ;

HOOK: %unbox-struct-1 cpu ( -- )

HOOK: %unbox-struct-2 cpu ( -- )

M: x86 %unbox-small-struct ( size -- )
    #! Alien must be in EAX.
    cell align cell /i {
        { 1 [ %unbox-struct-1 ] }
        { 2 [ %unbox-struct-2 ] }
    } case ;

M: x86 struct-small-enough? ( size -- ? )
    { 1 2 4 8 } member?
    os { linux netbsd solaris } member? not and ;

M: x86 %return ( -- ) 0 %unwind ;

! Alien intrinsics
M: x86 %unbox-byte-array ( dst src -- )
    [ v>operand ] bi@ byte-array-offset [+] LEA ;

M: x86 %unbox-alien ( dst src -- )
    [ v>operand ] bi@ alien-offset [+] MOV ;

M: x86 %unbox-f ( dst src -- )
    drop v>operand 0 MOV ;

M: x86 %unbox-any-c-ptr ( dst src -- )
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
    rs-reg header-offset [+] alien type-number tag-fixnum CMP
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
