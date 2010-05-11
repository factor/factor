! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces make math math.order math.parser sequences
accessors kernel layouts assocs words summary arrays combinators
classes.algebra sets continuations.private fry cpu.architecture
classes classes.struct locals slots parser generic.parser
strings quotations hashtables
compiler.constants
compiler.cfg
compiler.cfg.linearization
compiler.cfg.instructions
compiler.cfg.comparisons
compiler.cfg.stack-frame
compiler.cfg.registers
compiler.cfg.builder
compiler.codegen.fixup
compiler.utilities ;
FROM: namespaces => set ;
IN: compiler.codegen

SYMBOL: insn-counts

H{ } clone insn-counts set-global

GENERIC: generate-insn ( insn -- )

! Control flow
SYMBOL: labels

: lookup-label ( bb -- label )
    labels get [ drop <label> ] cache ;

: useless-branch? ( bb successor -- ? )
    ! If our successor immediately follows us in linearization
    ! order then we don't need to branch.
    [ block-number ] bi@ 1 - = ; inline

: emit-branch ( bb successor -- )
    2dup useless-branch?
    [ 2drop ] [ nip lookup-label %jump-label ] if ;

M: ##branch generate-insn
    drop basic-block get dup successors>> first emit-branch ;

GENERIC: generate-conditional-insn ( label insn -- )

GENERIC: negate-insn-cc ( insn -- )

M: conditional-branch-insn negate-insn-cc
    [ negate-cc ] change-cc drop ;

M: ##test-vector-branch negate-insn-cc
    [ negate-vcc ] change-vcc drop ;

M:: conditional-branch-insn generate-insn ( insn -- )
    basic-block get :> bb
    bb successors>> first2 :> ( first second )
    bb second useless-branch?
    [ bb second first ]
    [ bb first second insn negate-insn-cc ] if
    lookup-label insn generate-conditional-insn
    emit-branch ;

: %dispatch-label ( label -- )
    cell 0 <repetition> %
    rc-absolute-cell label-fixup ;

M: ##dispatch generate-insn
    [ src>> ] [ temp>> ] bi %dispatch
    basic-block get successors>>
    [ lookup-label %dispatch-label ] each ;

: generate-block ( bb -- )
    [ basic-block set ]
    [ lookup-label resolve-label ]
    [
        instructions>> [
            [ class insn-counts get inc-at ]
            [ generate-insn ]
            bi
        ] each
    ] tri ;

: generate ( cfg -- code )
    [
        H{ } clone labels set
        linearization-order
        [ number-blocks ] [ [ generate-block ] each ] bi
    ] with-fixup ;

! Special cases
M: ##no-tco generate-insn drop ;

M: ##stack-frame generate-insn drop ;

M: ##prologue generate-insn
    drop
    cfg get stack-frame>>
    [ [ stack-frame set ] [ total-size>> %prologue ] bi ] when* ;

M: ##epilogue generate-insn
    drop
    cfg get stack-frame>> [ total-size>> %epilogue ] when* ;

! Some meta-programming to generate simple code generators, where
! the instruction is unpacked and then a %word is called
<<

: insn-slot-quot ( spec -- quot )
    name>> reader-word 1quotation ;

: codegen-method-body ( class word -- quot )
    [
        "insn-slots" word-prop
        [ insn-slot-quot ] map cleave>quot
    ] dip suffix ;

SYNTAX: CODEGEN:
    scan-word [ \ generate-insn create-method-in ] keep scan-word
    codegen-method-body define ;

>>

