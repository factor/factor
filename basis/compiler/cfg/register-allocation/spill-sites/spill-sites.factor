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
SYMBOL: cold-definition-sites
SYMBOL: established-cold-spills

:: prepare-spill-sites ( cfg -- )
    0 loop-spill-site-count set
    0 cold-spill-store-count set
    f cold-spill-safe? set
    f cold-definition-sites set
    backtracking-loop-spills? get [
        H{ } clone cold-definition-sites set
        cfg needs-loops
        cfg cfg>insns [ gc-map-insn? ] any? not cold-spill-safe? set
        H{ } clone :> weights
        cfg linearization-order [| bb |
            8 bb loop-nesting-at 3 min ^ :> weight
            bb instructions>> [ insn#>> weight swap weights set-at ] each
            weight 1 = [
                bb instructions>> but-last [
                    insn#>> t swap cold-definition-sites get set-at
                ] each
            ] when
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
    interval vreg>> established-cold-spills get at
    interval spill-to>> =
    interval spill-to>> >boolean and
    interval reload-from>> interval spill-to>> = and
    interval reload-rep>> interval spill-rep>> eq? and
    interval uses>> [ def-rep>> ] any? not and ;

:: establishes-cold-spill? ( interval -- ? )
    interval vreg>> cold-spill-values get key?
    interval spill-to>> spill-slot? and
    interval reg>> >boolean and
    interval spill-rep>> int-rep eq? and
    interval uses>> length 1 = and [
        interval first-use :> definition
        definition def-rep>> int-rep eq?
        definition n>> cold-definition-sites get key? and
        interval live-interval-end definition n>> dup 1 + between? and
    ] [ f ] if ;

! Eligibility alone does not establish a slot: mandatory clobber splitting
! can place a defining fragment's store inside a bypassed loop. Require an
! actual allocated store immediately after the unique cold definition,
! ending at its phase point or the following transport point. Both expire
! before the next instruction in that same block. That store dominates all
! uses. Only then can read-only fragments omit their same-slot stores.
: finish-loop-spills ( intervals -- intervals )
    backtracking-loop-spills? get [
        dup [ establishes-cold-spill? ] filter
        [ [ vreg>> ] [ spill-to>> ] bi ] H{ } map>assoc
        established-cold-spills set
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
