! Copyright (C) 2007, 2011 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private compiler.constants
compiler.codegen.relocation compiler.units cpu.x86.assembler
cpu.x86.assembler.operands kernel kernel.private layouts
locals locals.backend make math math.private namespaces sequences
slots.private strings.private vocabs ;
IN: bootstrap.x86

big-endian off

! C to Factor entry point
[
    ! Optimizing compiler's side of callback accesses
    ! arguments that are on the stack via the frame pointer.
    ! On x86-32 fastcall, and x86-64, some arguments are passed
    ! in registers, and so the only registers that are safe for
    ! use here are frame-reg, nv-reg and vm-reg.
    frame-reg PUSH
    frame-reg stack-reg MOV

    ! Save all non-volatile registers
    nv-regs [ PUSH ] each

    jit-save-tib

    ! Load VM into vm-reg
    vm-reg 0 MOV 0 rc-absolute-cell rel-vm

    ! Save old context
    nv-reg vm-reg vm-context-offset [+] MOV
    nv-reg PUSH

    ! Switch over to the spare context
    nv-reg vm-reg vm-spare-context-offset [+] MOV
    vm-reg vm-context-offset [+] nv-reg MOV

    ! Save C callstack pointer
    nv-reg context-callstack-save-offset [+] stack-reg MOV

    ! Load Factor stack pointers
    stack-reg nv-reg context-callstack-bottom-offset [+] MOV
    nv-reg jit-update-tib
    jit-install-seh

    rs-reg nv-reg context-retainstack-offset [+] MOV
    ds-reg nv-reg context-datastack-offset [+] MOV

    ! Call into Factor code
    link-reg 0 MOV f rc-absolute-cell rel-word
    link-reg CALL

    ! Load VM into vm-reg; only needed on x86-32, but doesn't
    ! hurt on x86-64
    vm-reg 0 MOV 0 rc-absolute-cell rel-vm

    ! Load C callstack pointer
    nv-reg vm-reg vm-context-offset [+] MOV
    stack-reg nv-reg context-callstack-save-offset [+] MOV

    ! Load old context
    nv-reg POP
    vm-reg vm-context-offset [+] nv-reg MOV

    ! Restore non-volatile registers
    jit-restore-tib

    nv-regs <reversed> [ POP ] each

    frame-reg POP

    ! Callbacks which return structs, or use stdcall/fastcall/thiscall,
    ! need a parameter here.

    ! See the comment for M\ x86.32 stack-cleanup in cpu.x86.32
    0xffff RET f rc-absolute-2 rel-untagged
] callback-stub jit-define

[
    ! load literal
    temp0 0 MOV f rc-absolute-cell rel-literal
    ! increment datastack pointer
    ds-reg bootstrap-cell ADD
    ! store literal on datastack
    ds-reg [] temp0 MOV
] jit-push jit-define

[
    0 CALL f rc-relative rel-word-pic
] jit-word-call jit-define

! The *-signal-handler subprimitives are special-cased in vm/quotations.cpp
! not to trigger generation of a stack frame, so they can
! peform their own prolog/epilog preserving registers.

: jit-signal-handler-prolog ( -- )
    ! minus a cell each for flags, return address
    ! use LEA so we don't dirty flags
    stack-reg stack-reg signal-handler-stack-frame-size
    2 bootstrap-cells - neg [+] LEA

    signal-handler-save-regs
    [| r i | stack-reg i bootstrap-cells [+] r MOV ] each-index

    PUSHF

    jit-load-vm ;

: jit-signal-handler-epilog ( -- )
    POPF

    signal-handler-save-regs
    [| r i | r stack-reg i bootstrap-cells [+] MOV ] each-index

    stack-reg stack-reg signal-handler-stack-frame-size
    2 bootstrap-cells - [+] LEA ;

[| |
    jit-signal-handler-prolog
    jit-save-context
    temp0 vm-reg vm-signal-handler-addr-offset [+] MOV
    temp0 CALL
    jit-signal-handler-epilog
    0 RET
] \ signal-handler define-sub-primitive

[| |
    jit-signal-handler-prolog
    jit-save-context
    temp0 vm-reg vm-signal-handler-addr-offset [+] MOV
    temp0 CALL
    jit-signal-handler-epilog
    ! Pop the fake leaf frame along with our return address
    leaf-stack-frame-size bootstrap-cell - RET
] \ leaf-signal-handler define-sub-primitive

