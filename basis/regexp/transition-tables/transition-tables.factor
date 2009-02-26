! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs fry hashtables kernel sequences
vectors locals ;
IN: regexp.transition-tables

TUPLE: transition-table transitions start-state final-states ;

: <transition-table> ( -- transition-table )
    transition-table new
        H{ } clone >>transitions
        H{ } clone >>final-states ;

: maybe-initialize-key ( key hashtable -- )
    2dup key? [ 2drop ] [ [ H{ } clone ] 2dip set-at ] if ;

:: set-transition ( from to obj hash -- )
    to hash maybe-initialize-key
    from hash at
    [ [ to obj ] dip push-at ]
    [ to 1vector obj associate from hash set-at ] if* ;

: add-transition ( from to obj transition-table -- )
    transitions>> set-transition ;
