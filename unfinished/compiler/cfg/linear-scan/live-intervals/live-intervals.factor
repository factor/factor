! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces kernel assocs accessors sequences math fry
compiler.cfg.instructions compiler.cfg.registers ;
IN: compiler.cfg.linear-scan.live-intervals

TUPLE: live-interval < identity-tuple
vreg
reg spill-to reload-from split-before split-after
start end uses ;

: <live-interval> ( start vreg -- live-interval )
    live-interval new
        swap >>vreg
        swap >>start
        V{ } clone >>uses ;

M: live-interval hashcode*
    nip [ start>> ] [ end>> 1000 * ] bi + ;

M: live-interval clone
    call-next-method [ clone ] change-uses ;

! Mapping from vreg to live-interval
SYMBOL: live-intervals

: add-use ( n vreg live-intervals -- )
    at [ (>>end) ] [ uses>> push ] 2bi ;

: new-live-interval ( n vreg live-intervals -- )
    2dup key? [ "Multiple defs" throw ] when
    [ [ <live-interval> ] keep ] dip set-at ;

: compute-live-intervals* ( insn n -- )
    live-intervals get
    [ [ uses-vregs ] 2dip '[ _ swap >vreg _ add-use ] each ]
    [ [ defs-vregs ] 2dip '[ _ swap >vreg _ new-live-interval ] each ]
    3bi ;

: finalize-live-intervals ( assoc -- seq' )
    #! Reverse uses lists so that we can pop values off.
    values dup [ uses>> reverse-here ] each ;

: compute-live-intervals ( instructions -- live-intervals )
    H{ } clone [
        live-intervals [
            [ compute-live-intervals* ] each-index
        ] with-variable
    ] keep finalize-live-intervals ;
