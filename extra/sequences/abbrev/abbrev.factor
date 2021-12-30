! Copyright (C) 2009 Maximilian Lupke.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel ranges sequences ;
IN: sequences.abbrev

<PRIVATE

: prefixes ( seq -- prefixes )
    dup length [1..b] [ head ] with map ;

PRIVATE>

: abbrev ( seqs -- assoc )
    H{ } clone [
        '[ dup prefixes [ _ push-at ] with each ] each
    ] keep ;

: unique-abbrev ( seqs -- assoc )
    abbrev [ nip length 1 = ] assoc-filter ;
