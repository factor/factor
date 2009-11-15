! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs classes.algebra fry kernel math namespaces
sequences words ;
IN: stack-checker.dependencies

! Words that the current quotation depends on
SYMBOL: dependencies

SYMBOLS: inlined-dependency flushed-dependency called-dependency ;

: index>= ( obj1 obj2 seq -- ? )
    [ index ] curry bi@ >= ;

: dependency>= ( how1 how2 -- ? )
    { called-dependency flushed-dependency inlined-dependency }
    index>= ;

: strongest-dependency ( how1 how2 -- how )
    [ called-dependency or ] bi@ [ dependency>= ] most ;

: depends-on ( word how -- )
    over primitive? [ 2drop ] [
        dependencies get dup [
            swap '[ _ strongest-dependency ] change-at
        ] [ 3drop ] if
    ] if ;

! Generic words that the current quotation depends on
SYMBOL: generic-dependencies

: ?class-or ( class/f class -- class' )
    swap [ class-or ] when* ;

: depends-on-generic ( generic class -- )
    generic-dependencies get dup
    [ swap '[ _ ?class-or ] change-at ] [ 3drop ] if ;
