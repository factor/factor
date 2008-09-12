! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces kernel assocs accessors sequences math
math.order sorting compiler.instructions compiler.registers ;
IN: compiler.cfg.linear-scan.live-intervals

TUPLE: live-interval < identity-tuple vreg start end ;

M: live-interval hashcode* nip [ start>> ] [ end>> 1000 * ] bi + ;

! Mapping from vreg to live-interval
SYMBOL: live-intervals

: update-live-interval ( n vreg -- )
    >vreg
    live-intervals get
    [ over f live-interval boa ] cache
    (>>end) ;

: compute-live-intervals* ( n insn -- )
    uses-vregs [ update-live-interval ] with each ;

: sort-live-intervals ( assoc -- seq' )
    #! Sort by increasing start location.
    values [ [ start>> ] compare ] sort ;

: compute-live-intervals ( instructions -- live-intervals )
    H{ } clone [
        live-intervals [
            [ swap compute-live-intervals* ] each-index
        ] with-variable
    ] keep sort-live-intervals ;
