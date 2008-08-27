! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators.lib io kernel
math math.order namespaces regexp2.backend sequences
sequences.lib unicode.categories math.ranges fry
combinators.short-circuit ;
IN: regexp2.utils

: (while-changes) ( obj quot pred pred-ret -- obj )
    ! quot: ( obj -- obj' )
    ! pred: ( obj -- <=> )
    >r >r dup slip r> pick over call r> dupd =
    [ 3drop ] [ (while-changes) ] if ; inline recursive

: while-changes ( obj quot pred -- obj' )
    pick over call (while-changes) ; inline

: last-state ( regexp -- range ) stack>> peek first2 [a,b] ;
: push1 ( obj -- ) input-stream get stream>> push ;
: peek1 ( -- obj ) input-stream get stream>> [ f ] [ peek ] if-empty ;
: pop3 ( seq -- obj1 obj2 obj3 ) [ pop ] [ pop ] [ pop ] tri spin ;
: drop1 ( -- ) read1 drop ;

: stack ( -- obj ) current-regexp get stack>> ;
: change-whole-stack ( quot -- )
    current-regexp get
    [ stack>> swap call ] keep (>>stack) ; inline
: push-stack ( obj -- ) stack push ;
: pop-stack ( -- obj ) stack pop ;
: cut-out ( vector n -- vector' vector ) cut rest ;
ERROR: cut-stack-error ;
: cut-stack ( obj vector -- vector' vector )
    tuck last-index [ cut-stack-error ] unless* cut-out swap ;

ERROR: bad-octal number ;
ERROR: bad-hex number ;
: check-octal ( octal -- octal ) dup 255 > [ bad-octal ] when ;
: check-hex ( hex -- hex ) dup number? [ bad-hex ] unless ;

: ascii? ( n -- ? ) 0 HEX: 7f between? ;
: octal-digit? ( n -- ? ) CHAR: 0 CHAR: 7 between? ;
: decimal-digit? ( n -- ? ) CHAR: 0 CHAR: 9 between? ;

: hex-digit? ( n -- ? )
    [
        [ decimal-digit? ]
        [ CHAR: a CHAR: f between? ]
        [ CHAR: A CHAR: F between? ]
    ] 1|| ;

: control-char? ( n -- ? )
    [
        [ 0 HEX: 1f between? ]
        [ HEX: 7f = ]
    ] 1|| ;

: punct? ( n -- ? )
    "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~" member? ;

: c-identifier-char? ( ch -- ? )
    [ [ alpha? ] [ CHAR: _ = ] ] 1|| ;

: java-blank? ( n -- ? )
    {
        CHAR: \s CHAR: \t CHAR: \n
        HEX: b HEX: 7 CHAR: \r
    } member? ;

: java-printable? ( n -- ? )
    [ [ alpha? ] [ punct? ] ] 1|| ;
