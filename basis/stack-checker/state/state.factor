! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs namespaces sequences kernel definitions math
effects accessors words fry classes.algebra stack-checker.errors
compiler.units ;
IN: stack-checker.state

: <value> ( -- value ) \ <value> counter ;

SYMBOL: known-values

: known ( value -- known ) known-values get at ;

: set-known ( known value -- )
    over [ known-values get set-at ] [ 2drop ] if ;

: make-known ( known -- value )
    <value> [ set-known ] keep ;

: copy-value ( value -- value' )
    known make-known ;

: copy-values ( values -- values' )
    [ copy-value ] map ;

! Literal value
TUPLE: literal < identity-tuple value recursion ;

: <literal> ( obj -- value )
    recursive-state get \ literal boa ;

: literal ( value -- literal )
    known dup literal?
    [  \ literal-expected inference-warning ] unless ;

! Result of curry
TUPLE: curried obj quot ;

C: <curried> curried

! Result of compose
TUPLE: composed quot1 quot2 ;

C: <composed> composed

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

: init-known-values ( -- )
    H{ } clone known-values set ;

: recursive-label ( word -- label/f )
    recursive-state get at ;

: local-recursive-state ( -- assoc )
    recursive-state get dup
    [ first dup word? [ inline? ] when not ] find drop
    [ head-slice ] when* ;

: inline-recursive-label ( word -- label/f )
    local-recursive-state at ;

: recursive-quotation? ( quot -- ? )
    local-recursive-state [ first eq? ] with contains? ;

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

: depends-on-generic ( generic class -- )
    generic-dependencies get dup
    [ swap '[ null or _ class-or ] change-at ] [ 3drop ] if ;

! Words we've inferred the stack effect of, for rollback
SYMBOL: recorded
