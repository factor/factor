! Copyright (C) 2009 Maximilian Lupke.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs fry kernel math.ranges sequences ;
IN: sequences.abbrev

<PRIVATE

: prefixes ( seq -- prefixes )
    dup length [1,b] [ head ] with map ;

: (abbrev) ( seq -- assoc )
    [ prefixes ] keep 1array '[ _ ] H{ } map>assoc ;

: assoc-merge ( assoc1 assoc2 -- assoc3 )
    [ '[ over _ at [ append ] when* ] assoc-map ] keep swap assoc-union ;

PRIVATE>

: abbrev ( seqs -- assoc )
    [ (abbrev) ] map H{ } [ assoc-merge ] reduce ;

: unique-abbrev ( seqs -- assoc )
    abbrev [ nip length 1 = ] assoc-filter ;
