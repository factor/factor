USING: arrays errors generic hashtables io kernel math
namespaces parser prettyprint sequences strings vectors words ;
IN: xml

SYMBOL: code #! Source code
SYMBOL: spot #! Current index of string
SYMBOL: version
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
C: xml-string-error ( -- xml-string-error )
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
    spot get dup pick length + code get subseq = ;

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

: expect-string ( string -- )
    >r spot get r> t over [ char incr-spot = and ] each [
        2drop
    ] [
        swap spot get code get subseq <expected> throw
    ] if ;

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

: parse-entity ( -- ch )
    incr-spot [ CHAR: ; = ] take-until "#" ?head [
        "x" ?head 16 10 ? base>
    ] [
        dup entities hash [ ] [ <no-entity> throw ] ?if
    ] if ;

: parsed-ch ( buf ch -- buf ) over push incr-spot ;

: (parse-text) ( buf -- buf )
    {
        { [ more? not ] [ ] }
        { [ char CHAR: < = ] [ ] }
        { [ char CHAR: & = ] [ parse-entity parsed-ch (parse-text) ] }
        { [ t ] [ char parsed-ch (parse-text) ] }
    } cond ;

: parse-text ( -- string )
    SBUF" " clone (parse-text) >string ;

!   -- Parsing tags

: in-range-seq? ( number seq -- ? )
    #! seq: { { min max } { min max }* }
    [ first2 between? ] contains-with? ;