[| |
    jit-signal-handler-prolog
    temp0 vm-reg vm-signal-handler-addr-offset [+] MOV
    temp0 CALL
    jit-signal-handler-epilog
    red-zone-size RET
] \ ffi-signal-handler define-sub-primitive

[| |
    jit-signal-handler-prolog
    temp0 vm-reg vm-signal-handler-addr-offset [+] MOV
    temp0 CALL
    jit-signal-handler-epilog
    red-zone-size 16 bootstrap-cell - + RET
] \ ffi-leaf-signal-handler define-sub-primitive

[
    ! load boolean
    temp0 ds-reg [] MOV
    ! pop boolean
    ds-reg bootstrap-cell SUB
    ! compare boolean with f
    temp0 \ f type-number CMP
    ! jump to true branch if not equal
    0 JNE f rc-relative rel-word
    ! jump to false branch if equal
    0 JMP f rc-relative rel-word
] jit-if jit-define

: jit->r ( -- )
    rs-reg bootstrap-cell ADD
    temp0 ds-reg [] MOV
    ds-reg bootstrap-cell SUB
    rs-reg [] temp0 MOV ;

: jit-2>r ( -- )
    rs-reg 2 bootstrap-cells ADD
    temp0 ds-reg [] MOV
    temp1 ds-reg -1 bootstrap-cells [+] MOV
    ds-reg 2 bootstrap-cells SUB
    rs-reg [] temp0 MOV
    rs-reg -1 bootstrap-cells [+] temp1 MOV ;

: jit-3>r ( -- )
    rs-reg 3 bootstrap-cells ADD
    temp0 ds-reg [] MOV
    temp1 ds-reg -1 bootstrap-cells [+] MOV
    temp2 ds-reg -2 bootstrap-cells [+] MOV
    ds-reg 3 bootstrap-cells SUB
    rs-reg [] temp0 MOV
    rs-reg -1 bootstrap-cells [+] temp1 MOV
    rs-reg -2 bootstrap-cells [+] temp2 MOV ;

: jit-r> ( -- )
    ds-reg bootstrap-cell ADD
    temp0 rs-reg [] MOV
    rs-reg bootstrap-cell SUB
    ds-reg [] temp0 MOV ;

: jit-2r> ( -- )
    ds-reg 2 bootstrap-cells ADD
    temp0 rs-reg [] MOV
    temp1 rs-reg -1 bootstrap-cells [+] MOV
    rs-reg 2 bootstrap-cells SUB
    ds-reg [] temp0 MOV
    ds-reg -1 bootstrap-cells [+] temp1 MOV ;

: jit-3r> ( -- )
    ds-reg 3 bootstrap-cells ADD
    temp0 rs-reg [] MOV
    temp1 rs-reg -1 bootstrap-cells [+] MOV
    temp2 rs-reg -2 bootstrap-cells [+] MOV
    rs-reg 3 bootstrap-cells SUB
    ds-reg [] temp0 MOV
    ds-reg -1 bootstrap-cells [+] temp1 MOV
    ds-reg -2 bootstrap-cells [+] temp2 MOV ;

[
    jit->r
    0 CALL f rc-relative rel-word
    jit-r>
] jit-dip jit-define

[
    jit-2>r
    0 CALL f rc-relative rel-word
    jit-2r>
] jit-2dip jit-define

[
    jit-3>r
    0 CALL f rc-relative rel-word
    jit-3r>
] jit-3dip jit-define

[
    ! load from stack
    temp0 ds-reg [] MOV
    ! pop stack
    ds-reg bootstrap-cell SUB
]
[ temp0 word-entry-point-offset [+] CALL ]
[ temp0 word-entry-point-offset [+] JMP ]
\ (execute) define-combinator-primitive

[
    temp0 ds-reg [] MOV
    ds-reg bootstrap-cell SUB
    temp0 word-entry-point-offset [+] JMP
] jit-execute jit-define

[
    stack-reg stack-frame-size bootstrap-cell - SUB
] jit-prolog jit-define

[
    stack-reg stack-frame-size bootstrap-cell - ADD
] jit-epilog jit-define

[ 0 RET ] jit-return jit-define

! ! ! Polymorphic inline caches

