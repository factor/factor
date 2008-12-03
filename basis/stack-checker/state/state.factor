! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs arrays namespaces sequences kernel definitions
math effects accessors words fry classes.algebra
compiler.units ;
IN: stack-checker.state

! Did the current control-flow path throw an error?
SYMBOL: terminated?

! Number of inputs current word expects from the stack
SYMBOL: d-in

! Compile-time data stack
SYMBOL: meta-d

! Compile-time retain stack
SYMBOL: meta-r

: current-stack-height ( -- n ) meta-d get length d-in get - ;

: current-effect ( -- effect )
    d-in get
    meta-d get length <effect>
    terminated? get >>terminated? ;

: init-inference ( -- )
    terminated? off
    V{ } clone meta-d set
    V{ } clone meta-r set
    0 d-in set ;

! Words that the current quotation depends on
SYMBOL: dependencies

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

! Words we've inferred the stack effect of, for rollback
SYMBOL: recorded