: name-start-char? ( ch -- ? )
    {
        { CHAR: :    CHAR: :    }
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

: parse-name ( -- name )
    char dup name-start-char? [
        incr-spot ch>string [ name-char? not ] take-until append
    ] [
        "Malformed name" <xml-string-error> throw
    ] if ;

TUPLE: opener name props ;
TUPLE: closer name ;
TUPLE: contained name props ;
TUPLE: comment text ;
TUPLE: directive text ;

: start-tag ( -- string ? )
    #! Outputs the name and whether this is a closing tag
    char CHAR: / = dup [ incr-spot ] when
    parse-name swap ;

: (parse-quot) ( ch buf -- buf )
    {
        { [ more? not ] [ nip ] }
        { [ char pick = ] [ incr-spot nip ] }
        { [ char CHAR: & = ] [ parse-entity parsed-ch (parse-quot) ] }
        { [ t ] [ char parsed-ch (parse-quot) ] }
    } cond ;

: parse-quot ( ch -- str )
    SBUF" " clone (parse-quot) >string ;

: parse-prop-value ( -- str )
    char dup "'\"" member? [
        incr-spot parse-quot
    ] [
        "Attribute lacks quote" <xml-string-error> throw
    ] if ;

: parse-prop ( -- name value )
    parse-name pass-blank CHAR: = expect pass-blank
    parse-prop-value 2array ;

: (middle-tag) ( seq -- seq )
    pass-blank char name-char?
    [ parse-prop over push (middle-tag) ] when ;

: middle-tag ( -- hash )
    V{ } clone (middle-tag) alist>hash pass-blank ;

: end-tag ( string hash -- tag )
    pass-blank char CHAR: / =
    [ <contained> incr-spot ] [ <opener> ] if ;

: skip-comment ( -- comment )
    "--" expect-string
    "--" take-until-string
    <comment>
    CHAR: > expect ;

: cdata ( -- string )
    "[CDATA[" expect-string "]]>" take-until-string ;

: directive ( -- object )
    {
        { [ "--" string-matches? ] [ skip-comment ] }
        { [ "[CDATA[" string-matches? ] [ cdata ] }
        { [ t ] [ ">" take-until-string <directive> ] }
    } cond ;

: make-tag ( -- tag/f )
    CHAR: < expect
    char CHAR: ! = [
        incr-spot directive
    ] [
        start-tag [
            <closer>
        ] [
            middle-tag end-tag
        ] if pass-blank CHAR: > expect
    ] if ;

!   -- Overall

: get-version ( -- )
    "<?" string-matches? [
        "<?xml" expect-string
        pass-blank middle-tag "?>" expect-string
        "version" swap hash [ version set ] when*
    ] when ;

! * Data tree

TUPLE: tag name props children ;

! A stack of { tag children } pairs
SYMBOL: xml-stack

TUPLE: mismatched open close ;
M: mismatched error.
    "Mismatched tags" print
    "Opening tag: <" write dup mismatched-open write ">" print
    "Closing tag: </" write mismatched-close write ">" print ;

TUPLE: unclosed tags ;
C: unclosed ( -- unclosed )
    xml-stack get 1 tail-slice [ first opener-name ] map
    swap [ set-unclosed-tags  ] keep ;
M: unclosed error.
    "Unclosed tags" print
    "Tags: " print
    unclosed-tags [ "  <" write write ">" print ] each ;

: add-child ( object -- )
    xml-stack get peek second push ;

: push-xml-stack ( object -- )
    V{ } clone 2array xml-stack get push ;

GENERIC: process ( object -- )

M: f process drop ;

M: string process add-child ;
M: comment process add-child ;
M: directive process add-child ;

M: contained process
    [ contained-name ] keep contained-props
    V{ } clone <tag> add-child ;

M: opener process
    push-xml-stack ;

M: closer process
    closer-name xml-stack get pop first2 >r [ 
        opener-name [
            2dup = [ 2drop ] [ swap <mismatched> throw ] if
        ] keep
    ] keep opener-props r> <tag> add-child ;

: init-xml-stack ( -- )
    V{ } clone xml-stack set f push-xml-stack ;

: init-xml ( string -- )
    code set
    [ spot line column ] [ 0 swap set ] each
    "1.0" version set
    init-xml-stack ;

: (string>xml) ( -- )
    parse-text process
    more? [ make-tag process (string>xml) ] when ; inline

: string>xml ( string -- tag )
    #! Produces a tree of XML nodes
    [
        init-xml
        get-version (string>xml)
        xml-stack get
        dup length 1 = [ <unclosed> throw ] unless
        first second
    ] with-scope ;

! * Printer

: print-props ( hash -- )
    [
        " " % swap % "=\"" % % "\"" %
    ] hash-each ;

GENERIC: (xml>string) ( object -- )

: chars>entities ( str -- str )
    #! Convert <, >, &, ' and " to HTML entities.
    [
        [ dup entities hash [ % ] [ , ] ?if ] each
    ] "" make ;

M: string (xml>string) chars>entities % ;

: print-open/close ( tag -- )
    CHAR: > ,
    dup tag-children [ (xml>string) ] each
    "</" %
    tag-name %
    CHAR: > , ;

M: tag (xml>string)
    CHAR: < ,
    dup tag-name %
    dup tag-props print-props
    dup tag-children [ empty? not ] contains?
    [ print-open/close ] [ drop "/>" % ] if ;

M: comment (xml>string)
    "<!--" % comment-text % "-->" % ;

M: object (xml>string)
    [ (xml>string) ] each ;

: xml-preamble
    "<?xml version=\"1.0\" encoding=\"iso-8859-1\"?>" ;

: xml>string ( xml -- string )
    [ xml-preamble % (xml>string) ] "" make ;

: xml-reprint ( string -- string )
    string>xml xml>string ;

! * Easy XML generation for more literal things
! should this be rewritten?

: text ( string -- )
    chars>entities add-child ;

: tag ( string attr-quot contents-quot -- )
    >r swap >r make-hash r> swap r> 
    -rot dupd <opener> process
    slip
    <closer> process ; inline

: text-tag ( content name attr-quot -- ) [ text ] tag ; inline

: comment ( string -- )
    <comment> add-child ;

: make-xml ( quot -- vector )
    #! Produces a tree of XML from a quotation to generate it
    [
        init-xml-stack
        call
        xml-stack get
        first second first
    ] with-scope ; inline

! * System for words specialized on tag names

TUPLE: process-missing process tag ;
M: process-missing error.
    "Tag <" write
    process-missing-tag tag-name write
    "> not implemented on process " write
    dup process-missing-process word-name print ;

: run-process ( tag word -- )
    2dup "xtable" word-prop
    >r dup tag-name r> hash* [ 2nip call ] [
        drop <process-missing> throw
    ] if ;
