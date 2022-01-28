! Copyright (C) 2022 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs biassocs fonts kernel math.combinatorics
ranges sequences sequences.extras strings ui.text unicode.flags ;
IN: unicode.flags.images

MEMO: valid-flags ( -- flags )
    CHAR: a CHAR: z [a..b] 2 all-combinations-with-replacement
    [ >string unicode>flag ]
    [ monospace-font swap string>image drop dim>> first2 = ] map-filter ;

: valid-flag-names ( -- seq )
    valid-flags [ flag>unicode ] map ;

: valid-flag-biassoc ( -- biassoc )
    valid-flags valid-flag-names zip >biassoc ;
