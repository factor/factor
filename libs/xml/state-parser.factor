! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
IN: state-parser
USING: errors hashtables io kernel math namespaces prettyprint
sequences tools generic strings char-classes xml-data xml-errors ;

! -- Low-level parsing
! Code stored in stdio
! Spot is composite so it won't be lost in sub-scopes
SYMBOL: spot #! { char line column line-str }
: get-char ( -- char ) spot get first ;
: set-char ( char -- ) 0 spot get set-nth ;
: get-line ( -- line ) spot get second ;
: set-line ( line -- ) 1 spot get set-nth ;
: get-column ( -- column ) spot get third ;
: set-column ( column -- ) 2 spot get set-nth ;
: get-line-str ( -- line-str ) 3 spot get nth ;
: set-line-str ( line-str -- ) 3 spot get set-nth ;

C: xml-error ( -- xml-error )
    [ get-line swap set-xml-error-line ] keep
    [ get-column swap set-xml-error-column ] keep
    [ get-line-str swap set-xml-error-line-str ] keep ;

SYMBOL: prolog-data

! Record is composite so it changes in nested scopes
SYMBOL: record ! string
SYMBOL: now-recording? ! t/f
: recording? ( -- t/f ) now-recording? get ;
: get-record ( -- sbuf ) record get ;

: push-record ( ch -- )
    get-record push ;
: new-record ( -- )
    SBUF" " clone record set
    t now-recording? set
    get-char [ push-record ] when* ;
: unrecord ( -- )
    record get pop* ;

: (end-record) ( -- sbuf )
    f now-recording? set
    get-record ;
: end-record* ( n -- string )
    (end-record) tuck length swap -
    head-slice >string ;
: end-record ( -- string )
    get-record length 0 =
    [ "" f recording? set ]
    [ 1 end-record* ] if ;

!   -- Basic utility words

: next-line ( -- string/f )
    ! this is inefficient and should be changed!
    readln [ CHAR: \n add ] [ f ] if* ;

: (next) ( -- char )
    get-column get-line-str 2dup length 1- < [
        >r 1+ dup set-column r> nth
    ] [
        2drop 0 set-column
        next-line dup set-line-str
        [ first ] [ f ] if*
        get-line 1+ set-line
    ] if ;

: next ( -- )
    #! Increment spot.
    get-char [
         "XML document unexpectedly ended"
        <xml-string-error> throw
    ] unless
    (next) dup set-char
    recording? over and [ push-record ] [ drop ] if ;

: skip-until ( quot -- )
    #! quot: ( -- ? )
    get-char [
        [ call ] keep swap [ drop ] [
            next skip-until
        ] if
    ] [ 2drop ] if ; inline

: take-until ( quot -- string | quot: -- ? )
    #! Take the substring of a string starting at spot
    #! from code until the quotation given is true and
    #! advance spot to after the substring.
    new-record skip-until end-record ; inline

: take-char ( ch -- string )
    [ dup get-char = ] take-until nip ;

: pass-blank ( -- )
    #! Advance code past any whitespace, including newlines
    [ get-char blank? not ] skip-until ;

: string-matches? ( string -- ? )
    dup length get-column tuck +
    dup get-line-str length <=
    [ get-line-str <slice> sequence= ]
    [ 3drop f ] if ;

: take-string ( match -- string )
    ! match must not contain a newline
    [ dup string-matches? ] take-until
    get-line-str
    [ "Missing closing token" <xml-string-error> throw ] unless
    swap length [ next ] times ;
