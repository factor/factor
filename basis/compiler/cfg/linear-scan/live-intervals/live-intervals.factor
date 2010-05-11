! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces kernel assocs accessors locals sequences math
math.order fry combinators binary-search
compiler.cfg.instructions
compiler.cfg.registers
compiler.cfg.def-use
compiler.cfg.liveness
compiler.cfg.linearization
compiler.cfg.ssa.destruction
compiler.cfg
cpu.architecture ;
IN: compiler.cfg.linear-scan.live-intervals

TUPLE: live-range from to ;

C: <live-range> live-range

TUPLE: vreg-use n def-rep use-rep ;

: <vreg-use> ( n -- vreg-use ) vreg-use new swap >>n ;

TUPLE: live-interval
vreg
reg spill-to spill-rep reload-from reload-rep
start end ranges uses
reg-class ;

: first-use ( live-interval -- use ) uses>> first ; inline

: last-use ( live-interval -- use ) uses>> last ; inline

: new-use ( insn# uses -- use )
    [ <vreg-use> dup ] dip push ;

: last-use? ( insn# uses -- use/f )
    [ drop f ] [ last [ n>> = ] keep and ] if-empty ;

: (add-use) ( insn# live-interval -- use )
    uses>> 2dup last-use? dup [ 2nip ] [ drop new-use ] if ;

GENERIC: covers? ( insn# obj -- ? )

M: f covers? 2drop f ;

M: live-range covers? [ from>> ] [ to>> ] bi between? ;

M: live-interval covers? ( insn# live-interval -- ? )
    ranges>>
    dup length 4 <= [
        [ covers? ] with any?
    ] [
        [ drop ] [ [ from>> <=> ] with search nip ] 2bi
        covers?
    ] if ;

:: find-use ( insn# live-interval -- vreg-use )
    insn# live-interval uses>> [ n>> <=> ] with search nip
    dup [ dup n>> insn# = [ drop f ] unless ] when ;

: add-new-range ( from to live-interval -- )
    [ <live-range> ] dip ranges>> push ;

: shorten-range ( n live-interval -- )
    dup ranges>> empty?
    [ dupd add-new-range ] [ ranges>> last from<< ] if ;

: extend-range ( from to live-range -- )
    ranges>> last
    [ max ] change-to
    [ min ] change-from
    drop ;

: extend-range? ( to live-interval -- ? )
    ranges>> [ drop f ] [ last from>> >= ] if-empty ;

: add-range ( from to live-interval -- )
    2dup extend-range?
    [ extend-range ] [ add-new-range ] if ;

: <live-interval> ( vreg reg-class -- live-interval )
    \ live-interval new
        V{ } clone >>uses
        V{ } clone >>ranges
        swap >>reg-class
        swap >>vreg ;

: block-from ( bb -- n ) instructions>> first insn#>> 1 - ;

: block-to ( bb -- n ) instructions>> last insn#>> ;

SYMBOLS: from to ;

! Mapping from vreg to live-interval
SYMBOL: live-intervals

: live-interval ( vreg -- live-interval )
    leader live-intervals get
    [ dup rep-of reg-class-of <live-interval> ] cache ;

GENERIC: compute-live-intervals* ( insn -- )

M: insn compute-live-intervals* drop ;

:: record-def ( vreg n -- )
    vreg live-interval :> live-interval

    n live-interval shorten-range
    n live-interval (add-use) vreg rep-of >>def-rep drop ;

:: record-use ( vreg n -- )
    vreg live-interval :> live-interval

    from get n live-interval add-range
    n live-interval (add-use) vreg rep-of >>use-rep drop ;

:: record-temp ( vreg n -- )
    vreg live-interval :> live-interval

    n n live-interval add-range
    n live-interval (add-use) vreg rep-of >>def-rep drop ;

M: vreg-insn compute-live-intervals* ( insn -- )
    dup insn#>>
    [ [ defs-vreg ] dip '[ _ record-def ] when* ]
    [ [ uses-vregs ] dip '[ _ record-use ] each ]
    [ [ temp-vregs ] dip '[ _ record-temp ] each ]
    2tri ;

: handle-live-out ( bb -- )
    live-out dup assoc-empty? [ drop ] [
        [ from get to get ] dip keys
        [ live-interval add-range ] with with each
    ] if ;

! A location where all registers have to be spilled
TUPLE: sync-point n ;

C: <sync-point> sync-point

! Sequence of sync points
SYMBOL: sync-points

GENERIC: compute-sync-points* ( insn -- )

M: clobber-insn compute-sync-points*
    insn#>> <sync-point> sync-points get push ;

M: insn compute-sync-points* drop ;

: compute-live-intervals-step ( bb -- )
    {
        [ block-from from set ]
        [ block-to to set ]
        [ handle-live-out ]
        [
            instructions>> <reversed> [
                [ compute-live-intervals* ]
                [ compute-sync-points* ]
                bi
            ] each
        ]
    } cleave ;

: init-live-intervals ( -- )
    H{ } clone live-intervals set
    V{ } clone sync-points set ;
    
: compute-start/end ( live-interval -- )
    dup ranges>> [ first from>> ] [ last to>> ] bi
    [ >>start ] [ >>end ] bi* drop ;

ERROR: bad-live-interval live-interval ;

: check-start ( live-interval -- )
    dup start>> -1 = [ bad-live-interval ] [ drop ] if ;

: finish-live-intervals ( live-intervals -- seq )
    ! Since live intervals are computed in a backward order, we have
    ! to reverse some sequences, and compute the start and end.
    values dup [
        {
            [ ranges>> reverse! drop ]
            [ uses>> reverse! drop ]
            [ compute-start/end ]
            [ check-start ]
        } cleave
    ] each ;

: compute-live-intervals ( cfg -- live-intervals sync-points )
    init-live-intervals
    linearization-order <reversed> [ compute-live-intervals-step ] each
    live-intervals get finish-live-intervals
    sync-points get ;

: relevant-ranges ( interval1 interval2 -- ranges1 ranges2 )
    [ [ ranges>> ] bi@ ] [ nip start>> ] 2bi '[ to>> _ >= ] filter ;

: intersect-live-range ( range1 range2 -- n/f )
    2dup [ from>> ] bi@ > [ swap ] when
    2dup [ to>> ] [ from>> ] bi* >= [ nip from>> ] [ 2drop f ] if ;

: intersect-live-ranges ( ranges1 ranges2 -- n )
    {
        { [ over empty? ] [ 2drop f ] }
        { [ dup empty? ] [ 2drop f ] }
        [
            2dup [ first ] bi@ intersect-live-range dup [ 2nip ] [
                drop
                2dup [ first from>> ] bi@ <
                [ [ rest-slice ] dip ] [ rest-slice ] if
                intersect-live-ranges
            ] if
        ]
    } cond ;

: intervals-intersect? ( interval1 interval2 -- ? )
    relevant-ranges intersect-live-ranges >boolean ; inline
