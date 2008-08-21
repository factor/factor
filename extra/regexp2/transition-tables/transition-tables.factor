! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs fry hashtables kernel sequences
vectors ;
IN: regexp2.transition-tables

: insert-at ( value key hash -- )
    2dup at* [
        2nip push
    ] [
        drop >r >r dup vector? [ 1vector ] unless r> r> set-at
    ] if ;

: ?insert-at ( value key hash/f -- hash )
    [ H{ } clone ] unless* [ insert-at ] keep ;

TUPLE: transition from to obj ;
TUPLE: literal-transition < transition ;
TUPLE: class-transition < transition ;
TUPLE: default-transition < transition ;

TUPLE: literal obj ;
TUPLE: class obj ;
TUPLE: default ;
: <literal-transition> ( from to obj -- transition ) literal-transition boa ;
: <class-transition> ( from to obj -- transition ) class-transition boa ;
: <default-transition> ( from to -- transition ) t default-transition boa ;

TUPLE: transition-table transitions
    literals classes defaults
    start-state final-states ;

: <transition-table> ( -- transition-table )
    transition-table new
        H{ } clone >>transitions
        H{ } clone >>final-states ;

: set-transition ( transition hash -- )
    >r [ to>> ] [ obj>> ] [ from>> ] tri r>
    2dup at* [ 2nip insert-at ]
    [ drop >r >r H{ } clone [ insert-at ] keep r> r> set-at ] if ;

: add-transition ( transition transition-table -- )
    transitions>> set-transition ;
