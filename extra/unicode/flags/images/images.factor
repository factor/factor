! Copyright (C) 2022 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs biassocs fonts kernel ranges
sequences sequences.extras sequences.product strings ui.text
unicode.flags ;
IN: unicode.flags.images

: two-char-combinations ( -- seq )
    CHAR: a CHAR: z [a..b] dup 2array [ >string ] product-map ;

MEMO: valid-flags ( -- flags )
    two-char-combinations
    [ unicode>flag ]
    [ monospace-font swap string>image drop dim>> first2 = ] map-filter ;

: valid-flag-names ( -- seq )
    valid-flags [ flag>unicode ] map ;

: valid-flag-biassoc ( -- biassoc )
    valid-flags valid-flag-names zip >biassoc ;
