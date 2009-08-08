! Copyright (C) 2009 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: kernel fry accessors sequences assocs sets namespaces
arrays combinators make locals cpu.architecture compiler.utilities
compiler.cfg
compiler.cfg.rpo
compiler.cfg.hats
compiler.cfg.registers
compiler.cfg.instructions
compiler.cfg.def-use
compiler.cfg.utilities
compiler.cfg.loop-detection
compiler.cfg.renaming.functor
compiler.cfg.representations.preferred ;
IN: compiler.cfg.representations

! Virtual register representation selection.
! Still needs a loop nesting heuristic

! For every vreg, compute possible representations.
SYMBOL: possibilities

: possible ( vreg -- reps ) possibilities get at ;

: compute-possibilities ( cfg -- )
    H{ } clone [ '[ swap _ conjoin-at ] with-vreg-reps ] keep
    [ keys ] assoc-map possibilities set ;

! For every vreg, compute the cost of keeping it in every possible
! representation.

! Cost map maps vreg to representation to cost.
SYMBOL: costs

: init-costs ( -- )
    possibilities get [ [ 0 ] H{ } map>assoc ] assoc-map costs set ;

: increase-cost ( rep vreg -- )
    ! Increase cost of keeping vreg in rep, making a choice of rep less
    ! likely.
    [ basic-block get loop-nesting-at ] 2dip costs get at at+ ;

: maybe-increase-cost ( possible vreg preferred -- )
    pick eq? [ 2drop ] [ increase-cost ] if ;

: representation-cost ( vreg preferred -- )
    ! 'preferred' is a representation that the instruction can accept with no cost.
    ! So, for each representation that's not preferred, increase the cost of keeping
    ! the vreg in that representation.
    [ drop possible ]
    [ '[ _ _ maybe-increase-cost ] ]
    2bi each ;

! For every vreg, compute preferred representation, that minimizes costs.
SYMBOL: preferred

: minimize-costs ( -- )
    costs get [ >alist alist-min first ] assoc-map preferred set ;

: compute-costs ( cfg -- )
    init-costs
    [ representation-cost ] with-vreg-reps
    minimize-costs ;

! Insert conversions. This introduces new temporaries, so we need
! to rename opearands too.

: emit-conversion ( dst src dst-rep src-rep -- )
    2array {
        { { int-rep int-rep } [ int-rep ##copy ] }
        { { double-float-rep double-float-rep } [ double-float-rep ##copy ] }
        { { double-float-rep int-rep } [ ##unbox-float ] }
        { { int-rep double-float-rep } [ i ##box-float ] }
    } case ;

:: emit-def-conversion ( dst preferred required -- new-dst' )
    ! If an instruction defines a register with representation 'required',
    ! but the register has preferred representation 'preferred', then
    ! we rename the instruction's definition to a new register, which
    ! becomes the input of a conversion instruction.
    dst required next-vreg [ preferred required emit-conversion ] keep ;

:: emit-use-conversion ( src preferred required -- new-src' )
    ! If an instruction uses a register with representation 'required',
    ! but the register has preferred representation 'preferred', then
    ! we rename the instruction's input to a new register, which
    ! becomes the output of a conversion instruction.
    required next-vreg [ src required preferred emit-conversion ] keep ;

SYMBOLS: renaming-set needs-renaming? ;

: init-renaming-set ( -- )
    needs-renaming? off
    V{ } clone renaming-set set ;

: no-renaming ( vreg -- )
    dup 2array renaming-set get push ;

: record-renaming ( from to -- )
    2array renaming-set get push needs-renaming? on ;

:: (compute-renaming-set) ( vreg required quot: ( vreg preferred required -- ) -- )
    vreg preferred get at :> preferred
    preferred required eq?
    [ vreg no-renaming ]
    [ vreg vreg preferred required quot call record-renaming ] if ; inline

: compute-renaming-set ( insn -- )
    ! temp vregs don't need conversions since they're always in their
    ! preferred representation
    init-renaming-set
    [ [ [ emit-use-conversion ] (compute-renaming-set) ] each-use-rep ]
    [ , ]
    [ [ [ emit-def-conversion ] (compute-renaming-set) ] each-def-rep ]
    tri ;

: converted-value ( vreg -- vreg' )
    renaming-set get pop first2 [ assert= ] dip ;

RENAMING: convert [ converted-value ] [ converted-value ] [ ]

: perform-renaming ( insn -- )
    needs-renaming? get [
        renaming-set get reverse-here
        [ convert-insn-uses ] [ convert-insn-defs ] bi
        renaming-set get length 0 assert=
    ] [ drop ] if ;

GENERIC: conversions-for-insn ( insn -- )

! Inserting conversions for a phi is done in compiler.cfg.cssa
M: ##phi conversions-for-insn , ;

M: vreg-insn conversions-for-insn
    [ compute-renaming-set ] [ perform-renaming ] bi ;

M: insn conversions-for-insn , ;

: conversions-for-block ( bb -- )
    dup kill-block? [ drop ] [
        [
            [
                [ conversions-for-insn ] each
            ] V{ } make
        ] change-instructions drop
    ] if ;

: insert-conversions ( cfg -- )
    [ conversions-for-block ] each-basic-block ;

: select-representations ( cfg -- cfg' )
    {
        [ compute-possibilities ]
        [ compute-costs ]
        [ insert-conversions ]
        [ preferred get [ >>rep drop ] assoc-each ]
    } cleave ;