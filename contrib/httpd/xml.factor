USING: kernel math parser namespaces sequences strings
prettyprint errors lists hashtables vectors io generic
words ;
IN: xml

! * Simple SAX-ish parser

!   -- Basic utility words

SYMBOL: code #! Source code
SYMBOL: spot #! Current index of string
SYMBOL: version
SYMBOL: line
SYMBOL: column

: set-code ( string -- ) ! for debugging
    code set [ spot line column ] [ 0 swap set ] each ;

: more? ( -- ? )
    #! Return t if spot is not at the end of code
    code get length spot get = not ;

: char ( -- char/f )
    more? [ spot get code get nth ] [ f ] if ;

: incr-spot ( -- )
    #! Increment spot.
    spot [ 1 + ] change
    char "\n\r" member? [
        0 column set
        line
    ] [
        column
    ] if [ 1 + ] change ;

: skip-until ( quot -- | quot: char -- ? )
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

DEFER: <xml-string-error>
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

: in-range-seq? ( number { [[ min max ]] ... } -- ? )
    [ uncons between? not ] all-with? not ;

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

!   -- Parsing strings

: expect ( ch -- )
    char 2dup = [ 2drop ] [
        >r ch>string r> ch>string <expected> throw
    ] if incr-spot ;

: expect-string ( string -- )
    >r spot get r> t over [ char incr-spot = and ] each [ 2drop ] [
        swap spot get code get subseq <expected> throw
    ] if ;

