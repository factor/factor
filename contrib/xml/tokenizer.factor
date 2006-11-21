! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
IN: xml
USING: errors hashtables io kernel math namespaces prettyprint
sequences tools generic strings char-classes ;

SYMBOL: code #! Source code
SYMBOL: spot #! { index line column }
: get-index ( -- index ) spot get first ;
: set-index ( index -- ) 0 spot get set-nth ;
: get-line ( -- line ) spot get second ;
: set-line ( line -- ) 1 spot get set-nth ;
: get-column ( -- column ) spot get third ;
: set-column ( column -- ) 2 spot get set-nth ;
SYMBOL: prolog-data

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

: more? ( -- ? )
    #! Return t if spot is not at the end of code
    code get length get-index = not ;

: char ( -- char/f )
    more? [ get-index code get nth ] [ f ] if ;

: incr-spot ( -- )
    #! Increment spot.
    get-index 1+ set-index char "\n\r" member?
    [ 0 set-column get-line 1+ set-line ]
    [ get-column 1+ set-column ] if ;

: skip-until ( quot -- )
    #! quot: ( char -- ? )
    more? [
        char swap [ call ] keep swap [ drop ] [
             incr-spot skip-until
        ] if
    ] [ drop ] if ; inline

: take-until ( quot -- string | quot: char -- ? )
    #! Take the substring of a string starting at spot
    #! from code until the quotation given is true and
    #! advance spot to after the substring.
    get-index >r skip-until r>
    get-index code get subseq ; inline

: pass-blank ( -- )
    #! Advance code past any whitespace, including newlines
    [ blank? not ] skip-until ;

: string-matches? ( string -- ? )
    get-index dup pick length + code get
    2dup length > [ 3drop drop f ] [ <slice> sequence= ] if ;

: (take-until-string) ( string -- n )
    more? [
        dup string-matches? [
            drop get-index
        ] [
            incr-spot (take-until-string)
        ] if
    ] [ "Missing closing token" <xml-string-error> throw ] if ;

: take-until-string ( string -- string )
    [ >r get-index r> (take-until-string) code get subseq ] keep
    length get-index + set-index ;

!   -- Parsing strings

: expect ( ch -- )
    char 2dup = [ 2drop ] [
        >r ch>string r> ch>string <expected> throw
    ] if incr-spot ;

: expect-string* ( num -- )
    #! only skips string
    [ incr-spot ] times ;

: expect-string ( string -- )
    >r get-index r> t over [ char incr-spot = and ] each [
        2drop
    ] [
        swap get-index code get subseq <expected> throw
    ] if ;

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

: parsed-ch ( sbuf ch -- sbuf ) over push incr-spot ;

: parse-entity ( sbuf -- sbuf )
    incr-spot [ CHAR: ; = ] take-until "#" ?head [
        "x" ?head 16 10 ? base> parsed-ch
    ] [
        dup entities hash [ parsed-ch ] [ 
            prolog-data get prolog-standalone
            [ <no-entity> throw ] [
                >r >string , r> <entity> , incr-spot
                SBUF" " clone
            ] if
        ] ?if
    ] if ;

TUPLE: reference name ;

: parse-reference ( sbuf -- sbuf )
    , incr-spot [ CHAR: ; = ] take-until
    <reference> , SBUF" " clone incr-spot ;

: (parse-text) ( sbuf -- )
    char {
        { [ dup not ] [ drop >string , ] } ! should this be an error?
        { [ dup CHAR: < = ] [ drop >string , ] }
        { [ dup CHAR: & = ]
          [ drop parse-entity (parse-text) ] }
        { [ dup CHAR: % = ]
          [ drop parse-reference (parse-text) ] }
        { [ t ] [ parsed-ch (parse-text) ] }
    } cond ;

: parse-text ( -- array )
   [ SBUF" " clone (parse-text) ] { } make ;

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
    char dup name-start-char? [
        incr-spot ch>string [ name-char? not ] take-until append
    ] [
        "Malformed name" <xml-string-error> throw
    ] if ;

: parse-name ( -- str-name )
    (parse-name) char CHAR: : =
    [ incr-spot (parse-name) ] [ "" swap ] if <name> ;
