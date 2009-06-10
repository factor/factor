! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces kernel assocs accessors sequences math math.order fry
binary-search compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.def-use compiler.cfg.liveness compiler.cfg ;
IN: compiler.cfg.linear-scan.live-intervals

TUPLE: live-range from to ;

C: <live-range> live-range

TUPLE: live-interval
vreg
reg spill-to reload-from split-before split-after
start end ranges uses
copy-from ;

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

: block-from ( -- n )
    basic-block get instructions>> first insn#>> ;

: block-to ( -- n )
    basic-block get instructions>> last insn#>> ;

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
    [ [ block-from ] 2dip add-range ] [ add-use ] 2bi ;

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
    live-out keys block-from block-to live-intervals get '[
        [ _ _ ] dip _ live-interval add-range
    ] each ;

: compute-live-intervals-step ( bb -- )
    [ basic-block set ]
    [ handle-live-out ]
    [ instructions>> <reversed> [ compute-live-intervals* ] each ] tri ;

: compute-start/end ( live-interval -- )
    dup ranges>> [ first from>> ] [ last to>> ] bi
    2dup > [ "BUG: start > end" throw ] when
    [ >>start ] [ >>end ] bi* drop ;

: finish-live-intervals ( live-intervals -- )
    ! Since live intervals are computed in a backward order, we have
    ! to reverse some sequences, and compute the start and end.
    [
        [ ranges>> reverse-here ]
        [ uses>> reverse-here ]
        [ compute-start/end ]
        tri
    ] each ;

: compute-live-intervals ( rpo -- live-intervals )
    H{ } clone [
        live-intervals set
        <reversed> [ compute-live-intervals-step ] each
    ] keep values dup finish-live-intervals ;
