! Copyright (C) 2009 Maximilian Lupke.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs assocs.extras fry kernel math.ranges sequences ;
IN: sequences.abbrev

<PRIVATE

: prefixes ( seq -- prefixes )
    dup length [1,b] [ head ] with map ;

: (abbrev) ( seq -- assoc )
    [ prefixes ] keep 1array '[ _ ] H{ } map>assoc ;

PRIVATE>

: abbrev ( seqs -- assoc )
    [ (abbrev) ] map [ append ] assoc-collapse ;

: unique-abbrev ( seqs -- assoc )
    abbrev [ nip length 1 = ] assoc-filter ;
