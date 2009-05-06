! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel kernel.private namespaces
system cpu.x86.assembler layouts compiler.units math
math.private compiler.constants vocabs slots.private words
locals.backend make sequences combinators arrays ;
IN: bootstrap.x86

big-endian off

[
    ! Load word
    temp0 0 MOV rc-absolute-cell rt-immediate jit-rel
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
    ! load XT
    temp0 0 MOV rc-absolute-cell rt-this jit-rel
    ! save stack frame size
    stack-frame-size PUSH
    ! push XT
    temp0 PUSH
    ! alignment
    stack-reg stack-frame-size 3 bootstrap-cells - SUB
] jit-prolog jit-define

[
    ! load literal
    temp0 0 MOV rc-absolute-cell rt-immediate jit-rel
    ! increment datastack pointer
    ds-reg bootstrap-cell ADD
    ! store literal on datastack
    ds-reg [] temp0 MOV
] jit-push-immediate jit-define

[
    0 JMP rc-relative rt-xt jit-rel
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
    temp0 \ f tag-number CMP
    ! jump to true branch if not equal
    0 JNE rc-relative rt-xt jit-rel
] jit-if-1 jit-define

[
    ! jump to false branch if equal
    0 JMP rc-relative rt-xt jit-rel
] jit-if-2 jit-define

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

: prepare-(execute) ( -- operand )
    ! load from stack
    temp0 ds-reg [] MOV
    ! pop stack
    ds-reg bootstrap-cell SUB
    ! execute word
    temp0 word-xt-offset [+] ;

[ prepare-(execute) JMP ] jit-execute-jump jit-define

[ prepare-(execute) CALL ] jit-execute-call jit-define

[
    ! unwind stack frame
    stack-reg stack-frame-size bootstrap-cell - ADD
] jit-epilog jit-define

[ 0 RET ] jit-return jit-define

! ! ! Polymorphic inline caches

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

! Hi-tag
[
    temp0 temp1 MOV
    load-tag
    temp1 object tag-number tag-fixnum CMP
    [ temp1 temp0 object tag-number neg [+] MOV ] { } make
    [ length JNE ] [ % ] bi
] pic-hi-tag jit-define

! Tuple
[
    temp0 temp1 MOV
    load-tag
    temp1 tuple tag-number tag-fixnum CMP
    [ temp1 temp0 tuple tag-number neg bootstrap-cell + [+] MOV ] { } make
    [ length JNE ] [ % ] bi
] pic-tuple jit-define

! Hi-tag and tuple
[
    temp0 temp1 MOV
    load-tag
    ! If bits 2 and 3 are set, the tag is either 6 (object) or 7 (tuple)
    temp1 BIN: 110 tag-fixnum CMP
    [
        ! Untag temp0
        temp0 tag-mask get bitnot AND
        ! Set temp1 to 0 for objects, and bootstrap-cell for tuples
        temp1 1 tag-fixnum AND
        bootstrap-cell 4 = [ temp1 1 SHR ] when
        ! Load header cell or tuple layout cell
        temp1 temp0 temp1 [+] MOV
    ] [ ] make [ length JL ] [ % ] bi
] pic-hi-tag-tuple jit-define

[
    temp1 HEX: ffffffff CMP rc-absolute rt-immediate jit-rel
] pic-check-tag jit-define

[
    temp2 HEX: ffffffff MOV rc-absolute-cell rt-immediate jit-rel
    temp1 temp2 CMP
] pic-check jit-define

[ 0 JE rc-relative rt-xt jit-rel ] pic-hit jit-define

! ! ! Megamorphic caches

[
    ! cache = ...
    temp0 0 MOV rc-absolute-cell rt-immediate jit-rel
    ! key = class
    temp2 temp1 MOV
    bootstrap-cell 8 = [ temp2 1 SHL ] when
    ! key &= cache.length - 1
    temp2 mega-cache-size get 1- bootstrap-cell * AND
    ! cache += array-start-offset
    temp0 array-start-offset ADD
    ! cache += key
    temp0 temp2 ADD
    ! if(get(cache) == class)
    temp0 [] temp1 CMP
    ! ... goto get(cache + bootstrap-cell)
    [
        temp0 temp0 bootstrap-cell [+] MOV
        temp0 word-xt-offset [+] JMP
    ] [ ] make
    [ length JNE ] [ % ] bi
    ! fall-through on miss
] mega-lookup jit-define

! ! ! Sub-primitives

! Quotations and words
[
    ! load from stack
    arg ds-reg [] MOV
    ! pop stack
    ds-reg bootstrap-cell SUB
    ! call quotation
    arg quot-xt-offset [+] JMP
] \ (call) define-sub-primitive

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
    temp1 ds-reg -1 bootstrap-cells [+] MOV
    ds-reg bootstrap-cell ADD
    ds-reg [] temp0 MOV
    ds-reg -1 bootstrap-cells [+] temp1 MOV
    ds-reg -2 bootstrap-cells [+] temp0 MOV
] \ tuck define-sub-primitive

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
    temp3 0 MOV rc-absolute-cell rt-immediate jit-rel
    ! load f
    temp1 \ f tag-number MOV
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
    mod-arg bootstrap-cell-bits 1- SAR
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
    temp0 \ f tag-number MOV
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
