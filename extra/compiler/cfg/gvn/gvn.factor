! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces arrays assocs hashtables kernel accessors fry
grouping sorting sets sequences locals
cpu.architecture
sequences.deep
compiler.cfg
compiler.cfg.rpo
compiler.cfg.def-use
compiler.cfg.utilities
compiler.cfg.instructions
compiler.cfg.predecessors
compiler.cfg.gvn.alien
compiler.cfg.gvn.avail
compiler.cfg.gvn.comparisons
compiler.cfg.gvn.graph
compiler.cfg.gvn.math
compiler.cfg.gvn.rewrite
compiler.cfg.gvn.slots
compiler.cfg.gvn.misc
compiler.cfg.gvn.expressions ;
IN: compiler.cfg.gvn

GENERIC: simplify ( insn -- insn' )

M: insn simplify dup rewrite [ simplify ] [ ] ?if ;
M: array simplify [ simplify ] map ;
M: ##copy simplify ;

! ! ! Global value numbering

GENERIC: value-number ( insn -- )

M: array value-number [ value-number ] each ;

M: alien-call-insn value-number drop ;
M: ##callback-inputs value-number drop ;

M: ##copy value-number [ src>> vreg>vn ] [ dst>> ] bi set-vn ;

: redundant-instruction ( insn vn -- )
    swap dst>> set-vn ;

:: useful-instruction ( insn expr -- )
    insn dst>> :> vn
    vn vn set-vn
    vn expr exprs>vns get set-at
    insn vn vns>insns get set-at ;

: check-redundancy ( insn -- )
    dup >expr dup exprs>vns get at
    [ redundant-instruction ] [ useful-instruction ] ?if ;

! M: ##phi value-number
!     dup inputs>> values [ vreg>vn ] map sift
!     dup all-equal? [
!         [ drop ] [ first redundant-instruction ] if-empty
!     ] [ drop check-redundancy ] if ;

M: insn value-number
    dup defs-vregs length 1 = [ check-redundancy ] [ drop ] if ;

: value-numbering-step ( insns -- )
    [ simplify value-number ] each ;

: value-numbering-iteration ( cfg -- )
    clear-exprs [ value-numbering-step ] simple-analysis ;

: determine-value-numbers ( cfg -- )
    final-iteration? off
    init-value-graph
    '[
        changed? off
        _ value-numbering-iteration
        changed? get
    ] loop ;

! ! ! Global common subexpression elimination

GENERIC: gcse ( insn -- insn' )

M: array gcse [ gcse ] map ;

M: alien-call-insn gcse ;
M: ##callback-inputs gcse ;
M: ##copy gcse ;

: ?eliminate ( insn vn -- insn' )
    dup available? [
        [ dst>> ] dip <copy>
    ] [ drop make-available ] if ;

: eliminate-redundancy ( insn -- insn' )
    dup >expr exprs>vns get at
    [ ?eliminate ] [ make-available ] if* ;

! M: ##phi gcse
!     dup inputs>> values [ vreg>vn ] map sift
!     dup all-equal? [
!         [ first ?eliminate ] unless-empty
!     ] [ drop eliminate-redundancy ] if ;

M: insn gcse
    dup defs-vregs length 1 = [ eliminate-redundancy ] when ;

: gcse-step ( insns -- insns' )
    ! [ simplify gcse ] map flatten ;
    [ gcse ] map flatten ;

: eliminate-common-subexpressions ( cfg -- )
    final-iteration? on
    dup compute-avail-sets
    [ gcse-step ] simple-optimization ;

: value-numbering ( cfg -- cfg )
    needs-predecessors
    dup determine-value-numbers
    dup eliminate-common-subexpressions

    cfg-changed predecessors-changed ;
