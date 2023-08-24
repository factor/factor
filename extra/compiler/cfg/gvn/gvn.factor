! Copyright (C) 2008, 2010 Slava Pestov, 2011 Alex Vondrak
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs compiler.cfg compiler.cfg.def-use
compiler.cfg.gvn.avail compiler.cfg.gvn.expressions
compiler.cfg.gvn.graph compiler.cfg.gvn.rewrite
compiler.cfg.instructions compiler.cfg.predecessors
compiler.cfg.rpo compiler.cfg.utilities grouping kernel
namespaces sequences sequences.deep ;
IN: compiler.cfg.gvn

GENERIC: simplify ( insn -- insn' )

M: insn simplify [ rewrite ] [ simplify ] [ dup >avail-insn-uses ] ?if ;
M: array simplify [ simplify ] map ;
M: ##copy simplify ;

! ! ! Global value numbering

GENERIC: value-number ( insn -- )

M: array value-number [ value-number ] each ;

: record-defs ( insn -- ) defs-vregs [ dup set-vn ] each ;

M: alien-call-insn value-number record-defs ;
M: ##callback-inputs value-number record-defs ;

M: ##copy value-number [ src>> vreg>vn ] [ dst>> ] bi set-vn ;

: redundant-instruction ( insn vn -- )
    swap dst>> set-vn ;

:: useful-instruction ( insn expr -- )
    insn dst>> :> vn
    vn vn set-vn
    vn expr exprs>vns get set-at
    insn vn vns>insns get set-at ;

: check-redundancy ( insn -- )
    dup >expr
    [ exprs>vns get at ]
    [ redundant-instruction ] [ useful-instruction ] ?if ;

M: ##phi value-number
    dup inputs>> values [ vreg>vn ] map sift
    dup all-equal? [
        [ drop ] [ first redundant-instruction ] if-empty
    ] [ drop check-redundancy ] if ;

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

: defs-available ( insn -- insn )
    dup defs-vregs [ make-available ] each ;

M: alien-call-insn gcse defs-available ;
M: ##callback-inputs gcse defs-available ;
M: ##copy gcse defs-available ;

: ?eliminate ( insn vn -- insn' )
    dup available? [
        [ dst>> dup make-available ] dip <copy>
    ] [ drop defs-available ] if ;

: eliminate-redundancy ( insn -- insn' )
    dup >expr exprs>vns get at >avail-vreg
    [ ?eliminate ] [ defs-available ] if* ;

M: ##phi gcse
    dup inputs>> values [ vreg>vn ] map sift
    dup all-equal? [
        [ first ?eliminate ] unless-empty
    ] [ drop eliminate-redundancy ] if ;

M: insn gcse
    dup defs-vregs length 1 = [ eliminate-redundancy ] when ;

: gcse-step ( insns -- insns' )
    [ simplify gcse ] map flatten ;

: eliminate-common-subexpressions ( cfg -- )
    final-iteration? on
    compute-congruence-classes
    dup compute-avail-sets
    [ gcse-step ] simple-optimization ;

: value-numbering ( cfg -- )
    {
        needs-predecessors
        determine-value-numbers
        eliminate-common-subexpressions
        cfg-changed
        predecessors-changed
    } apply-passes ;
