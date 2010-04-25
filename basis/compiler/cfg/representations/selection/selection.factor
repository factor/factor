! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.cfg compiler.cfg.instructions
compiler.cfg.loop-detection compiler.cfg.registers
compiler.cfg.representations.preferred compiler.cfg.rpo
compiler.cfg.utilities compiler.utilities cpu.architecture
deques dlists fry kernel locals math namespaces sequences sets ;
FROM: namespaces => set ;
IN: compiler.cfg.representations.selection

! For every vreg, compute possible representations.
SYMBOL: possibilities

: possible ( vreg -- reps ) possibilities get at ;

: compute-possibilities ( cfg -- )
    H{ } clone [ '[ swap _ adjoin-at ] with-vreg-reps ] keep
    [ members ] assoc-map possibilities set ;

! Compute vregs for which dereferencing cannot be hoisted past
! conditionals, because they might be immediate.
:: check-restriction ( vreg rep -- )
    rep tagged-rep eq? [
        vreg possibilities get
        [ { tagged-rep int-rep } intersect ] change-at
    ] when ;

: compute-restrictions ( cfg -- )
    [
        [
            dup ##load-reference?
            [ drop ] [ [ check-restriction ] each-def-rep ] if
        ] each-non-phi
    ] each-basic-block ;

! For every vreg, compute the cost of keeping it in every possible
! representation.

! Cost map maps vreg to representation to cost.
SYMBOL: costs

: init-costs ( -- )
    ! Initialize cost as 0 for each possibility.
    possibilities get [ [ 0 ] H{ } map>assoc ] assoc-map costs set ;

: 10^ ( n -- x ) 10 <repetition> product ;

: increase-cost ( rep vreg factor -- )
    ! Increase cost of keeping vreg in rep, making a choice of rep less
    ! likely. If the rep is not in the cost alist, it means this
    ! representation is prohibited.
    [ costs get at 2dup key? ] dip
    '[ [ current-loop-nesting 10^ _ * + ] change-at ] [ 2drop ] if ;

:: increase-costs ( vreg preferred factor -- )
    vreg possible [
        dup preferred eq? [ drop ] [ vreg factor increase-cost ] if
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
        [
            [
                compute-insn-costs
            ] each-non-phi
        ] bi
    ] each-basic-block ;

! For every vreg, compute preferred representation, that minimizes costs.
: minimize-costs ( costs -- representations )
    [ nip assoc-empty? not ] assoc-filter
    [ >alist alist-min first ] assoc-map ;

: compute-representations ( cfg -- )
    compute-costs costs get minimize-costs representations set ;

! PHI nodes require special treatment
! If the output of a phi instruction is only used as the input to another
! phi instruction, then we want to use the same representation for both
! if possible.
SYMBOL: phis

: collect-phis ( cfg -- )
    H{ } clone phis set
    [
        phis get
        '[ [ inputs>> values ] [ dst>> ] bi _ set-at ] each-phi
    ] each-basic-block ;

SYMBOL: work-list

: add-to-work-list ( vregs -- )
    work-list get push-all-front ;

: rep-assigned ( vregs -- vregs' )
    representations get '[ _ key? ] filter ;

: rep-not-assigned ( vregs -- vregs' )
    representations get '[ _ key? not ] filter ;

: add-ready-phis ( -- )
    phis get keys rep-assigned add-to-work-list ;

: process-phi ( dst -- )
    ! If dst = phi(src1,src2,...) and dst's representation has been
    ! determined, assign that representation to each one of src1,...
    ! that does not have a representation yet, and process those, too.
    dup phis get at* [
        [ rep-of ] [ rep-not-assigned ] bi*
        [ [ set-rep-of ] with each ] [ add-to-work-list ] bi
    ] [ 2drop ] if ;

: remaining-phis ( -- )
    phis get keys rep-not-assigned { } assert-sequence= ;

: process-phis ( -- )
    <hashed-dlist> work-list set
    add-ready-phis
    work-list get [ process-phi ] slurp-deque
    remaining-phis ;

: compute-phi-representations ( cfg -- )
    collect-phis process-phis ;
