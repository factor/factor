! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs binary-search combinators
compiler.cfg.def-use compiler.cfg.instructions
compiler.cfg.linear-scan.ranges compiler.cfg.linearization
compiler.cfg.liveness compiler.cfg.registers
compiler.cfg.ssa.destruction.leaders cpu.architecture fry kernel locals math
math.intervals math.order namespaces sequences ;
IN: compiler.cfg.linear-scan.live-intervals

TUPLE: vreg-use n def-rep use-rep spill-slot? ;

: <vreg-use> ( n -- vreg-use ) vreg-use new swap >>n ;

TUPLE: live-interval-state
    vreg
    reg spill-to spill-rep reload-from reload-rep
    start end ranges uses ;

: first-use ( live-interval -- use ) uses>> first ; inline

: last-use ( live-interval -- use ) uses>> last ; inline

: new-use ( insn# uses -- use )
    [ <vreg-use> dup ] dip push ;

: last-use? ( insn# uses -- use/f )
    [ drop f ] [ last [ n>> = ] keep and ] if-empty ;

:: (add-use) ( insn# live-interval spill-slot? -- use )
    live-interval uses>> :> uses
    insn# uses last-use? [ insn# uses new-use ] unless*
    spill-slot? [ t >>spill-slot? ] when ;

: covers? ( n live-interval -- ? )
    ranges>> ranges-cover? ;

: (find-use) ( insn# live-interval -- vreg-use )
    uses>> [ n>> <=> ] with search nip ;

:: find-use ( insn# live-interval -- vreg-use )
    insn# live-interval (find-use)
    dup [ dup n>> insn# = [ drop f ] unless ] when ;

: <live-interval> ( vreg -- live-interval )
    \ live-interval-state new
        V{ } clone >>uses
        V{ } clone >>ranges
        swap >>vreg ;

: block-from ( bb -- n ) instructions>> first insn#>> 1 - ;

: block-to ( bb -- n ) instructions>> last insn#>> ;

SYMBOLS: from to ;

SYMBOL: live-intervals

: live-interval ( vreg -- live-interval )
    leader live-intervals get [ <live-interval> ] cache ;

: interval-reg-class ( live-interval -- reg-class )
    vreg>> rep-of reg-class-of ;

GENERIC: compute-live-intervals* ( insn -- )

M: insn compute-live-intervals* drop ;

:: record-def ( vreg n spill-slot? -- )
    vreg live-interval :> live-interval

    n live-interval ranges>> shorten-ranges
    n live-interval spill-slot? (add-use) vreg rep-of >>def-rep drop ;

:: record-use ( vreg n spill-slot? -- )
    vreg live-interval :> live-interval

    from get n live-interval ranges>> add-range
    n live-interval spill-slot? (add-use) vreg rep-of >>use-rep drop ;

:: record-temp ( vreg n -- )
    vreg live-interval :> live-interval

    n n live-interval ranges>> add-range
    n live-interval f (add-use) vreg rep-of >>def-rep drop ;

M: vreg-insn compute-live-intervals* ( insn -- )
    dup insn#>>
    [ [ defs-vregs ] dip '[ _ f record-def ] each ]
    [ [ uses-vregs ] dip '[ _ f record-use ] each ]
    [ [ temp-vregs ] dip '[ _ record-temp ] each ]
    2tri ;

! Extend lifetime intervals of base pointers, so that their
! values are available even if the base pointer is never used
! again.

GENERIC: uses-vregs* ( insn -- seq )

M: gc-map-insn uses-vregs*
    [ uses-vregs ] [ gc-map>> derived-roots>> values ] bi append ;

M: vreg-insn uses-vregs* uses-vregs ;

M: insn uses-vregs* drop f ;

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
    [ live-interval ranges>> add-range ] 2with each ;

: compute-live-intervals-step ( bb -- )
    {
        [ block-from from set ]
        [ block-to to set ]
        [ handle-live-out ]
        [ instructions>> <reversed> [ compute-live-intervals* ] each ]
    } cleave ;

: compute-start/end ( live-interval -- )
    dup ranges>> ranges-endpoints [ >>start ] [ >>end ] bi* drop ;

ERROR: bad-live-interval live-interval ;

: check-start ( live-interval -- )
    dup start>> -1 = [ bad-live-interval ] [ drop ] if ;

: finish-live-intervals ( live-intervals -- )
    [
        {
            [ [ { } like reverse! ] change-ranges drop ]
            [ [ { } like reverse! ] change-uses drop ]
            [ compute-start/end ]
            [ check-start ]
        } cleave
    ] each ;

TUPLE: sync-point n keep-dst? ;

C: <sync-point> sync-point

GENERIC: insn>sync-point ( insn -- sync-point/f )

M: hairy-clobber-insn insn>sync-point
    insn#>> f <sync-point> ;

M: clobber-insn insn>sync-point
    insn#>> t <sync-point> ;

M: insn insn>sync-point drop f ;

: cfg>sync-points ( cfg -- sync-points )
    cfg>insns [ insn>sync-point ] map sift ;

: cfg>live-intervals ( cfg -- live-intervals )
    H{ } clone live-intervals set
    linearization-order <reversed> [ compute-live-intervals-step ] each
    live-intervals get values dup finish-live-intervals ;

: compute-live-intervals ( cfg -- intervals/sync-points )
    [ cfg>live-intervals ] [ cfg>sync-points ] bi append ;

: intersect-intervals ( interval1 interval2 -- n/f )
    [ ranges>> ] bi@ intersect-ranges ;

: intervals-intersect? ( interval1 interval2 -- ? )
    intersect-intervals >boolean ; inline