! The PIC stubs are not permitted to touch pic-tail-reg.

! Load a value from a stack position
[
    temp1 ds-reg 0x7f [+] MOV f rc-absolute-1 rel-untagged
] pic-load jit-define

[ temp1 tag-mask get AND ] pic-tag jit-define

[
    temp0 temp1 MOV
    temp1 tag-mask get AND
    temp1 tuple type-number CMP
    [ JNE ]
    [ temp1 temp0 tuple-class-offset [+] MOV ]
    jit-conditional
] pic-tuple jit-define

[
    temp1 0x7f CMP f rc-absolute-1 rel-untagged
] pic-check-tag jit-define

[ 0 JE f rc-relative rel-word ] pic-hit jit-define

! ! ! Megamorphic caches

[
    ! class = ...
    temp0 temp1 MOV
    temp1 tag-mask get AND
    temp1 tag-bits get SHL
    temp1 tuple type-number tag-fixnum CMP
    [ JNE ]
    [ temp1 temp0 tuple-class-offset [+] MOV ]
    jit-conditional
    ! cache = ...
    temp0 0 MOV f rc-absolute-cell rel-literal
    ! key = hashcode(class)
    temp2 temp1 MOV
    bootstrap-cell 4 = [ temp2 1 SHR ] when
    ! key &= cache.length - 1
    temp2 mega-cache-size get 1 - bootstrap-cell * AND
    ! cache += array-start-offset
    temp0 array-start-offset ADD
    ! cache += key
    temp0 temp2 ADD
    ! if(get(cache) == class)
    temp0 [] temp1 CMP
    [ JNE ]
    [
        ! megamorphic_cache_hits++
        temp1 0 MOV rc-absolute-cell rel-megamorphic-cache-hits
        temp1 [] 1 ADD
        ! goto get(cache + bootstrap-cell)
        temp0 temp0 bootstrap-cell [+] MOV
        temp0 word-entry-point-offset [+] JMP
        ! fall-through on miss
    ] jit-conditional
] mega-lookup jit-define

! ! ! Sub-primitives

! Objects
[
    ! load from stack
    temp0 ds-reg [] MOV
    ! compute tag
    temp0 tag-mask get AND
    ! tag the tag
    temp0 tag-bits get SHL
    ! push to stack
    ds-reg [] temp0 MOV
] \ tag define-sub-primitive

[
    ! load slot number
    temp0 ds-reg [] MOV
    ! adjust stack pointer
    ds-reg bootstrap-cell SUB
    ! load object
    temp1 ds-reg [] MOV
    ! turn slot number into offset
    fixnum>slot@
    ! mask off tag
    temp1 tag-bits get SHR
    temp1 tag-bits get SHL
    ! load slot value
    temp0 temp1 temp0 [+] MOV
    ! push to stack
    ds-reg [] temp0 MOV
] \ slot define-sub-primitive

[
    ! load string index from stack
    temp0 ds-reg bootstrap-cell neg [+] MOV
    temp0 tag-bits get SHR
    ! load string from stack
    temp1 ds-reg [] MOV
    ! load character
    temp0 8-bit-version-of temp0 temp1 string-offset [++] MOV
    temp0 temp0 8-bit-version-of MOVZX
    temp0 tag-bits get SHL
    ! store character to stack
    ds-reg bootstrap-cell SUB
    ds-reg [] temp0 MOV
] \ string-nth-fast define-sub-primitive

! Shufflers
[
    ds-reg bootstrap-cell SUB
] \ drop define-sub-primitive

[
    ds-reg 2 bootstrap-cells SUB
] \ 2drop define-sub-primitive

[
    ds-reg 3 bootstrap-cells SUB
] \ 3drop define-sub-primitive

[
    ds-reg 4 bootstrap-cells SUB
] \ 4drop define-sub-primitive

[
    temp0 ds-reg [] MOV
    ds-reg bootstrap-cell ADD
    ds-reg [] temp0 MOV
] \ dup define-sub-primitive

[
    temp0 ds-reg [] MOV
    temp1 ds-reg bootstrap-cell neg [+] MOV
    ds-reg 2 bootstrap-cells ADD
    ds-reg [] temp0 MOV
    ds-reg bootstrap-cell neg [+] temp1 MOV
] \ 2dup define-sub-primitive

