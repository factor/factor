! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces kernel assocs accessors sequences math fry
compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.def-use ;
IN: compiler.cfg.linear-scan.live-intervals

TUPLE: live-interval
vreg
reg spill-to reload-from split-before split-after
start end uses ;

: add-use ( n live-interval -- )
    dup live-interval? [ "No def" throw ] unless
    [ (>>end) ] [ uses>> push ] 2bi ;

: <live-interval> ( start vreg -- live-interval )
    live-interval new
        V{ } clone >>uses
        swap >>vreg
        over >>start
        [ add-use ] keep ;

M: live-interval hashcode*
    nip [ start>> ] [ end>> 1000 * ] bi + ;

M: live-interval clone
    call-next-method [ clone ] change-uses ;

! Mapping from vreg to live-interval
SYMBOL: live-intervals

: new-live-interval ( n vreg live-intervals -- )
    2dup key? [
        at add-use
    ] [
        [ [ <live-interval> ] keep ] dip set-at
    ] if ;

: compute-live-intervals* ( insn n -- )
    live-intervals get
    [ [ uses-vregs ] 2dip '[ _ swap _ at add-use ] each ]
    [ [ defs-vregs ] 2dip '[ _ swap _ new-live-interval ] each ]
    3bi ;

: compute-live-intervals ( instructions -- live-intervals )
    H{ } clone [
        live-intervals set
        [ compute-live-intervals* ] each-index
    ] keep values ;
