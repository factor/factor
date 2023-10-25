! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel models arrays sequences math math.order
models.product generalizations sequences.generalizations
math.functions ;
FROM: models.product => product ;
IN: models.range

TUPLE: range < product ;

: <range> ( value page min max step -- range )
    5 narray [ <model> ] map range new-product ;

: range-model ( range -- model ) dependencies>> first ;
: range-page ( range -- model ) dependencies>> second ;
: range-min ( range -- model ) dependencies>> third ;
: range-max ( range -- model ) dependencies>> fourth ;
: range-step ( range -- model ) dependencies>> 4 swap nth ;

: step-value ( value range -- value' )
    range-step value>> floor-to ;

DEFER: clamp-value

: range-value ( range -- value )
    [ range-model value>> ] [ clamp-value ] [ step-value ] tri ;

: range-page-value ( range -- value ) range-page value>> ;

: range-min-value ( range -- value ) range-min value>> ;

: range-max-value ( range -- value ) range-max value>> ;

: range-max-value* ( range -- value )
    [ range-max-value ] [ range-page-value ] bi [-] ;

: clamp-value ( value range -- newvalue )
    [ range-min-value ] [ range-max-value* ] bi clamp ;

: set-range-value ( value range -- )
    [ clamp-value ] [ range-model ] bi set-model ;

: set-range-page-value ( value range -- ) range-page set-model ;

: set-range-min-value ( value range -- ) range-min set-model ;

: set-range-max-value ( value range -- ) range-max set-model ;

: move-by ( amount range -- )
    [ range-value + ] keep set-range-value ;

: move-by-page ( amount range -- )
    [ range-page-value * ] keep move-by ;
