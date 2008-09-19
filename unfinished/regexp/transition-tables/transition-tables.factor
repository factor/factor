! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs fry hashtables kernel sequences
vectors regexp.utils ;
IN: regexp.transition-tables

TUPLE: transition from to obj ;
TUPLE: literal-transition < transition ;
TUPLE: class-transition < transition ;
TUPLE: default-transition < transition ;

TUPLE: literal obj ;
TUPLE: class obj ;
TUPLE: default ;
: make-transition ( from to obj class -- obj )
    new
        swap >>obj
        swap >>to
        swap >>from ;

: <literal-transition> ( from to obj -- transition )
    literal-transition make-transition ;
: <class-transition> ( from to obj -- transition )
    class-transition make-transition ;
: <default-transition> ( from to -- transition )
    t default-transition make-transition ;

TUPLE: transition-table transitions start-state final-states ;

: <transition-table> ( -- transition-table )
    transition-table new
        H{ } clone >>transitions
        H{ } clone >>final-states ;

: set-transition ( transition hash -- )
    [ [ to>> ] [ obj>> ] [ from>> ] tri ] dip
    2dup at* [ 2nip insert-at ]
    [ drop >r >r H{ } clone [ insert-at ] keep r> r> set-at ] if ;

: add-transition ( transition transition-table -- )
    transitions>> set-transition ;