CODEGEN: ##load-integer %load-immediate
CODEGEN: ##load-tagged %load-immediate
CODEGEN: ##load-reference %load-reference
CODEGEN: ##load-float %load-float
CODEGEN: ##load-double %load-double
CODEGEN: ##load-vector %load-vector
CODEGEN: ##peek %peek
CODEGEN: ##replace %replace
CODEGEN: ##replace-imm %replace-imm
CODEGEN: ##inc-d %inc-d
CODEGEN: ##inc-r %inc-r
CODEGEN: ##call %call
CODEGEN: ##jump %jump
CODEGEN: ##return %return
CODEGEN: ##slot %slot
CODEGEN: ##slot-imm %slot-imm
CODEGEN: ##set-slot %set-slot
CODEGEN: ##set-slot-imm %set-slot-imm
CODEGEN: ##add %add
CODEGEN: ##add-imm %add-imm
CODEGEN: ##sub %sub
CODEGEN: ##sub-imm %sub-imm
CODEGEN: ##mul %mul
CODEGEN: ##mul-imm %mul-imm
CODEGEN: ##and %and
CODEGEN: ##and-imm %and-imm
CODEGEN: ##or %or
CODEGEN: ##or-imm %or-imm
CODEGEN: ##xor %xor
CODEGEN: ##xor-imm %xor-imm
CODEGEN: ##shl %shl
CODEGEN: ##shl-imm %shl-imm
CODEGEN: ##shr %shr
CODEGEN: ##shr-imm %shr-imm
CODEGEN: ##sar %sar
CODEGEN: ##sar-imm %sar-imm
CODEGEN: ##min %min
CODEGEN: ##max %max
CODEGEN: ##not %not
CODEGEN: ##neg %neg
CODEGEN: ##log2 %log2
CODEGEN: ##copy %copy
CODEGEN: ##tagged>integer %tagged>integer
CODEGEN: ##add-float %add-float
CODEGEN: ##sub-float %sub-float
CODEGEN: ##mul-float %mul-float
CODEGEN: ##div-float %div-float
CODEGEN: ##min-float %min-float
CODEGEN: ##max-float %max-float
CODEGEN: ##sqrt %sqrt
CODEGEN: ##unary-float-function %unary-float-function
CODEGEN: ##binary-float-function %binary-float-function
CODEGEN: ##single>double-float %single>double-float
CODEGEN: ##double>single-float %double>single-float
CODEGEN: ##integer>float %integer>float
CODEGEN: ##float>integer %float>integer
CODEGEN: ##zero-vector %zero-vector
CODEGEN: ##fill-vector %fill-vector
CODEGEN: ##gather-vector-2 %gather-vector-2
CODEGEN: ##gather-vector-4 %gather-vector-4
CODEGEN: ##shuffle-vector-imm %shuffle-vector-imm
CODEGEN: ##shuffle-vector %shuffle-vector
CODEGEN: ##tail>head-vector %tail>head-vector
CODEGEN: ##merge-vector-head %merge-vector-head
CODEGEN: ##merge-vector-tail %merge-vector-tail
CODEGEN: ##signed-pack-vector %signed-pack-vector
CODEGEN: ##unsigned-pack-vector %unsigned-pack-vector
CODEGEN: ##unpack-vector-head %unpack-vector-head
CODEGEN: ##unpack-vector-tail %unpack-vector-tail
CODEGEN: ##integer>float-vector %integer>float-vector
CODEGEN: ##float>integer-vector %float>integer-vector
CODEGEN: ##compare-vector %compare-vector
CODEGEN: ##test-vector %test-vector
CODEGEN: ##add-vector %add-vector
CODEGEN: ##saturated-add-vector %saturated-add-vector
CODEGEN: ##add-sub-vector %add-sub-vector
CODEGEN: ##sub-vector %sub-vector
CODEGEN: ##saturated-sub-vector %saturated-sub-vector
CODEGEN: ##mul-vector %mul-vector
CODEGEN: ##mul-high-vector %mul-high-vector
CODEGEN: ##mul-horizontal-add-vector %mul-horizontal-add-vector
CODEGEN: ##saturated-mul-vector %saturated-mul-vector
CODEGEN: ##div-vector %div-vector
CODEGEN: ##min-vector %min-vector
CODEGEN: ##max-vector %max-vector
CODEGEN: ##avg-vector %avg-vector
CODEGEN: ##dot-vector %dot-vector
CODEGEN: ##sad-vector %sad-vector
CODEGEN: ##sqrt-vector %sqrt-vector
CODEGEN: ##horizontal-add-vector %horizontal-add-vector
CODEGEN: ##horizontal-sub-vector %horizontal-sub-vector
CODEGEN: ##horizontal-shl-vector-imm %horizontal-shl-vector-imm
CODEGEN: ##horizontal-shr-vector-imm %horizontal-shr-vector-imm
CODEGEN: ##abs-vector %abs-vector
CODEGEN: ##and-vector %and-vector
CODEGEN: ##andn-vector %andn-vector
CODEGEN: ##or-vector %or-vector
CODEGEN: ##xor-vector %xor-vector
CODEGEN: ##not-vector %not-vector
CODEGEN: ##shl-vector-imm %shl-vector-imm
CODEGEN: ##shr-vector-imm %shr-vector-imm
CODEGEN: ##shl-vector %shl-vector
CODEGEN: ##shr-vector %shr-vector
CODEGEN: ##integer>scalar %integer>scalar
CODEGEN: ##scalar>integer %scalar>integer
CODEGEN: ##vector>scalar %vector>scalar
CODEGEN: ##scalar>vector %scalar>vector
CODEGEN: ##box-alien %box-alien
CODEGEN: ##box-displaced-alien %box-displaced-alien
CODEGEN: ##unbox-alien %unbox-alien
CODEGEN: ##unbox-any-c-ptr %unbox-any-c-ptr
CODEGEN: ##load-memory %load-memory
CODEGEN: ##load-memory-imm %load-memory-imm
CODEGEN: ##store-memory %store-memory
CODEGEN: ##store-memory-imm %store-memory-imm
CODEGEN: ##allot %allot
CODEGEN: ##write-barrier %write-barrier
CODEGEN: ##write-barrier-imm %write-barrier-imm
CODEGEN: ##compare %compare
CODEGEN: ##compare-imm %compare-imm
CODEGEN: ##compare-integer %compare
CODEGEN: ##compare-integer-imm %compare-integer-imm
CODEGEN: ##compare-float-ordered %compare-float-ordered
CODEGEN: ##compare-float-unordered %compare-float-unordered
CODEGEN: ##save-context %save-context
CODEGEN: ##restore-context %restore-context
CODEGEN: ##vm-field %vm-field
CODEGEN: ##set-vm-field %set-vm-field
CODEGEN: ##alien-global %alien-global
CODEGEN: ##call-gc %call-gc
CODEGEN: ##spill %spill
CODEGEN: ##reload %reload

