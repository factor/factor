! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs binary-search combinators
compiler.cfg.def-use compiler.cfg.instructions
compiler.cfg.linear-scan.ranges compiler.cfg.linearization
compiler.cfg.liveness compiler.cfg.registers
compiler.cfg.ssa.destruction.leaders cpu.architecture kernel
math math.order namespaces sequences vectors ;
IN: compiler.cfg.linear-scan.live-intervals

TUPLE: vreg-use n def-rep use-rep spill-slot? ;

: <vreg-use> ( n -- vreg-use ) vreg-use new swap >>n ;

TUPLE: live-interval-state
    vreg
    reg spill-to spill-rep reload-from reload-rep
    { ranges vector } { uses vector } ;

: first-use ( live-interval -- use ) uses>> first ; inline

: last-use ( live-interval -- use ) uses>> last ; inline

: new-use ( insn# uses -- use )
    [ <vreg-use> dup ] dip push ;

: last-use? ( insn# uses -- use/f )
    [ drop f ] [ last [ n>> = ] 1verify ] if-empty ;

:: (add-use) ( insn# live-interval spill-slot? -- use )
    live-interval uses>> :> uses
    insn# uses last-use? [ insn# uses new-use ] unless*
    spill-slot? [ t >>spill-slot? ] when ;

: (find-use) ( insn# live-interval -- vreg-use )
    uses>> [ n>> <=> ] with search nip ;

:: find-use ( insn# live-interval -- vreg-use/f )
    insn# live-interval (find-use)
    [ dup n>> insn# = and* ] ?call ;

: <live-interval> ( vreg -- live-interval )
    \ live-interval-state new
        V{ } clone >>uses
        V{ } clone >>ranges
        swap >>vreg ;

: block-from ( bb -- n ) instructions>> first insn#>> 1 - ;

: block-to ( bb -- n ) instructions>> last insn#>> ;

SYMBOLS: from to ;

SYMBOL: live-intervals

: vreg>live-interval ( vreg -- live-interval )
    leader live-intervals get [ <live-interval> ] cache ;

: interval-reg-class ( live-interval -- reg-class )
    vreg>> rep-of reg-class-of ;

GENERIC: compute-live-intervals* ( insn -- )

M: insn compute-live-intervals* drop ;

:: record-def ( vreg n spill-slot? -- )
    vreg vreg>live-interval :> live-interval

    n live-interval ranges>> shorten-ranges
    n live-interval spill-slot? (add-use) vreg rep-of >>def-rep drop ;

:: record-use ( vreg n spill-slot? -- )
    vreg vreg>live-interval :> live-interval

    from get n live-interval ranges>> add-range
    n live-interval spill-slot? (add-use) vreg rep-of >>use-rep drop ;

:: record-temp ( vreg n -- )
    vreg vreg>live-interval :> live-interval

    n n live-interval ranges>> add-range
    n live-interval f (add-use) vreg rep-of >>def-rep drop ;

: uses-vregs* ( insn -- seq )
    dup gc-map-insn? [
        [ uses-vregs ] [ gc-map>> derived-roots>> values ] bi append
    ] [ uses-vregs ] if ;

UNION: hairy-clobber-insn
    alien-call-insn
    ##callback-inputs
    ##callback-outputs
    ##unbox-long-long ;

UNION: clobber-insn
    hairy-clobber-insn
    ##unbox
    ##box
    ##box-long-long ;

M: vreg-insn compute-live-intervals* ( insn -- )
    dup insn#>>
    [ [ defs-vregs ] dip '[ _ f record-def ] each ]
    [ [ uses-vregs* ] dip '[ _ f record-use ] each ]
    [ [ temp-vregs ] dip '[ _ record-temp ] each ]
    2tri ;

M: clobber-insn compute-live-intervals* ( insn -- )
    dup insn#>>
    [ [ defs-vregs ] dip '[ _ f record-def ] each ]
    [ [ uses-vregs* ] dip '[ _ t record-use ] each ]
    [ [ temp-vregs ] dip '[ _ record-temp ] each ]
    2tri ;

M: hairy-clobber-insn compute-live-intervals* ( insn -- )
    dup insn#>>
    [ [ defs-vregs ] dip '[ _ t record-def ] each ]
    [ [ uses-vregs* ] dip '[ _ t record-use ] each ]
    [ [ temp-vregs ] dip '[ _ record-temp ] each ]
    2tri ;

: handle-live-out ( bb -- )
    [ from get to get ] dip live-out keys
    [ vreg>live-interval ranges>> add-range ] 2with each ;

: compute-live-intervals-step ( bb -- )
    {
        [ block-from from set ]
        [ block-to to set ]
        [ handle-live-out ]
        [ instructions>> <reversed> [ compute-live-intervals* ] each ]
    } cleave ;

: live-interval-start ( live-interval -- n )
    ranges>> first first ; inline

: live-interval-end ( live-interval -- n )
    ranges>> last last ; inline

ERROR: bad-live-interval live-interval ;

: check-start ( live-interval -- )
    dup live-interval-start -1 = [ bad-live-interval ] [ drop ] if ;

: finish-live-interval ( live-interval -- )
    [ ranges>> reverse! ] [ uses>> reverse! ] [ check-start ] tri 2drop ;

TUPLE: sync-point n keep-dst? ;

GENERIC: insn>sync-point ( insn -- sync-point/f )

M: clobber-insn insn>sync-point
    [ insn#>> ] [ hairy-clobber-insn? not ] bi sync-point boa ;

M: insn insn>sync-point drop f ;

: cfg>sync-points ( cfg -- sync-points )
    cfg>insns [ insn>sync-point ] map sift ;

: cfg>live-intervals ( cfg -- live-intervals )
    H{ } clone live-intervals set
    linearization-order <reversed> [ compute-live-intervals-step ] each
    live-intervals get values dup [ finish-live-interval ] each ;

: compute-live-intervals ( cfg -- intervals/sync-points )
    [ cfg>live-intervals ] [ cfg>sync-points ] bi append ;

: intersect-intervals ( interval1 interval2 -- n/f )
    [ ranges>> ] bi@ intersect-ranges ;

: intervals-intersect? ( interval1 interval2 -- ? )
    intersect-intervals >boolean ; inline
