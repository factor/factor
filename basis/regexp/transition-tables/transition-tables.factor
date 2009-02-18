! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs fry hashtables kernel sequences
vectors ;
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

: maybe-initialize-key ( key hashtable -- )
    2dup key? [ 2drop ] [ [ H{ } clone ] 2dip set-at ] if ;

: set-transition ( transition hash -- )
    #! set the state as a key
    2dup [ to>> ] dip maybe-initialize-key
    [ [ to>> ] [ obj>> ] [ from>> ] tri ] dip
    2dup at* [ 2nip push-at ]
    [ drop [ H{ } clone [ push-at ] keep ] 2dip set-at ] if ;

: add-transition ( transition transition-table -- )
    transitions>> set-transition ;
