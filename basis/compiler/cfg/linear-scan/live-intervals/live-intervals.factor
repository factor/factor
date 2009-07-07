! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces kernel assocs accessors sequences math math.order fry
combinators compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.def-use compiler.cfg.liveness compiler.cfg ;
IN: compiler.cfg.linear-scan.live-intervals

TUPLE: live-range from to ;

C: <live-range> live-range

TUPLE: live-interval
vreg
reg spill-to reload-from
split-before split-after split-next
start end ranges uses
copy-from ;

: covers? ( insn# live-interval -- ? )
    ranges>> [ [ from>> ] [ to>> ] bi between? ] with any? ;

: child-interval-at ( insn# interval -- interval' )
    dup split-after>> [
        2dup split-after>> start>> <
        [ split-before>> ] [ split-after>> ] if
        child-interval-at
    ] [ nip ] if ;

ERROR: dead-value-error vreg ;

: shorten-range ( n live-interval -- )
    dup ranges>> empty?
    [ vreg>> dead-value-error ] [ ranges>> last (>>from) ] if ;

: extend-range ( from to live-range -- )
    ranges>> last
    [ max ] change-to
    [ min ] change-from
    drop ;

: add-new-range ( from to live-interval -- )
    [ <live-range> ] dip ranges>> push ;

: extend-range? ( to live-interval -- ? )
    ranges>> [ drop f ] [ last from>> >= ] if-empty ;

: add-range ( from to live-interval -- )
    2dup extend-range?
    [ extend-range ] [ add-new-range ] if ;

: add-use ( n live-interval -- )
    uses>> push ;

: <live-interval> ( vreg -- live-interval )
    \ live-interval new
        V{ } clone >>uses
        V{ } clone >>ranges
        swap >>vreg ;

: block-from ( bb -- n ) instructions>> first insn#>> 1 - ;

: block-to ( bb -- n ) instructions>> last insn#>> ;

M: live-interval hashcode*
    nip [ start>> ] [ end>> 1000 * ] bi + ;

M: live-interval clone
    call-next-method [ clone ] change-uses ;

! Mapping from vreg to live-interval
SYMBOL: live-intervals

: live-interval ( vreg live-intervals -- live-interval )
    [ <live-interval> ] cache ;

GENERIC: compute-live-intervals* ( insn -- )

M: insn compute-live-intervals* drop ;

: handle-output ( n vreg live-intervals -- )
    live-interval
    [ add-use ] [ shorten-range ] 2bi ;

: handle-input ( n vreg live-intervals -- )
    live-interval
    [ [ basic-block get block-from ] 2dip add-range ] [ add-use ] 2bi ;

: handle-temp ( n vreg live-intervals -- )
    live-interval
    [ dupd add-range ] [ add-use ] 2bi ;

M: vreg-insn compute-live-intervals*
    dup insn#>>
    live-intervals get
    [ [ defs-vregs ] 2dip '[ [ _ ] dip _ handle-output ] each ]
    [ [ uses-vregs ] 2dip '[ [ _ ] dip _ handle-input ] each ]
    [ [ temp-vregs ] 2dip '[ [ _ ] dip _ handle-temp ] each ]
    3tri ;

: record-copy ( insn -- )
    [ dst>> live-intervals get at ] [ src>> ] bi >>copy-from drop ;

M: ##copy compute-live-intervals*
    [ call-next-method ] [ record-copy ] bi ;

M: ##copy-float compute-live-intervals*
    [ call-next-method ] [ record-copy ] bi ;

: handle-live-out ( bb -- )
    live-out keys
    basic-block get [ block-from ] [ block-to ] bi
    live-intervals get '[
        [ _ _ ] dip _ live-interval add-range
    ] each ;

: compute-live-intervals-step ( bb -- )
    [ basic-block set ]
    [ handle-live-out ]
    [ instructions>> <reversed> [ compute-live-intervals* ] each ] tri ;

: compute-start/end ( live-interval -- )
    dup ranges>> [ first from>> ] [ last to>> ] bi
    [ >>start ] [ >>end ] bi* drop ;

: check-start/end ( live-interval -- )
    [ [ start>> ] [ uses>> first ] bi assert= ]
    [ [ end>> ] [ uses>> last ] bi assert= ]
    bi ;

: finish-live-intervals ( live-intervals -- )
    ! Since live intervals are computed in a backward order, we have
    ! to reverse some sequences, and compute the start and end.
    [
        {
            [ ranges>> reverse-here ]
            [ uses>> reverse-here ]
            [ compute-start/end ]
            [ check-start/end ]
        } cleave
    ] each ;

: compute-live-intervals ( rpo -- live-intervals )
    H{ } clone [
        live-intervals set
        <reversed> [ compute-live-intervals-step ] each
    ] keep values dup finish-live-intervals ;

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