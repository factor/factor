! Copyright (C) 2026 Factor authors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.cfg compiler.cfg.def-use
compiler.cfg.instructions compiler.cfg.rpo kernel locals
sequences ;
IN: compiler.cfg.multiply-negate

:: fuse-negated-product ( insn definitions use-counts -- insn' )
    insn ##neg? [
        insn src>> :> product
        product definitions at :> multiply
        multiply ##mul? product use-counts at 1 = and [
            insn dst>> multiply src1>> multiply src2>> ##mneg new-insn
        ] [ insn ] if
    ] [ insn ] if ;

! Run after copy propagation while the CFG is still in SSA form. Counting
! uses across every block prevents duplicating a multiply used elsewhere.
! The following DCE pass removes the now-unused original multiplication.
:: fuse-multiply-negate ( cfg -- )
    cfg post-order :> blocks
    blocks [ instructions>> [ ##neg? ] any? ] any? [
        H{ } clone :> definitions
        H{ } clone :> use-counts
        blocks [ instructions>> [| insn |
            insn defs-vregs [ insn swap definitions set-at ] each
            insn uses-vregs [ use-counts inc-at ] each
        ] each ] each
        cfg [
            [ definitions use-counts fuse-negated-product ] map
        ] simple-optimization
        cfg cfg-changed
    ] when ;
