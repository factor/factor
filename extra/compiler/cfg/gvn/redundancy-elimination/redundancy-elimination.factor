! Copyright (C) 2011 Alex Vondrak.
! See http://factorcode.org/license.txt for BSD license.
USING: ;
IN: compiler.cfg.gvn.redundancy-elimination

! ! ! Available expressions analysis

FORWARD-ANALYSIS: avail

M: avail-analysis transfer-set drop defined assoc-union ;

: available? ( vn -- ? )
    basic-block get avail-ins get at key? ;

! ! ! Copy propagation

RENAMING: propagate [ vreg>avail-vn ] [ vreg>avail-vn ] [ drop next-vreg ]

! ! ! Redundancy elimination

! Returns f if insn should be removed
GENERIC: process-instruction ( insn -- insn'/f )

: redundant-instruction ( insn vn -- f ) 2drop f ; inline

: make-available ( vn -- )
    dup basic-block get avail-ins get [ ?set-at ] change-at ;

:: useful-instruction ( insn expr -- insn' )
    insn dst>> :> vn
    vn make-available
    insn propagate-insn-uses ! I think that's right?
    insn ;

: check-redundancy ( insn -- insn'/f )
    dup >expr dup exrs>vns get at
    [ redundant-instruction ] [ useful-instruction ] ?if ;

: check-redundancy? ( insn -- ? )
    defs-vregs {
        [ length 1 = ]
        [ first dup vreg>vn = not ] ! avoid ##copy x x
    } 1&& ;

M: insn process-instruction
    dup rewrite
    [ process-instruction ]
    [ dup check-redundancy? [ check-redundancy ] when ] ?if ;

M: ##copy process-instruction drop f ;

M: array process-instruction [ process-instruction ] map ;

: redundancy-elimination-step ( insns -- insns' )
    [ process-instruction ] map flatten sift ;

: eliminate-redunancies ( cfg -- )
    final-iteration? on ! if vreg>vn uses this to obey avail-ins
    dup compute-avail-sets
    [ redundancy-elimination-step ] simple-optimization ;
