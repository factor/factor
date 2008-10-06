! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays cpu.x86.assembler
cpu.x86.assembler.private cpu.architecture kernel kernel.private
math memory namespaces make sequences words compiler.generator
compiler.generator.registers compiler.generator.fixup system
layouts combinators compiler.constants math.order ;
IN: cpu.x86.architecture

HOOK: ds-reg cpu ( -- reg )
HOOK: rs-reg cpu ( -- reg )
HOOK: stack-reg cpu ( -- reg )

: stack@ ( n -- op ) stack-reg swap [+] ;

: next-stack@ ( n -- operand )
    #! nth parameter from the next stack frame. Used to box
    #! input values to callbacks; the callback has its own
    #! stack frame set up, and we want to read the frame
    #! set up by the caller.
    stack-frame get total-size>> + stack@ ;

: reg-stack ( n reg -- op ) swap cells neg [+] ;

M: ds-loc v>operand n>> ds-reg reg-stack ;
M: rs-loc v>operand n>> rs-reg reg-stack ;

M: int-regs %save-param-reg drop >r stack@ r> MOV ;
M: int-regs %load-param-reg drop swap stack@ MOV ;

GENERIC: MOVSS/D ( dst src reg-class -- )

M: single-float-regs MOVSS/D drop MOVSS ;

M: double-float-regs MOVSS/D drop MOVSD ;

M: float-regs %save-param-reg >r >r stack@ r> r> MOVSS/D ;
M: float-regs %load-param-reg >r swap stack@ r> MOVSS/D ;

GENERIC: push-return-reg ( reg-class -- )
GENERIC: load-return-reg ( n reg-class -- )
GENERIC: store-return-reg ( n reg-class -- )

! Only used by inline allocation
HOOK: temp-reg-1 cpu ( -- reg )
HOOK: temp-reg-2 cpu ( -- reg )

HOOK: fixnum>slot@ cpu ( op -- )

HOOK: prepare-division cpu ( -- )

M: immediate load-literal v>operand swap v>operand MOV ;

: align-stack ( n -- n' )
    os macosx? [ 16 align ] when ;

M: x86 stack-frame-size ( n -- i )
    3 cells + align-stack ;

M: x86 %save-word-xt ( -- )
    temp-reg v>operand 0 MOV rc-absolute-cell rel-this ;

: decr-stack-reg ( n -- )
    dup 0 = [ drop ] [ stack-reg swap SUB ] if ;

M: x86 %prologue ( n -- )
    dup PUSH
    temp-reg v>operand PUSH
    3 cells - decr-stack-reg ;

: incr-stack-reg ( n -- )
    dup 0 = [ ] [ stack-reg swap ADD ] if ;

M: x86 %epilogue ( n -- ) cell - incr-stack-reg ;

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
