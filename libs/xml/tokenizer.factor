! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
IN: xml
USING: errors hashtables io kernel math namespaces prettyprint
sequences tools generic strings char-classes ;

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

!   -- Error reporting

TUPLE: xml-error line column ;
C: xml-error ( -- xml-error )
    [ get-line swap set-xml-error-line ] keep
    [ get-column swap set-xml-error-column ] keep ;

: xml-error. ( xml-error -- )
    "XML error" print
    "Line: " write dup xml-error-line .
    "Column: " write xml-error-column . ;

TUPLE: expected should-be was ;
C: expected ( should-be was -- error )
    [ <xml-error> swap set-delegate ] keep
    [ set-expected-was ] keep
    [ set-expected-should-be ] keep ;

M: expected error.
    dup xml-error.
    "Token expected: " write dup expected-should-be print
    "Token present: " write expected-was print ;

TUPLE: no-entity thing ;
C: no-entity ( string -- entitiy )
    [ <xml-error> swap set-delegate ] keep
    [ set-no-entity-thing ] keep ;

M: no-entity error.
    dup xml-error.
    "Entity does not exist: &" write no-entity-thing write ";" print ;

TUPLE: xml-string-error string ;
C: xml-string-error ( string -- xml-string-error )
    [ set-xml-string-error-string ] keep
    [ <xml-error> swap set-delegate ] keep ;

M: xml-string-error error.
    dup xml-error.
    xml-string-error-string print ;

!   -- Basic utility words

: next-line ( -- string )
    ! read a non-blank line
    readln dup "" = [ drop next-line ] when ;

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

!   -- Parsing strings

: expect ( ch -- )
    get-char 2dup = [ 2drop ] [
        >r ch>string r> ch>string <expected> throw
    ] if next ;

: expect-string* ( num -- )
    #! only skips string, and only for when you're sure the string is there
    [ next ] times ;

: expect-string ( string -- )
    ! TODO: add error if this isn't long enough
    new-record dup length [ next ] times
    end-record 2dup = [ 2drop ]
    [ <expected> throw ] if ;

TUPLE: prolog version encoding standalone ; ! part of xml-doc, see parser

: entities
    #! We have both directions here as a shortcut.
    H{
        { "lt"    CHAR: <  }
        { "gt"    CHAR: >  }
        { "amp"   CHAR: &  }
        { "apos"  CHAR: '  }
        { "quot"  CHAR: "  }
        { CHAR: < "&lt;"   }
        { CHAR: > "&gt;"   }
        { CHAR: & "&amp;"  }
        { CHAR: ' "&apos;" }
        { CHAR: " "&quot;" }
    } ;

TUPLE: entity name ;

: (parse-entity) ( string -- )
    dup entities hash [ push-record ] [ 
        prolog-data get prolog-standalone
        [ <no-entity> throw ] [
            end-record , <entity> , next new-record
        ] if
    ] ?if ;

: parse-entity ( -- )
    next unrecord unrecord 
    ! the following line is in a scope to shield this
    ! word from the record-altering side effects of
    ! take-until.
    [ CHAR: ; take-char ] with-scope
    "#" ?head [
        "x" ?head 16 10 ? base>
        push-record
    ] [ (parse-entity) ] if ;

TUPLE: reference name ;

: parse-reference ( -- )
    next unrecord end-record , CHAR: ; take-char
    <reference> , next new-record ;

: (parse-text) ( -- )
    get-char {
        { [ dup not ]
          [ drop 0 end-record* , ] }
        { [ dup CHAR: < = ] [ drop end-record , ] }
        { [ dup CHAR: & = ]
          [ drop parse-entity (parse-text) ] }
        { [ CHAR: % = ]
          [ parse-reference (parse-text) ] }
        { [ t ] [ next (parse-text) ] }
    } cond ;

: parse-text ( -- array )
   [ new-record (parse-text) ] { } make ;

!   -- Parsing tags

TUPLE: name space tag url ;
C: name ( space tag -- name )
    [ set-name-tag ] keep
    [ set-name-space ] keep ;

: get-version ( -- string )
    prolog-data get prolog-version ;

: name-start-char? ( char -- ? )
    get-version "1.0" =
    [ 1.0name-start-char? ] [ 1.1name-start-char? ] if ;

: name-char? ( char -- ? )
    get-version "1.0" =
    [ 1.0name-char? ] [ 1.1name-char? ] if ;

: (parse-name) ( -- str )
    new-record get-char name-start-char? [
        [ get-char name-char? not ] skip-until end-record
    ] [
        "Malformed name" <xml-string-error> throw
    ] if ;

: parse-name ( -- name )
    (parse-name) get-char CHAR: : =
    [ next (parse-name) ] [ "" swap ] if <name> ;