: entities
    #! We have both directions here as a shortcut.
    H{
        { "lt" CHAR: < }
        { "gt" CHAR: > }
        { "amp" CHAR: & }
        { "apos" CHAR: ' }
        { "quot" CHAR: " }
        { CHAR: < "&lt;"   }
        { CHAR: > "&gt;"   }
        { CHAR: & "&amp;"  }
        { CHAR: ' "&apos;" }
        { CHAR: " "&quot;" }
    } ;

: parse-entity ( -- ch )
    incr-spot [ CHAR: ; = ] take-until incr-spot
    dup first CHAR: # = [
        1 swap tail "x" ?head 16 10 ? base>
    ] [
        dup entities hash [ nip ] [ <no-entity> throw ] if*
    ] if ;

: (parse-text) ( vector -- vector )
    [ CHAR: & = ] take-until over push
    char CHAR: & = [
        parse-entity ch>string over push (parse-text)
    ] when ;

: parse-text ( string -- string )
    [
        code set 0 spot set
        100 <vector> (parse-text) concat
    ] with-scope ;

: get-text ( -- string )
    [ CHAR: < = ] take-until parse-text ;

!   -- Parsing tags

: name-start-char? ( ch -- ? )
    dup ":_" member? swap {
        [[ CHAR: A CHAR: Z ]] [[ CHAR: a CHAR: z ]] [[ HEX: C0 HEX: D6 ]]
        [[ HEX: D8 HEX: F6 ]] [[ HEX: F8 HEX: 2FF ]] [[ HEX: 370 HEX: 37D ]]
        [[ HEX: 37F HEX: 1FFF ]] [[ HEX: 200C HEX: 200D ]] [[ HEX: 2070 HEX: 218F ]]
        [[ HEX: 2C00 HEX: 2FEF ]] [[ HEX: 3001 HEX: D7FF ]] [[ HEX: F900 HEX: FDCF ]]
        [[ HEX: FDF0 HEX: FFFD ]] [[ HEX: 10000 HEX: EFFFF ]]
    } in-range-seq? or ;

: name-char? ( ch -- ? )
    dup name-start-char? over "-." member? or over HEX: B7 = or swap
    { [[ CHAR: 0 CHAR: 9 ]] [[ HEX: 300 HEX: 36F ]] [[ HEX: 203F HEX: 2040 ]] }
    in-range-seq? or ;

: parse-name ( -- name )
    char dup name-start-char? [
        incr-spot ch>string [ name-char? not ] take-until append
    ] [
        "Malformed name" <xml-string-error> throw
    ] if ;

: parse-quot ( ch -- str )
    incr-spot [ dupd = ] take-until parse-text nip incr-spot ;

: parse-prop-value ( -- str )
    char dup "'\"" member? [
        parse-quot
    ] [
        "Attribute lacks quote" <xml-string-error> throw
    ] if ;

: parse-prop ( -- [[ name value ]] )
    parse-name pass-blank CHAR: = expect pass-blank
    parse-prop-value cons pass-blank ;

TUPLE: opener name props ;
TUPLE: closer name ;
TUPLE: contained name props ;
TUPLE: comment text ;

: start-tag ( -- string ? )
    #! Outputs the name and whether this is a closing tag
    char CHAR: / = dup [ incr-spot ] when
    parse-name swap ;

: (middle-tag) ( list -- list )
    pass-blank char name-char? [ parse-prop swons (middle-tag) ] when ;

: middle-tag ( -- hash )
    f (middle-tag) alist>hash ;

: end-tag ( string hash -- tag )
    pass-blank char CHAR: / = [
        <contained> incr-spot
    ] [
        <opener>
    ] if ;

: skip-comment ( -- comment )
    "--" expect-string "--" take-until-string <comment> CHAR: > expect ;

: cdata ( -- string )
    "[CDATA[" expect-string "]]>" take-until-string ;

: cdata/comment ( -- object )
    incr-spot char CHAR: - = [ skip-comment ] [ cdata ] if ;

: make-tag ( -- tag/f )
    CHAR: < expect
    char CHAR: ! = [
        cdata/comment
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

: dip-ns ( quot -- )
    n> slip >n ; inline

: (xml-each) ( quot -- )
    get-text swap [ dip-ns ] keep
    more? [
        make-tag [ swap [ dip-ns ] keep ] when* (xml-each)
    ] [ drop ] if ; inline

: xml-each ( string quot -- | quot: node -- )
    #! Quotation is called with each node: an opener, closer, contained,
    #! comment, or string
    #! Somewhat like SAX but vastly simplified.
    [
        swap code set
        [ spot line column ] [ 0 swap set ] each
        "1.0" version set
        get-version (xml-each)
    ] with-scope ; inline

! * Data tree

TUPLE: tag name props children ;

SYMBOL: xml-stack

TUPLE: mismatched open close ;
M: mismatched error.
    "Mismatched tags" print
    "Opening tag: <" write dup mismatched-open write ">" print
    "Closing tag: </" write mismatched-close write ">" print ;

TUPLE: unclosed tags ;
C: unclosed ( -- unclosed )
    1 xml-stack get tail-slice [ car opener-name ] map
    swap [ set-unclosed-tags  ] keep ;
M: unclosed error.
    "Unclosed tags" print
    "Tags: " print
    unclosed-tags [ "  <" write write ">" print ] each ;

: push-datum ( object -- )
    xml-stack get peek cdr push ;

GENERIC: process ( object -- )

M: string process push-datum ;
M: comment process push-datum ;

M: contained process
    [ contained-name ] keep contained-props 0 <vector> <tag> push-datum ;

M: opener process
    V{ } clone cons
    xml-stack get push ;

M: closer process
    closer-name xml-stack get pop uncons
    >r [ 
        opener-name [
            2dup = [ 2drop ] [ swap <mismatched> throw ] if
        ] keep
    ] keep opener-props r> <tag> push-datum ;

: initialize-xml-stack ( -- )
    f V{ } clone cons unit >vector xml-stack set ;

: xml ( string -- tag )
    #! Produces a tree of XML nodes
    [
        initialize-xml-stack
        [ process ] xml-each
        xml-stack get
        dup length 1 = [ <unclosed> throw ] unless
        first cdr second
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
    dup tag-children [ "" = not ] subset empty? [
        drop "/>" %
    ] [
        print-open/close
    ] if ;

M: comment (xml>string)
    "<!--" %
    comment-text %
    "-->" % ;

: xml>string ( xml -- string )
    [ (xml>string) ] "" make ;

: xml-reprint ( string -- string )
    xml xml>string ;

! * Easy XML generation for more literal things
! should this be rewritten?

: text ( string -- )
    chars>entities push-datum ;

: tag ( string attr-quot contents-quot -- )
    >r swap >r make-hash r> swap r> 
    -rot dupd <opener> process
    slip
    <closer> process ; inline

: comment ( string -- )
    <comment> push-datum ;

: make-xml ( quot -- vector )
    #! Produces a tree of XML from a quotation to generate it
    [
        initialize-xml-stack
        call
        xml-stack get
        first cdr second
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

: PROCESS:
    CREATE
    dup H{ } clone "xtable" set-word-prop
    dup literalize [ run-process ] cons define-compound ; parsing

: TAG:
    scan scan-word [
        swap "xtable" word-prop
        rot "/" split [ >r 2dup r> swap set-hash ] each 2drop
    ] f ; parsing
