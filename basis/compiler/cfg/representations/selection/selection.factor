! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs byte-arrays combinators
disjoint-sets fry kernel locals math math.functions
namespaces sequences sets
compiler.cfg
compiler.cfg.instructions
compiler.cfg.loop-detection
compiler.cfg.registers
compiler.cfg.representations.preferred
compiler.cfg.representations.coalescing
compiler.cfg.rpo
compiler.cfg.utilities
compiler.utilities
cpu.architecture ;
FROM: assocs => change-at ;
FROM: namespaces => set ;
IN: compiler.cfg.representations.selection

! vregs which must be tagged at the definition site because
! there is at least one usage that is not int-rep. If all usages
! are int-rep it is safe to untag at the definition site.
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
    H{ } clone vreg-reps set
    HS{ } clone tagged-vregs set
    [ [ (collect-vreg-reps) ] each-non-phi ] each-basic-block ;

SYMBOL: possibilities

: possible-reps ( vreg reps -- vreg reps )
    { tagged-rep } union
    2dup [ tagged-vregs get in? not ] [ { tagged-rep } = ] bi* and
    [ drop { tagged-rep int-rep } ] when ;

: compute-possibilities ( cfg -- )
    collect-vreg-reps
    vreg-reps get [ possible-reps ] assoc-map possibilities set ;

! For every vreg, compute the cost of keeping it in every possible
! representation.

! Cost map maps vreg to representation to cost.
SYMBOL: costs

: init-costs ( -- )
    ! Initialize cost as 0 for each possibility.
    possibilities get [ [ 0 ] H{ } map>assoc ] assoc-map costs set ;

: increase-cost ( rep scc factor -- )
    ! Increase cost of keeping vreg in rep, making a choice of rep less
    ! likely. If the rep is not in the cost alist, it means this
    ! representation is prohibited.
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

GENERIC: has-peephole-opts? ( insn -- ? )

M: insn has-peephole-opts? drop f ;
M: ##load-integer has-peephole-opts? drop t ;
M: ##load-reference has-peephole-opts? drop t ;
M: ##neg has-peephole-opts? drop t ;
M: ##not has-peephole-opts? drop t ;
M: inert-tag-untag-insn has-peephole-opts? drop t ;
M: inert-arithmetic-tag-untag-insn has-peephole-opts? drop t ;
M: inert-bitwise-tag-untag-insn has-peephole-opts? drop t ;
M: ##mul-imm has-peephole-opts? drop t ;
M: ##shl-imm has-peephole-opts? drop t ;
M: ##shr-imm has-peephole-opts? drop t ;
M: ##sar-imm has-peephole-opts? drop t ;
M: ##compare-integer-imm has-peephole-opts? drop t ;
M: ##compare-integer has-peephole-opts? drop t ;
M: ##compare-integer-imm-branch has-peephole-opts? drop t ;
M: ##compare-integer-branch has-peephole-opts? drop t ;
M: ##test-imm has-peephole-opts? drop t ;
M: ##test has-peephole-opts? drop t ;
M: ##test-imm-branch has-peephole-opts? drop t ;
M: ##test-branch has-peephole-opts? drop t ;

GENERIC: compute-insn-costs ( insn -- )

M: insn compute-insn-costs drop ;

M: vreg-insn compute-insn-costs
    dup has-peephole-opts? 2 5 ? '[ _ increase-costs ] each-rep ;

: compute-costs ( cfg -- )
    init-costs
    [
        [ basic-block set ]
        [ [ compute-insn-costs ] each-non-phi ] bi
    ] each-basic-block ;

! For every vreg, compute preferred representation, that minimizes costs.
: minimize-costs ( costs -- representations )
    [ nip assoc-empty? not ] assoc-filter
    [ >alist alist-min first ] assoc-map ;

: compute-representations ( cfg -- )
    compute-costs costs get minimize-costs
    [ components get [ disjoint-set-members ] keep ] dip
    '[ dup _ representative _ at ] H{ } map>assoc
    representations set ;