[
    temp0 ds-reg [] MOV
    temp1 ds-reg -1 bootstrap-cells [+] MOV
    temp3 ds-reg -2 bootstrap-cells [+] MOV
    ds-reg 3 bootstrap-cells ADD
    ds-reg [] temp0 MOV
    ds-reg -1 bootstrap-cells [+] temp1 MOV
    ds-reg -2 bootstrap-cells [+] temp3 MOV
] \ 3dup define-sub-primitive

[
    temp0 ds-reg [] MOV
    temp1 ds-reg -1 bootstrap-cells [+] MOV
    temp2 ds-reg -2 bootstrap-cells [+] MOV
    temp3 ds-reg -3 bootstrap-cells [+] MOV
    ds-reg 4 bootstrap-cells ADD
    ds-reg [] temp0 MOV
    ds-reg -1 bootstrap-cells [+] temp1 MOV
    ds-reg -2 bootstrap-cells [+] temp2 MOV
    ds-reg -3 bootstrap-cells [+] temp3 MOV
] \ 4dup define-sub-primitive

[
    temp0 ds-reg [] MOV
    ds-reg bootstrap-cell SUB
    ds-reg [] temp0 MOV
] \ nip define-sub-primitive

[
    temp0 ds-reg [] MOV
    ds-reg 2 bootstrap-cells SUB
    ds-reg [] temp0 MOV
] \ 2nip define-sub-primitive

[
    temp0 ds-reg -1 bootstrap-cells [+] MOV
    ds-reg bootstrap-cell ADD
    ds-reg [] temp0 MOV
] \ over define-sub-primitive

[
    temp0 ds-reg -2 bootstrap-cells [+] MOV
    ds-reg bootstrap-cell ADD
    ds-reg [] temp0 MOV
] \ pick define-sub-primitive

[
    temp0 ds-reg [] MOV
    temp1 ds-reg -1 bootstrap-cells [+] MOV
    ds-reg [] temp1 MOV
    ds-reg bootstrap-cell ADD
    ds-reg [] temp0 MOV
] \ dupd define-sub-primitive

[
    temp0 ds-reg [] MOV
    temp1 ds-reg bootstrap-cell neg [+] MOV
    ds-reg bootstrap-cell neg [+] temp0 MOV
    ds-reg [] temp1 MOV
] \ swap define-sub-primitive

[
    temp0 ds-reg -1 bootstrap-cells [+] MOV
    temp1 ds-reg -2 bootstrap-cells [+] MOV
    ds-reg -2 bootstrap-cells [+] temp0 MOV
    ds-reg -1 bootstrap-cells [+] temp1 MOV
] \ swapd define-sub-primitive

[
    temp0 ds-reg [] MOV
    temp1 ds-reg -1 bootstrap-cells [+] MOV
    temp3 ds-reg -2 bootstrap-cells [+] MOV
    ds-reg -2 bootstrap-cells [+] temp1 MOV
    ds-reg -1 bootstrap-cells [+] temp0 MOV
    ds-reg [] temp3 MOV
] \ rot define-sub-primitive

[
    temp0 ds-reg [] MOV
    temp1 ds-reg -1 bootstrap-cells [+] MOV
    temp3 ds-reg -2 bootstrap-cells [+] MOV
    ds-reg -2 bootstrap-cells [+] temp0 MOV
    ds-reg -1 bootstrap-cells [+] temp3 MOV
    ds-reg [] temp1 MOV
] \ -rot define-sub-primitive

[ jit->r ] \ load-local define-sub-primitive

! Comparisons
: jit-compare ( insn -- )
    ! load t
    temp3 0 MOV t rc-absolute-cell rel-literal
    ! load f
    temp1 \ f type-number MOV
    ! load first value
    temp0 ds-reg [] MOV
    ! adjust stack pointer
    ds-reg bootstrap-cell SUB
    ! compare with second value
    ds-reg [] temp0 CMP
    ! move t if true
    [ temp1 temp3 ] dip execute( dst src -- )
    ! store
    ds-reg [] temp1 MOV ;

: define-jit-compare ( insn word -- )
    [ [ jit-compare ] curry ] dip define-sub-primitive ;

\ CMOVE \ eq? define-jit-compare
\ CMOVGE \ fixnum>= define-jit-compare
\ CMOVLE \ fixnum<= define-jit-compare
\ CMOVG \ fixnum> define-jit-compare
\ CMOVL \ fixnum< define-jit-compare

