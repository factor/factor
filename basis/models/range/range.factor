! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel models arrays sequences math math.order
models.product ;
FROM: models.product => product ;
IN: models.range

TUPLE: range < product ;

: <range> ( value page min max -- range )
    4array [ <model> ] map range new-product ;

: range-model ( range -- model ) dependencies>> first ;
: range-page ( range -- model ) dependencies>> second ;
: range-min ( range -- model ) dependencies>> third ;
: range-max ( range -- model ) dependencies>> fourth ;

M: range range-value
    [ range-model value>> ] keep clamp-value ;

M: range range-page-value range-page value>> ;

M: range range-min-value range-min value>> ;

M: range range-max-value range-max value>> ;

M: range range-max-value*
    [ range-max-value ] [ range-page-value ] bi [-] ;

M: range set-range-value
    [ clamp-value ] [ range-model ] bi set-model ;

M: range set-range-page-value range-page set-model ;

M: range set-range-min-value range-min set-model ;

M: range set-range-max-value range-max set-model ;

: move-by ( amount range -- )
    [ range-value + ] keep set-range-value ;

: move-by-page ( amount range -- )
    [ range-page-value * ] keep move-by ;
