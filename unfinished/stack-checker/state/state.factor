! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs namespaces sequences kernel definitions math
effects accessors words stack-checker.errors ;
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

: copy-inference ( -- )
    meta-d [ clone ] change
    meta-r [ clone ] change
    d-in [ ] change ;

: recursive-label ( word -- label/f )
    recursive-state get at ;

: local-recursive-state ( -- assoc )
    recursive-state get dup keys
    [ dup word? [ inline? ] when not ] find drop
    [ head-slice ] when* ;

: inline-recursive-label ( word -- label/f )
    local-recursive-state at ;

: recursive-quotation? ( quot -- ? )
    local-recursive-state [ first eq? ] with contains? ;

! Words that the current quotation depends on
SYMBOL: dependencies

: depends-on ( word how -- )
    swap dependencies get dup [
        2dup at +inlined+ eq? [ 3drop ] [ set-at ] if
    ] [ 3drop ] if ;

! Words we've inferred the stack effect of, for rollback
SYMBOL: recorded
