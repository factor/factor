! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs byte-arrays combinators
compiler.cfg compiler.cfg.instructions
compiler.cfg.loop-detection compiler.cfg.registers
compiler.cfg.representations.coalescing
compiler.cfg.representations.preferred compiler.cfg.rpo
compiler.cfg.utilities compiler.utilities cpu.architecture
disjoint-sets fry kernel locals math math.functions namespaces
sequences sets ;
IN: compiler.cfg.representations.selection

SYMBOL: tagged-vregs

SYMBOL: vreg-reps

: handle-def ( vreg rep -- )
    swap vreg>scc vreg-reps get
    [ [ intersect ] when* ] change-at ;

: handle-use ( vreg rep -- )
    int-rep eq? [ drop ] [ vreg>scc tagged-vregs get adjoin ] if ;

GENERIC: (collect-vreg-reps) ( insn -- )

M: ##load-reference (collect-vreg-reps)
    [ dst>> ] [ obj>> ] bi {
        { [ dup float? ] [ drop { float-rep double-rep } ] }
        { [ dup byte-array? ] [ drop vector-reps ] }
        [ drop { } ]
    } cond handle-def ;

M: vreg-insn (collect-vreg-reps)
    [ [ handle-use ] each-use-rep ]
    [ [ 1array handle-def ] each-def-rep ]
    [ [ 1array handle-def ] each-temp-rep ]
    tri ;

M: insn (collect-vreg-reps) drop ;

: collect-vreg-reps ( cfg -- )
    H{ } clone vreg-reps namespaces:set
    HS{ } clone tagged-vregs namespaces:set
    [ [ (collect-vreg-reps) ] each-non-phi ] each-basic-block ;

SYMBOL: possibilities

: possible-reps ( vreg reps -- vreg reps )
    { tagged-rep } union
    2dup [ tagged-vregs get in? not ] [ { tagged-rep } = ] bi* and
    [ drop { tagged-rep int-rep } ] when ;

: compute-possibilities ( cfg -- )
    collect-vreg-reps
    vreg-reps get [ possible-reps ] assoc-map possibilities namespaces:set ;

! For every vreg, compute the cost of keeping it in every possible
! representation.

SYMBOL: costs

: init-costs ( -- )
    possibilities get [ [ 0 ] H{ } map>assoc ] assoc-map costs namespaces:set ;

: increase-cost ( rep scc factor -- )
    [ costs get at 2dup key? ] dip
    '[ [ current-loop-nesting 10^ _ * + ] change-at ] [ 2drop ] if ;

:: increase-costs ( vreg preferred factor -- )
    vreg vreg>scc :> scc
    scc possibilities get at [
        dup preferred eq? [ drop ] [ scc factor increase-cost ] if
    ] each ; inline

UNION: inert-tag-untag-insn
    ##add
    ##sub
    ##and
    ##or
    ##xor
    ##min
    ##max ;

UNION: inert-arithmetic-tag-untag-insn
    ##add-imm
    ##sub-imm ;

UNION: inert-bitwise-tag-untag-insn
    ##and-imm
    ##or-imm
    ##xor-imm ;

UNION: peephole-optimizable
    ##load-integer
    ##load-reference
    ##neg
    ##not
    inert-tag-untag-insn
    inert-arithmetic-tag-untag-insn
    inert-bitwise-tag-untag-insn
    ##mul-imm
    ##shl-imm
    ##shr-imm
    ##sar-imm
    ##compare-integer-imm
    ##compare-integer
    ##compare-integer-imm-branch
    ##compare-integer-branch
    ##test-imm
    ##test
    ##test-imm-branch
    ##test-branch
    ##bit-count ;

GENERIC: compute-insn-costs ( insn -- )

M: insn compute-insn-costs drop ;

M: vreg-insn compute-insn-costs
    dup peephole-optimizable? 2 5 ? '[ _ increase-costs ] each-rep ;

: compute-costs ( cfg -- )
    init-costs
    [
        [ basic-block namespaces:set ]
        [ [ compute-insn-costs ] each-non-phi ] bi
    ] each-basic-block ;

: minimize-costs ( costs -- representations )
    [ nip assoc-empty? ] assoc-reject
    [ >alist alist-min first ] assoc-map ;

: compute-representations ( cfg -- )
    compute-costs costs get minimize-costs
    [ components get [ disjoint-set-members ] keep ] dip
    '[ dup _ representative _ at ] H{ } map>assoc
    representations namespaces:set ;
