! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
IN: xml
USING: errors hashtables io kernel math namespaces prettyprint sequences tools
    generic strings ;

SYMBOL: code #! Source code
SYMBOL: spot #! Current index of string
SYMBOL: prolog-data
SYMBOL: line
SYMBOL: column

!   -- Error reporting

TUPLE: xml-error line column ;
C: xml-error ( -- xml-error )
    [ line get swap set-xml-error-line ] keep
    [ column get swap set-xml-error-column ] keep ;

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

: set-code ( string -- ) ! for debugging
    code set [ spot line column ] [ 0 swap set ] each ;

: more? ( -- ? )
    #! Return t if spot is not at the end of code
    code get length spot get = not ;

: char ( -- char/f )
    more? [ spot get code get nth ] [ f ] if ;

: incr-spot ( -- )
    #! Increment spot.
    spot inc
    char "\n\r" member? [ 0 column set line ] [ column ] if
    inc ;

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
    spot get >r skip-until r>
    spot get code get subseq ; inline

: pass-blank ( -- )
    #! Advance code past any whitespace, including newlines
    [ blank? not ] skip-until ;

: string-matches? ( string -- ? )
    spot get dup pick length + code get
    2dup length > [ 3drop drop f ] [ <slice> sequence= ] if ;

: (take-until-string) ( string -- n )
    more? [
        dup string-matches? [
            drop spot get
        ] [
            incr-spot (take-until-string)
        ] if
    ] [ "Missing closing token" <xml-string-error> throw ] if ;

: take-until-string ( string -- string )
    [ >r spot get r> (take-until-string) code get subseq ] keep
    length spot [ + ] change ;

!   -- Parsing strings

: expect ( ch -- )
    char 2dup = [ 2drop ] [
        >r ch>string r> ch>string <expected> throw
    ] if incr-spot ;

: expect-string* ( num -- )
    #! only skips string
    [ incr-spot ] times ;

: expect-string ( string -- )
    >r spot get r> t over [ char incr-spot = and ] each [
        2drop
    ] [
        swap spot get code get subseq <expected> throw
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

: parse-entity ( vector sbuf -- vector sbuf )
    incr-spot [ CHAR: ; = ] take-until "#" ?head [
        "x" ?head 16 10 ? base> parsed-ch
    ] [
        dup entities hash [ parsed-ch ] [ 
            prolog-data get prolog-standalone
            [ <no-entity> throw ] [
                >r >string over push r> <entity> over push incr-spot SBUF" " 
            ] if
        ] ?if
    ] if ;

: (parse-text) ( vector sbuf -- vector )
    {
        { [ more? not ] [ >string over push ] }
        { [ char CHAR: < = ] [ >string over push ] }
        { [ char CHAR: & = ] [ parse-entity (parse-text) ] }
        { [ t ] [ char parsed-ch (parse-text) ] }
    } cond ;

: parse-text ( -- array )
   V{ } clone SBUF" " clone (parse-text) ;

!   -- Parsing tags

: in-range-seq? ( number seq -- ? )
    #! seq: { { min max } { min max }* }
    [ first2 between? ] contains-with? ;

: name-start-char? ( ch -- ? )
    {
        { CHAR: _    CHAR: _    }
        { CHAR: A    CHAR: Z    }
        { CHAR: a    CHAR: z    }
        { HEX: C0    HEX: D6    }
        { HEX: D8    HEX: F6    }
        { HEX: F8    HEX: 2FF   }
        { HEX: 370   HEX: 37D   }
        { HEX: 37F   HEX: 1FFF  }
        { HEX: 200C  HEX: 200D  }
        { HEX: 2070  HEX: 218F  }
        { HEX: 2C00  HEX: 2FEF  }
        { HEX: 3001  HEX: D7FF  }
        { HEX: F900  HEX: FDCF  }
        { HEX: FDF0  HEX: FFFD  }
        { HEX: 10000 HEX: EFFFF }
    } in-range-seq? ;

: name-char? ( ch -- ? )
    dup name-start-char? swap {
        { CHAR: -   CHAR: -   }
        { CHAR: .   CHAR: .   }
        { CHAR: 0   CHAR: 9   }
        { HEX: b7   HEX: b7   }
        { HEX: 300  HEX: 36F  }
        { HEX: 203F HEX: 2040 }
    } in-range-seq? or ;

TUPLE: name space tag url ;
C: name ( space tag -- name )
    [ set-name-tag ] keep
    [ set-name-space ] keep ;

: (parse-name) ( -- str )
    char dup name-start-char? [
        incr-spot ch>string [ name-char? not ] take-until append
    ] [
        "Malformed name" <xml-string-error> throw
    ] if ;

: parse-name ( -- str-name )
    (parse-name) char CHAR: : =
    [ incr-spot (parse-name) ] [ "" swap ] if <name> ;
