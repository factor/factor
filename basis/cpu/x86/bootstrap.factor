! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private compiler.constants
compiler.units cpu.x86.assembler cpu.x86.assembler.operands
kernel kernel.private layouts locals.backend make math
math.private namespaces sequences slots.private vocabs ;
IN: bootstrap.x86

big-endian off

! C to Factor entry point
[
    ! Optimizing compiler's side of callback accesses
    ! arguments that are on the stack via the frame pointer.
    ! On x86-64, some arguments are passed in registers, and
    ! so the only register that is safe for use here is safe-reg.
    frame-reg PUSH
    frame-reg stack-reg MOV

    ! Save all non-volatile registers
    nv-regs [ PUSH ] each

    ! Save old stack pointer and align
    safe-reg stack-reg MOV
    stack-reg bootstrap-cell SUB
    stack-reg -16 AND
    stack-reg [] safe-reg MOV

    ! Register shadow area - only required on Win64, but doesn't
    ! hurt on other platforms
    stack-reg 32 SUB

    ! Call into Factor code
    safe-reg 0 MOV rc-absolute-cell rt-xt jit-rel
    safe-reg CALL

    ! Tear down register shadow area
    stack-reg 32 ADD

    ! Undo stack alignment
    stack-reg stack-reg [] MOV

    ! Restore non-volatile registers
    nv-regs <reversed> [ POP ] each

    frame-reg POP

    ! Callbacks which return structs, or use stdcall, need a
    ! parameter here. See the comment in callback-return-rewind
    ! in cpu.x86.32
    HEX: ffff RET rc-absolute-2 rt-untagged jit-rel
] callback-stub jit-define

[
    ! Load word
    temp0 0 MOV rc-absolute-cell rt-literal jit-rel
    ! Bump profiling counter
    temp0 profile-count-offset [+] 1 tag-fixnum ADD
    ! Load word->code
    temp0 temp0 word-code-offset [+] MOV
    ! Compute word XT
    temp0 compiled-header-size ADD
    ! Jump to XT
    temp0 JMP
] jit-profiling jit-define

[
    ! load literal
    temp0 0 MOV rc-absolute-cell rt-literal jit-rel
    ! increment datastack pointer
    ds-reg bootstrap-cell ADD
    ! store literal on datastack
    ds-reg [] temp0 MOV
] jit-push jit-define

[
    temp3 0 MOV rc-absolute-cell rt-here jit-rel
    0 JMP rc-relative rt-xt-pic-tail jit-rel
] jit-word-jump jit-define

[
    0 CALL rc-relative rt-xt-pic jit-rel
] jit-word-call jit-define

[
    ! load boolean
    temp0 ds-reg [] MOV
    ! pop boolean
    ds-reg bootstrap-cell SUB
    ! compare boolean with f
    temp0 \ f type-number CMP
    ! jump to true branch if not equal
    0 JNE rc-relative rt-xt jit-rel
    ! jump to false branch if equal
    0 JMP rc-relative rt-xt jit-rel
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
    0 CALL rc-relative rt-xt jit-rel
    jit-r>
] jit-dip jit-define

[
    jit-2>r
    0 CALL rc-relative rt-xt jit-rel
    jit-2r>
] jit-2dip jit-define

[
    jit-3>r
    0 CALL rc-relative rt-xt jit-rel
    jit-3r>
] jit-3dip jit-define

[
    ! load from stack
    temp0 ds-reg [] MOV
    ! pop stack
    ds-reg bootstrap-cell SUB
]
[ temp0 word-xt-offset [+] CALL ]
[ temp0 word-xt-offset [+] JMP ]
\ (execute) define-sub-primitive*

[
    temp0 ds-reg [] MOV
    ds-reg bootstrap-cell SUB
    temp0 word-xt-offset [+] JMP
] jit-execute jit-define

[
    stack-reg stack-frame-size bootstrap-cell - ADD
] jit-epilog jit-define

[ 0 RET ] jit-return jit-define

! ! ! Polymorphic inline caches

! The PIC stubs are not permitted to touch temp3.

! Load a value from a stack position
[
    temp1 ds-reg HEX: ffffffff [+] MOV rc-absolute rt-untagged jit-rel
] pic-load jit-define

! Tag
: load-tag ( -- )
    temp1 tag-mask get AND
    temp1 tag-bits get SHL ;

[ load-tag ] pic-tag jit-define

! The 'make' trick lets us compute the jump distance for the
! conditional branches there

! Tuple
[
    temp0 temp1 MOV
    load-tag
    temp1 tuple type-number tag-fixnum CMP
    [ JNE ]
    [ temp1 temp0 tuple type-number neg bootstrap-cell + [+] MOV ]
    jit-conditional
] pic-tuple jit-define

[
    temp1 HEX: ffffffff CMP rc-absolute rt-literal jit-rel
] pic-check-tag jit-define

[
    temp2 HEX: ffffffff MOV rc-absolute-cell rt-literal jit-rel
    temp1 temp2 CMP
] pic-check-tuple jit-define

[ 0 JE rc-relative rt-xt jit-rel ] pic-hit jit-define

! ! ! Megamorphic caches

[
    ! cache = ...
    temp0 0 MOV rc-absolute-cell rt-literal jit-rel
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
    bootstrap-cell 4 = 14 22 ? JNE ! Yuck!
    ! megamorphic_cache_hits++
    temp1 0 MOV rc-absolute-cell rt-megamorphic-cache-hits jit-rel
    temp1 [] 1 ADD
    ! goto get(cache + bootstrap-cell)
    temp0 temp0 bootstrap-cell [+] MOV
    temp0 word-xt-offset [+] JMP
    ! fall-through on miss
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
    t jit-literal
    temp3 0 MOV rc-absolute-cell rt-literal jit-rel
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
    ds-reg [] temp1 MOV
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
    temp1 temp3 MOV
    ! compute positive shift value in temp1
    temp1 CL SHL
    shift-arg NEG
    ! compute negative shift value in temp3
    temp3 CL SAR
    temp3 tag-mask get bitnot AND
    shift-arg 0 CMP
    ! if shift count was negative, move temp0 to temp1
    temp1 temp3 CMOVGE
    ! push to stack
    ds-reg [] temp1 MOV
] \ fixnum-shift-fast define-sub-primitive

: jit-fixnum-/mod ( -- )
    ! load second parameter
    temp3 ds-reg [] MOV
    ! load first parameter
    div-arg ds-reg bootstrap-cell neg [+] MOV
    ! make a copy
    mod-arg div-arg MOV
    ! sign-extend
    mod-arg bootstrap-cell-bits 1 - SAR
    ! divide
    temp3 IDIV ;

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
    temp0 tag-mask get AND
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
