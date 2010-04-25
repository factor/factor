! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs byte-arrays combinators
disjoint-sets fry kernel locals math namespaces sequences sets
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
FROM: namespaces => set ;
IN: compiler.cfg.representations.selection

SYMBOL: scc-infos

TUPLE: scc-info reps all-uses-untagged? ;

: <scc-info> ( -- reps )
    V{ } clone t \ scc-info boa ;

: scc-info ( vreg -- info )
    vreg>scc scc-infos get [ drop <scc-info> ] cache ;

: handle-def ( vreg rep -- )
    swap scc-info reps>> push ;

: handle-use ( vreg rep -- )
    int-rep eq? [ scc-info f >>all-uses-untagged? ] unless drop ;

GENERIC: collect-scc-info ( insn -- )

M: ##load-reference collect-scc-info
    [ dst>> ] [ obj>> ] bi {
        { [ dup float? ] [ drop { float-rep double-rep } ] }
        { [ dup byte-array? ] [ drop vector-reps ] }
        [ drop { } ]
    } cond handle-def ;

M: vreg-insn collect-scc-info
    [ [ handle-use ] each-use-rep ]
    [ [ 1array handle-def ] each-def-rep ]
    [ [ 1array handle-def ] each-temp-rep ]
    tri ;

M: insn collect-scc-info drop ;

: collect-scc-infos ( cfg -- )
    H{ } clone scc-infos set
    [ [ collect-scc-info ] each-non-phi ] each-basic-block ;

SYMBOL: possibilities

: permitted-reps ( scc-info -- seq )
    reps>> [ ] [ intersect ] map-reduce
    tagged-rep over member-eq? [ tagged-rep suffix ] unless ;

: scc-reps ( scc-info -- seq )
    dup permitted-reps
    2dup [ all-uses-untagged?>> ] [ { tagged-rep } = ] bi* and
    [ 2drop { tagged-rep int-rep } ] [ nip ] if ;

: compute-possibilities ( cfg -- )
    collect-scc-infos
    scc-infos get [ scc-reps ] assoc-map possibilities set ;

! For every vreg, compute the cost of keeping it in every possible
! representation.

! Cost map maps vreg to representation to cost.
SYMBOL: costs

: init-costs ( -- )
    ! Initialize cost as 0 for each possibility.
    possibilities get [ [ 0 ] H{ } map>assoc ] assoc-map costs set ;

: 10^ ( n -- x ) 10 <repetition> product ;

: increase-cost ( rep scc factor -- )
    ! Increase cost of keeping vreg in rep, making a choice of rep less
    ! likely. If the rep is not in the cost alist, it means this
    ! representation is prohibited.
    [ costs get at 2dup key? ] dip
    '[ [ current-loop-nesting 10^ _ * + ] change-at ] [ 2drop ] if ;

: possible-reps ( scc -- reps )
    possibilities get at ;

:: increase-costs ( vreg preferred factor -- )
    vreg vreg>scc :> scc
    scc possible-reps [
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

UNION: inert-tag-untag-imm-insn
##add-imm
##sub-imm
##and-imm
##or-imm
##xor-imm ;

GENERIC: has-peephole-opts? ( insn -- ? )

M: insn                     has-peephole-opts? drop f ;
M: ##load-integer           has-peephole-opts? drop t ;
M: ##load-reference         has-peephole-opts? drop t ;
M: inert-tag-untag-insn     has-peephole-opts? drop t ;
M: inert-tag-untag-imm-insn has-peephole-opts? drop t ;
M: ##mul-imm                has-peephole-opts? drop t ;
M: ##shl-imm                has-peephole-opts? drop t ;
M: ##shr-imm                has-peephole-opts? drop t ;
M: ##sar-imm                has-peephole-opts? drop t ;
M: ##neg                    has-peephole-opts? drop t ;
M: ##not                    has-peephole-opts? drop t ;

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
