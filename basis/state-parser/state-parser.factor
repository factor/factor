! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: io io.streams.string kernel math namespaces sequences
strings circular prettyprint debugger ascii sbufs fry summary
accessors ;
IN: state-parser

! * Basic underlying words
! Code stored in stdio
! Spot is composite so it won't be lost in sub-scopes
TUPLE: spot char line column next ;

C: <spot> spot

: get-char ( -- char ) spot get char>> ;
: set-char ( char -- ) spot get swap >>char drop ;
: get-line ( -- line ) spot get line>> ;
: set-line ( line -- ) spot get swap >>line drop ;
: get-column ( -- column ) spot get column>> ;
: set-column ( column -- ) spot get swap >>column drop ;
: get-next ( -- char ) spot get next>> ;
: set-next ( char -- ) spot get swap >>next drop ;

! * Errors
TUPLE: parsing-error line column ;

: parsing-error ( class -- obj )
    new
        get-line >>line
        get-column >>column ;
M: parsing-error summary ( obj -- str )
    [
        "Parsing error" print
        "Line: " write dup line>> .
        "Column: " write column>> .
    ] with-string-writer ;

TUPLE: expected < parsing-error should-be was ;
: expected ( should-be was -- * )
    \ expected parsing-error
        swap >>was
        swap >>should-be throw ;
M: expected summary ( obj -- str )
    [
        dup call-next-method write
        "Token expected: " write dup should-be>> print
        "Token present: " write was>> print
    ] with-string-writer ;

TUPLE: unexpected-end < parsing-error ;
: unexpected-end ( -- * ) \ unexpected-end parsing-error throw ;
M: unexpected-end summary ( obj -- str )
    [
        call-next-method write
        "File unexpectedly ended." print
    ] with-string-writer ;

TUPLE: missing-close < parsing-error ;
: missing-close ( -- * ) \ missing-close parsing-error throw ;
M: missing-close summary ( obj -- str )
    [
        call-next-method write
        "Missing closing token." print
    ] with-string-writer ;

SYMBOL: prolog-data

! * Basic utility words

: record ( char -- )
    CHAR: \n =
    [ 0 get-line 1+ set-line ] [ get-column 1+ ] if
    set-column ;

! (next) normalizes \r\n and \r
: (next) ( -- char )
    get-next read1
    2dup swap CHAR: \r = [
        CHAR: \n =
        [ nip read1 ] [ nip CHAR: \n swap ] if
    ] [ drop ] if
    set-next dup set-char ;

: next ( -- )
    #! Increment spot.
    get-char [ unexpected-end ] unless (next) record ;

: next* ( -- )
    get-char [ (next) record ] when ;

: skip-until ( quot: ( -- ? ) -- )
    get-char [
        [ call ] keep swap [ drop ] [
            next skip-until
        ] if
    ] [ drop ] if ; inline recursive

: take-until ( quot -- string )
    #! Take the substring of a string starting at spot
    #! from code until the quotation given is true and
    #! advance spot to after the substring.
    10 <sbuf> [
        '[ @ [ t ] [ get-char _ push f ] if ] skip-until
    ] keep >string ; inline

: take-rest ( -- string )
    [ f ] take-until ;

: take-char ( ch -- string )
    [ dup get-char = ] take-until nip ;

TUPLE: not-enough-characters < parsing-error ;
: not-enough-characters ( -- * )
    \ not-enough-characters parsing-error throw ;
M: not-enough-characters summary ( obj -- str )
    [
        call-next-method write
        "Not enough characters" print
    ] with-string-writer ;

: take ( n -- string )
    [ 1- ] [ <sbuf> ] bi [
        '[ drop get-char [ next _ push f ] [ t ] if* ] contains? drop
    ] keep get-char [ over push ] when* >string ;

: pass-blank ( -- )
    #! Advance code past any whitespace, including newlines
    [ get-char blank? not ] skip-until ;

: string-matches? ( string circular -- ? )
    get-char over push-circular
    sequence= ;

: take-string ( match -- string )
    dup length <circular-string>
    [ 2dup string-matches? ] take-until nip
    dup length rot length 1- - head
    get-char [ missing-close ] unless next ;

: expect ( ch -- )
    get-char 2dup = [ 2drop ] [
        [ 1string ] bi@ expected
    ] if next ;

: expect-string ( string -- )
    dup [ get-char next ] replicate 2dup =
    [ 2drop ] [ expected ] if ;

: init-parser ( -- )
    0 1 0 f <spot> spot set
    read1 set-next next ;

: state-parse ( stream quot -- )
    ! with-input-stream implicitly creates a new scope which we use
    swap [ init-parser call ] with-input-stream ; inline

: string-parse ( input quot -- )
    [ <string-reader> ] dip state-parse ; inline
