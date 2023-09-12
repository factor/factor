! Copyright (C) 2009 Maximilian Lupke.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs assocs.extras kernel ranges sequences ;
IN: sequences.abbrev

<PRIVATE

: prefixes ( seq -- prefixes )
    dup length [1..b] [ head ] with map ;

PRIVATE>

: abbrev ( seqs -- assoc )
    H{ } clone [
        swap [ dup prefixes rot push-at-each ] with each
    ] keep ;

: unique-abbrev ( seqs -- assoc )
    abbrev [ length 1 = ] filter-values ;
