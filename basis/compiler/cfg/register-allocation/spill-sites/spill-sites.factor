! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.cfg.instructions
compiler.cfg.linear-scan.live-intervals compiler.cfg.registers cpu.architecture
compiler.cfg.linearization compiler.cfg.loop-detection kernel locals
math math.functions math.order namespaces sequences ;
IN: compiler.cfg.register-allocation.spill-sites

SYMBOL: backtracking-loop-spills?
SYMBOL: spill-site-weights
SYMBOL: loop-spill-site-count
SYMBOL: cold-spill-safe?
SYMBOL: cold-spill-values
SYMBOL: cold-spill-store-count

:: prepare-spill-sites ( cfg -- )
    0 loop-spill-site-count set
    0 cold-spill-store-count set
    f cold-spill-safe? set
    backtracking-loop-spills? get [
        cfg needs-loops
        cfg cfg>insns [ gc-map-insn? ] any? not cold-spill-safe? set
        H{ } clone :> weights
        cfg linearization-order [| bb |
            8 bb loop-nesting-at 3 min ^ :> weight
            bb instructions>> [ insn#>> weight swap weights set-at ] each
        ] each
        weights
    ] [ f ] if spill-site-weights set ;

: spill-site-weight ( use -- weight )
    n>> spill-site-weights get at 1 or ;

: backtracking-use-weight ( intervals -- weight )
    backtracking-loop-spills? get
    [ [ uses>> [ spill-site-weight ] map-sum ] map-sum ]
    [ [ uses>> length ] map-sum ] if ;

:: cold-definition? ( interval -- ? )
    interval uses>> :> uses
    uses length 1 > [
        uses first def-rep>> int-rep eq?
        uses [ def-rep>> ] count 1 = and
        uses first spill-site-weight 1 = and
        uses second spill-site-weight 1 > and
        uses [ spill-slot?>> ] any? not and
        interval vreg>> rep-of int-rep eq? and
    ] [ f ] if ;

: prepare-cold-spills ( intervals/syncs -- )
    cold-spill-safe? get backtracking-loop-spills? get and [
        [ live-interval-state? ] filter [ cold-definition? ] filter
        [ vreg>> dup ] H{ } map>assoc
    ] [ drop f ] if cold-spill-values set ;

:: redundant-cold-spill? ( interval -- ? )
    interval vreg>> cold-spill-values get key?
    interval spill-to>> >boolean and
    interval reload-from>> interval spill-to>> = and
    interval reload-rep>> interval spill-rep>> eq? and
    interval uses>> [ def-rep>> ] any? not and ;

! A unique cold definition establishes this private slot. A fragment that
! only reads the same slot cannot change its bits, so storing its reload
! back again is redundant. GC-map CFGs and ABI memory values are excluded.
: finish-loop-spills ( intervals -- intervals )
    backtracking-loop-spills? get [
        dup [
            dup redundant-cold-spill? [
                f >>spill-to cold-spill-store-count inc
            ] when drop
        ] each
    ] when ;

:: split-site-cost ( index uses -- cost )
    index 1 - uses nth spill-site-weight
    index uses nth spill-site-weight + ;

:: loop-transition? ( index uses -- ? )
    index 1 - uses nth spill-site-weight
    index uses nth spill-site-weight = not ;

! The ordinary splitter stores after the last preceding use and reloads
! before the first following use. Score these actual sites, rather than
! assuming that splitting at a block boundary also hoists memory traffic.
! Keep at least one quarter of the uses on either side: every recursive
! split makes geometric progress even for deeply nested or huge loops.
:: cooler-spill-site ( uses -- index )
    uses length :> length
    length 2 /i :> best!
    best uses split-site-cost :> cost!
    cost :> median-cost
    best :> median
    length 3 + 4 /i 1 max :> lower
    length 3 * 4 /i length 1 - min :> upper
    upper lower - 1 + <iota> [| offset |
        offset lower + :> index
        index uses split-site-cost :> candidate
        candidate cost < candidate cost =
        index median - abs best median - abs < and or
        candidate median-cost < and
        index uses loop-transition? and [
            candidate cost!
            index best!
        ] when
    ] each
    best ;

:: backtracking-spill-site ( interval -- position )
    interval uses>> :> uses
    uses length 2 /i :> median
    backtracking-loop-spills? get
    interval vreg>> cold-spill-values get key? and
    uses first def-rep>> >boolean and [
        ! This exceptional one-definition cut can occur only once. The
        ! remaining fragments have no defs and use balanced splitting.
        loop-spill-site-count inc
        uses first n>> 1 +
    ] [ backtracking-loop-spills? get [
        uses cooler-spill-site dup median = [ ] [ loop-spill-site-count inc ] if
    ] [ median ] if
    uses nth n>> 1 - ] if ;