! Math
: jit-math ( insn -- )
    ! load second input
    temp0 ds-reg [] MOV
    ! pop stack
    ds-reg bootstrap-cell SUB
    ! compute result
    [ ds-reg [] temp0 ] dip execute( dst src -- ) ;

[ \ ADD jit-math ] \ fixnum+fast define-sub-primitive

[ \ SUB jit-math ] \ fixnum-fast define-sub-primitive

[
    ! load second input
    temp0 ds-reg [] MOV
    ! pop stack
    ds-reg bootstrap-cell SUB
    ! load first input
    temp1 ds-reg [] MOV
    ! untag second input
    temp0 tag-bits get SAR
    ! multiply
    temp0 temp1 IMUL2
    ! push result
    ds-reg [] temp0 MOV
] \ fixnum*fast define-sub-primitive

[ \ AND jit-math ] \ fixnum-bitand define-sub-primitive

[ \ OR jit-math ] \ fixnum-bitor define-sub-primitive

[ \ XOR jit-math ] \ fixnum-bitxor define-sub-primitive

[
    ! complement
    ds-reg [] NOT
    ! clear tag bits
    ds-reg [] tag-mask get XOR
] \ fixnum-bitnot define-sub-primitive

[
    ! load shift count
    shift-arg ds-reg [] MOV
    ! untag shift count
    shift-arg tag-bits get SAR
    ! adjust stack pointer
    ds-reg bootstrap-cell SUB
    ! load value
    temp3 ds-reg [] MOV
    ! make a copy
    temp2 temp3 MOV
    ! compute positive shift value in temp2
    temp2 CL SHL
    shift-arg NEG
    ! compute negative shift value in temp3
    temp3 CL SAR
    temp3 tag-mask get bitnot AND
    shift-arg 0 CMP
    ! if shift count was negative, move temp0 to temp2
    temp2 temp3 CMOVGE
    ! push to stack
    ds-reg [] temp2 MOV
] \ fixnum-shift-fast define-sub-primitive

: jit-fixnum-/mod ( -- )
    ! load second parameter
    temp1 ds-reg [] MOV
    ! load first parameter
    div-arg ds-reg bootstrap-cell neg [+] MOV
    ! make a copy
    mod-arg div-arg MOV
    ! sign-extend
    mod-arg bootstrap-cell-bits 1 - SAR
    ! divide
    temp1 IDIV ;

[
    jit-fixnum-/mod
    ! adjust stack pointer
    ds-reg bootstrap-cell SUB
    ! push to stack
    ds-reg [] mod-arg MOV
] \ fixnum-mod define-sub-primitive

[
    jit-fixnum-/mod
    ! adjust stack pointer
    ds-reg bootstrap-cell SUB
    ! tag it
    div-arg tag-bits get SHL
    ! push to stack
    ds-reg [] div-arg MOV
] \ fixnum/i-fast define-sub-primitive

[
    jit-fixnum-/mod
    ! tag it
    div-arg tag-bits get SHL
    ! push to stack
    ds-reg [] mod-arg MOV
    ds-reg bootstrap-cell neg [+] div-arg MOV
] \ fixnum/mod-fast define-sub-primitive

[
    temp0 ds-reg [] MOV
    ds-reg bootstrap-cell SUB
    temp0 ds-reg [] OR
    temp0 tag-mask get TEST
    temp0 \ f type-number MOV
    temp1 1 tag-fixnum MOV
    temp0 temp1 CMOVE
    ds-reg [] temp0 MOV
] \ both-fixnums? define-sub-primitive

[
    ! load local number
    temp0 ds-reg [] MOV
    ! turn local number into offset
    fixnum>slot@
    ! load local value
    temp0 rs-reg temp0 [+] MOV
    ! push to stack
    ds-reg [] temp0 MOV
] \ get-local define-sub-primitive

[
    ! load local count
    temp0 ds-reg [] MOV
    ! adjust stack pointer
    ds-reg bootstrap-cell SUB
    ! turn local number into offset
    fixnum>slot@
    ! decrement retain stack pointer
    rs-reg temp0 SUB
] \ drop-locals define-sub-primitive

[ "bootstrap.x86" forget-vocab ] with-compilation-unit