! Conditional branches
<<

SYNTAX: CONDITIONAL:
    scan-word [ \ generate-conditional-insn create-method-in ] keep scan-word
    codegen-method-body define ;

>>

CONDITIONAL: ##compare-branch %compare-branch
CONDITIONAL: ##compare-imm-branch %compare-imm-branch
CONDITIONAL: ##compare-integer-branch %compare-branch
CONDITIONAL: ##compare-integer-imm-branch %compare-integer-imm-branch
CONDITIONAL: ##compare-float-ordered-branch %compare-float-ordered-branch
CONDITIONAL: ##compare-float-unordered-branch %compare-float-unordered-branch
CONDITIONAL: ##test-vector-branch %test-vector-branch
CONDITIONAL: ##check-nursery-branch %check-nursery-branch
CONDITIONAL: ##fixnum-add %fixnum-add
CONDITIONAL: ##fixnum-sub %fixnum-sub
CONDITIONAL: ##fixnum-mul %fixnum-mul

! FFI
CODEGEN: ##unbox %unbox
CODEGEN: ##store-reg-param %store-reg-param
CODEGEN: ##store-stack-param %store-stack-param
CODEGEN: ##store-return %store-return
CODEGEN: ##store-struct-return %store-struct-return
CODEGEN: ##store-long-long-return %store-long-long-return
CODEGEN: ##prepare-struct-area %prepare-struct-area
CODEGEN: ##box %box
CODEGEN: ##box-long-long %box-long-long
CODEGEN: ##box-large-struct %box-large-struct
CODEGEN: ##box-small-struct %box-small-struct
CODEGEN: ##save-param-reg %save-param-reg
CODEGEN: ##alien-invoke %alien-invoke
CODEGEN: ##cleanup %cleanup
CODEGEN: ##alien-indirect %alien-indirect
CODEGEN: ##begin-callback %begin-callback
CODEGEN: ##alien-callback %alien-callback
CODEGEN: ##end-callback %end-callback

M: ##alien-assembly generate-insn quot>> call( -- ) ;
