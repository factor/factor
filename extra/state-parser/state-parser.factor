! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: io io.streams.string kernel math namespaces sequences
strings circular prettyprint debugger ;
IN: state-parser

! * Basic underlying words
! Code stored in stdio
! Spot is composite so it won't be lost in sub-scopes
TUPLE: spot char line column next ;

C: <spot> spot

: get-char ( -- char ) spot get spot-char ;
: set-char ( char -- ) spot get set-spot-char ;
: get-line ( -- line ) spot get spot-line ;
: set-line ( line -- ) spot get set-spot-line ;
: get-column ( -- column ) spot get spot-column ;
: set-column ( column -- ) spot get set-spot-column ;
: get-next ( -- char ) spot get spot-next ;
: set-next ( char -- ) spot get set-spot-next ;

! * Errors
TUPLE: parsing-error line column ;
: <parsing-error> ( -- parsing-error )
    get-line get-column parsing-error construct-boa ;

: construct-parsing-error ( ... slots class -- error )
    construct <parsing-error> over set-delegate ; inline

: parsing-error. ( parsing-error -- )
    "Parsing error" print
    "Line: " write dup parsing-error-line .
    "Column: " write parsing-error-column . ;

TUPLE: expected should-be was ;
: <expected> ( should-be was -- error )
    { set-expected-should-be set-expected-was }
    expected construct-parsing-error ;
M: expected error.
    dup parsing-error.
    "Token expected: " write dup expected-should-be print
    "Token present: " write expected-was print ;

TUPLE: unexpected-end ;
: <unexpected-end> ( -- unexpected-end )
    { } unexpected-end construct-parsing-error ;
M: unexpected-end error.
    parsing-error.
    "File unexpectedly ended." print ;

TUPLE: missing-close ;
: <missing-close> ( -- missing-close )
    { } missing-close construct-parsing-error ;
M: missing-close error.
    parsing-error.
    "Missing closing token." print ;

SYMBOL: prolog-data

! * Basic utility words

: record ( char -- )
    CHAR: \n =
    [ 0 get-line 1+ set-line ] [ get-column 1+ ] if
    set-column ;

: (next) ( -- char ) ! this normalizes \r\n and \r
    get-next read1
    2dup swap CHAR: \r = [
        CHAR: \n =
        [ nip read1 ] [ nip CHAR: \n swap ] if
    ] [ drop ] if
    set-next dup set-char ;

: next ( -- )
    #! Increment spot.
    get-char [
        <unexpected-end> throw
    ] unless
    (next) record ;

: next* ( -- )
    get-char [ (next) record ] when ;

: skip-until ( quot -- )
    #! quot: ( -- ? )
    get-char [
        [ call ] keep swap [ drop ] [
            next skip-until
        ] if
    ] [ drop ] if ; inline

: take-until ( quot -- string )
    #! Take the substring of a string starting at spot
    #! from code until the quotation given is true and
    #! advance spot to after the substring.
    [ [
        dup slip swap dup [ get-char , ] unless
    ] skip-until ] "" make nip ;

: rest ( -- string )
    [ f ] take-until ;

: take-char ( ch -- string )
    [ dup get-char = ] take-until nip ;

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
    get-char [ <missing-close> throw ] unless next ;

: expect ( ch -- )
    get-char 2dup = [ 2drop ] [
        >r 1string r> 1string <expected> throw
    ] if next ;

: expect-string ( string -- )
    dup [ drop get-char next ] map 2dup =
    [ 2drop ] [ <expected> throw ] if ;

: init-parser ( -- )
    0 1 0 f <spot> spot set
    read1 set-next next ;

: state-parse ( stream quot -- )
    ! with-stream implicitly creates a new scope which we use
    swap [ init-parser call ] with-stream ; inline

: string-parse ( input quot -- )
    >r <string-reader> r> state-parse ; inline
