! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes combinators
compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.stacks compiler.cfg.stacks.local
compiler.tree.propagation.info cpu.architecture generalizations
kernel make math quotations sequences sequences.generalizations ;
IN: compiler.cfg.intrinsics.simd.backend

! Selection of implementation based on available CPU instructions

GENERIC: insn-available? ( ## -- reps )

M: object insn-available? drop t ;

M: ##zero-vector insn-available? rep>> %zero-vector-reps member? ;
M: ##fill-vector insn-available? rep>> %fill-vector-reps member? ;
M: ##gather-vector-2 insn-available? rep>> %gather-vector-2-reps member? ;
M: ##gather-vector-4 insn-available? rep>> %gather-vector-4-reps member? ;
M: ##gather-int-vector-2 insn-available? rep>> %gather-int-vector-2-reps member? ;
M: ##gather-int-vector-4 insn-available? rep>> %gather-int-vector-4-reps member? ;
M: ##select-vector insn-available? rep>> %select-vector-reps member? ;
M: ##store-memory-imm insn-available? rep>> %alien-vector-reps member? ;
M: ##shuffle-vector insn-available? rep>> %shuffle-vector-reps member? ;
M: ##shuffle-vector-imm insn-available? rep>> %shuffle-vector-imm-reps member? ;
M: ##shuffle-vector-halves-imm insn-available? rep>> %shuffle-vector-halves-imm-reps member? ;
M: ##merge-vector-head insn-available? rep>> %merge-vector-reps member? ;
M: ##merge-vector-tail insn-available? rep>> %merge-vector-reps member? ;
M: ##float-pack-vector insn-available? rep>> %float-pack-vector-reps member? ;
M: ##signed-pack-vector insn-available? rep>> %signed-pack-vector-reps member? ;
M: ##unsigned-pack-vector insn-available? rep>> %unsigned-pack-vector-reps member? ;
M: ##unpack-vector-head insn-available? rep>> %unpack-vector-head-reps member? ;
M: ##unpack-vector-tail insn-available? rep>> %unpack-vector-tail-reps member? ;
M: ##tail>head-vector insn-available? rep>> %unpack-vector-head-reps member? ;
M: ##integer>float-vector insn-available? rep>> %integer>float-vector-reps member? ;
M: ##float>integer-vector insn-available? rep>> %float>integer-vector-reps member? ;
M: ##compare-vector insn-available? [ rep>> ] [ cc>> ] bi %compare-vector-reps member? ;
M: ##move-vector-mask insn-available? rep>> %move-vector-mask-reps member? ;
M: ##test-vector insn-available? rep>> %test-vector-reps member? ;
M: ##add-vector insn-available? rep>> %add-vector-reps member? ;
M: ##saturated-add-vector insn-available? rep>> %saturated-add-vector-reps member? ;
M: ##add-sub-vector insn-available? rep>> %add-sub-vector-reps member? ;
M: ##sub-vector insn-available? rep>> %sub-vector-reps member? ;
M: ##saturated-sub-vector insn-available? rep>> %saturated-sub-vector-reps member? ;
M: ##mul-vector insn-available? rep>> %mul-vector-reps member? ;
M: ##mul-high-vector insn-available? rep>> %mul-high-vector-reps member? ;
M: ##mul-horizontal-add-vector insn-available? rep>> %mul-horizontal-add-vector-reps member? ;
M: ##saturated-mul-vector insn-available? rep>> %saturated-mul-vector-reps member? ;
M: ##div-vector insn-available? rep>> %div-vector-reps member? ;
M: ##min-vector insn-available? rep>> %min-vector-reps member? ;
M: ##max-vector insn-available? rep>> %max-vector-reps member? ;
M: ##avg-vector insn-available? rep>> %avg-vector-reps member? ;
M: ##dot-vector insn-available? rep>> %dot-vector-reps member? ;
M: ##sad-vector insn-available? rep>> %sad-vector-reps member? ;
M: ##sqrt-vector insn-available? rep>> %sqrt-vector-reps member? ;
M: ##horizontal-add-vector insn-available? rep>> %horizontal-add-vector-reps member? ;
M: ##horizontal-sub-vector insn-available? rep>> %horizontal-sub-vector-reps member? ;
M: ##abs-vector insn-available? rep>> %abs-vector-reps member? ;
M: ##and-vector insn-available? rep>> %and-vector-reps member? ;
M: ##andn-vector insn-available? rep>> %andn-vector-reps member? ;
M: ##or-vector insn-available? rep>> %or-vector-reps member? ;
M: ##xor-vector insn-available? rep>> %xor-vector-reps member? ;
M: ##not-vector insn-available? rep>> %not-vector-reps member? ;
M: ##shl-vector insn-available? rep>> %shl-vector-reps member? ;
M: ##shr-vector insn-available? rep>> %shr-vector-reps member? ;
M: ##shl-vector-imm insn-available? rep>> %shl-vector-imm-reps member? ;
M: ##shr-vector-imm insn-available? rep>> %shr-vector-imm-reps member? ;
M: ##horizontal-shl-vector-imm insn-available? rep>> %horizontal-shl-vector-imm-reps member? ;
M: ##horizontal-shr-vector-imm insn-available? rep>> %horizontal-shr-vector-imm-reps member? ;

: [vector-op-checked] ( #dup quot -- quot )
    '[ _ ndup _ { } make dup [ insn-available? ] all? ] ;

GENERIC#: >vector-op-cond 2 ( quot #pick #dup -- quotpair )
M:: callable >vector-op-cond ( quot #pick #dup -- quotpair )
    #dup quot [vector-op-checked] '[ 2drop @ ]
    #dup '[ % _ nnip ]
    2array ;

M:: pair >vector-op-cond ( pair #pick #dup -- quotpair )
    pair first2 :> ( class quot )
    #pick class #dup quot [vector-op-checked]
    '[ 2drop _ npick _ instance? _ [ f f f ] if ]
    #dup '[ % _ nnip ]
    2array ;

MACRO: v-vector-op ( trials -- quot )
    [ 1 2 >vector-op-cond ] map '[ f f _ cond ] ;
MACRO: vl-vector-op ( trials -- quot )
    [ 1 3 >vector-op-cond ] map '[ f f _ cond ] ;
MACRO: vvl-vector-op ( trials -- quot )
    [ 1 4 >vector-op-cond ] map '[ f f _ cond ] ;
MACRO: vv-vector-op ( trials -- quot )
    [ 1 3 >vector-op-cond ] map '[ f f _ cond ] ;
MACRO: vv-cc-vector-op ( trials -- quot )
    [ 2 4 >vector-op-cond ] map '[ f f _ cond ] ;
MACRO: vvvv-vector-op ( trials -- quot )
    [ 1 5 >vector-op-cond ] map '[ f f _ cond ] ;

! Intrinsic code emission

MACRO: check-elements ( quots -- quot )
    [ length '[ _ firstn ] ]
    [ '[ _ spread ] ]
    [ length 1 - \ and <repetition> [ ] like ]
    tri 3append ;

ERROR: bad-simd-intrinsic node ;

MACRO: if-literals-match ( quots -- quot )
    [ length ] [ ] [ length ] tri
    ! n quots n
    '[
        ! node quot
        [
            dup node-input-infos
            _ tail-slice* [ literal>> ] map
            dup _ check-elements
        ] dip
        swap [
            ! node literals quot
            [ _ firstn ] dip call
            drop
        ] [ 2drop bad-simd-intrinsic ] if
    ] ;

CONSTANT: unary        [ ds-drop  ds-pop ]
CONSTANT: unary/param  [ [ -2 <ds-loc> inc-stack ds-pop ] dip ]
CONSTANT: binary       [ ds-drop 2inputs ]
CONSTANT: binary/param [ [ -2 <ds-loc> inc-stack 2inputs ] dip ]
CONSTANT: quaternary
    [
        ds-drop
        D: 3 peek-loc
        D: 2 peek-loc
        D: 1 peek-loc
        D: 0 peek-loc
        -4 <ds-loc> inc-stack
    ]

:: emit-vector-op ( trials params-quot op-quot literal-preds -- quot )
    params-quot trials op-quot literal-preds
    '[ [ _ dip _ @ ds-push ] _ if-literals-match ] ;

MACRO: emit-v-vector-op ( trials -- quot )
    unary [ v-vector-op ] { [ representation? ] } emit-vector-op ;
MACRO: emit-vl-vector-op ( trials literal-pred -- quot )
    [ unary/param [ vl-vector-op ] { [ representation? ] } ] dip prefix emit-vector-op ;
MACRO: emit-vv-vector-op ( trials -- quot )
    binary [ vv-vector-op ] { [ representation? ] } emit-vector-op ;
MACRO: emit-vvl-vector-op ( trials literal-pred -- quot )
    [ binary/param [ vvl-vector-op ] { [ representation? ] } ] dip prefix emit-vector-op ;
MACRO: emit-vvvv-vector-op ( trials -- quot )
    quaternary [ vvvv-vector-op ] { [ representation? ] } emit-vector-op ;

MACRO:: emit-vv-or-vl-vector-op ( var-trials imm-trials literal-pred -- quot )
    literal-pred imm-trials literal-pred var-trials
    '[
        dup node-input-infos 2 tail-slice* first literal>> @
        [ _ _ emit-vl-vector-op ]
        [ _   emit-vv-vector-op ] if
    ] ;
