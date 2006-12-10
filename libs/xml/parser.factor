! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
IN: xml
USING: errors hashtables io kernel math namespaces prettyprint sequences
    arrays generic strings vectors char-classes ;

! * Parsing tags

TUPLE: opener name props ;
TUPLE: closer name ;
TUPLE: contained name props ;
TUPLE: comment text ;
TUPLE: directive text ;
TUPLE: instruction text ;

: start-tag ( -- name ? )
    #! Outputs the name and whether this is a closing tag
    get-char CHAR: / = dup [ next ] when
    parse-name swap ;

: parse-prop-value ( -- seq )
    get-char dup "'\"" member? [
        next parse-quot
    ] [
        "Attribute lacks quote" <xml-string-error> throw
    ] if ;

: parse-prop ( -- )
    [ parse-name ] with-scope
    pass-blank CHAR: = expect pass-blank
    [ parse-prop-value ] with-scope
    swap set ;

: (middle-tag) ( -- )
    pass-blank version=1.0? get-char name-start-char?
    [ parse-prop (middle-tag) ] when ;

: middle-tag ( -- hash )
    [ (middle-tag) ] make-hash pass-blank ;

: end-tag ( string hash -- tag )
    pass-blank get-char CHAR: / =
    [ <contained> next ] [ <opener> ] if ;

: skip-comment ( -- comment )
    "--" expect-string
    "--" take-string
    <comment>
    CHAR: > expect ;

: cdata ( -- string )
    "[CDATA[" expect-string "]]>" take-string ;

: directive ( -- object )
    {
        { [ "--" string-matches? ] [ skip-comment ] }
        { [ "[CDATA[" string-matches? ] [ cdata ] }
        { [ t ] [ CHAR: > take-char <directive> ] }
    } cond ;

: instruction ( -- instruction )
    ! this should make sure the name doesn't include 'xml'
    "?>" take-string <instruction> ;

: make-tag ( -- tag/f )
    { { [ get-char dup CHAR: ! = ] [ drop next directive ] }
      { [ CHAR: ? = ] [ next instruction ] } 
      { [ t ] [
            start-tag [ <closer> ] [
                middle-tag end-tag
            ] if pass-blank CHAR: > expect
        ] }
    } cond ;

!   -- Overall parser with data tree

TUPLE: tag props children ;
C: tag ( name props children -- tag )
    [ set-tag-children ] keep
    [ set-tag-props ] keep
    [ set-delegate ] keep ;

! tag with children=f is contained
: <contained-tag> ( name props -- tag )
    f <tag> ;

PREDICATE: tag contained-tag tag-children not ;
PREDICATE: tag open-tag tag-children ;

! A stack of { tag children } pairs
SYMBOL: xml-stack

! A stack of hashtables
SYMBOL: namespace-stack

DEFER: print-name

TUPLE: mismatched open close ;
M: mismatched error.
    "Mismatched tags" print
    "Opening tag: <" write dup mismatched-open print-name ">" print
    "Closing tag: </" write mismatched-close print-name ">" print ;

TUPLE: unclosed tags ;
C: unclosed ( -- unclosed )
    xml-stack get 1 tail-slice [ first opener-name ] map
    swap [ set-unclosed-tags  ] keep ;
M: unclosed error.
    "Unclosed tags" print
    "Tags: " print
    unclosed-tags [ "  <" write print-name ">" print ] each ;

: add-child ( object -- )
    xml-stack get peek second push ;

: push-xml-stack ( object -- )
    V{ } clone 2array xml-stack get push ;

TUPLE: bad-uri string ;
M: bad-uri error.
    "Bad URI:" print bad-uri-string . ;

: xml-string>uri ( seq -- string )
    dup length 1 = [ <bad-uri> throw ] unless
    first ;

: process-ns ( hash -- hash )
    ! This should assure all namespaces are URIs by replacing first
    [
        dup [
            swap dup name-space "xmlns" =
            [ >r xml-string>uri r> name-tag set ]
            [ 2drop ] if
        ] hash-each
        T{ name f "" "xmlns" } swap hash
        [ xml-string>uri "" set ] when*
    ] make-hash ;

TUPLE: nonexist-ns name ;
M: nonexist-ns error.
    "Namespace " write nonexist-ns-name write " has not been declared" print ;

: add-ns2name ( name -- )
    dup name-space dup namespace-stack get hash-stack
    [ nip ] [ <nonexist-ns> throw ] if* swap set-name-url ;

: push-ns-stack ( hash -- )
    dup process-ns namespace-stack get push
    [ drop add-ns2name ] hash-each ;

: pop-ns-stack ( -- )
    namespace-stack get pop drop ;

GENERIC: process ( object -- )

M: object process add-child ;

M: contained process
    [ contained-name ] keep contained-props
    dup push-ns-stack >r dup add-ns2name r>
    pop-ns-stack <contained-tag> add-child ;

M: opener process ! move add-ns2name on name to closer and fix mismatched
    dup opener-props push-ns-stack push-xml-stack ;

TUPLE: unopened ;
M: unopened error.
    drop "Closed an unopened tag" print ;

M: closer process
    closer-name xml-stack get pop first2 >r [ 
        dup [ <unopened> throw ] unless
        opener-name [
            2dup = [ nip add-ns2name ]
            [ swap <mismatched> throw ] if
        ] keep
    ] keep opener-props r> <tag> add-child pop-ns-stack ;

: init-ns-stack ( -- )
    V{ H{
        { "xml" "http://www.w3.org/XML/1998/namespace" }
        { "xmlns" "http://www.w3.org/2000/xmlns" }
        { "" "" }
    } } clone
    namespace-stack set ;

: init-xml-stack ( -- )
    V{ } clone xml-stack set f push-xml-stack ;

TUPLE: xml-doc prolog before after ;
C: xml-doc ( prolog before main after -- xml-doc )
    [ set-xml-doc-after ] keep
    [ set-delegate ] keep
    [ set-xml-doc-before ] keep
    [ set-xml-doc-prolog ] keep ;

TUPLE: not-yes/no text ;
M: not-yes/no error.
    "Standalone must be either yes or no, not \"" write
    not-yes/no-text write "\"." print ;

: yes/no>bool ( string -- t/f )
    dup "yes" = [ drop t ] [
        dup "no" = [ drop f ] [
            <not-yes/no> throw
        ] if
    ] if ;

TUPLE: extra-attrs attrs ;
M: extra-attrs error.
    "Extra attributes included in xml version declaration:" print
    extra-attrs-attrs . ;

: assure-no-extra ( hash -- )
    hash-keys {
        T{ name f "" "version" f }
        T{ name f "" "encoding" f }
        T{ name f "" "standalone" f }
    } swap diff dup empty? [ drop ] [ <extra-attrs> throw ] if ; 

: concat-strings ( xml-string -- string )
    dup [ string? ] all?
    [ "XML prolog attributes contain undefined entities"
      <xml-string-error> throw ] unless
    concat ;

TUPLE: bad-version num ;
M: bad-version error.
    "XML version must be \"1.0\" or \"1.1\". Version here was " write
    bad-version-num . ;

: good-version ( version -- version )
    dup { "1.0" "1.1" } member? [ <bad-version> throw ] unless ;

: prolog-attrs ( hash -- )
    T{ name f "" "version" f } over hash [
        concat-strings good-version
        prolog-data get set-prolog-version
    ] when*
    T{ name f "" "encoding" f } over hash [
        concat-strings prolog-data get set-prolog-encoding
    ] when*
    T{ name f "" "standalone" f } swap hash [
        concat-strings yes/no>bool
        prolog-data get set-prolog-standalone
    ] when* ;

: parse-prolog ( -- )
    "<?xml" string-matches? [
        5 expect-string*
        pass-blank middle-tag "?>" expect-string
         dup assure-no-extra prolog-attrs
    ] when ;

: init-xml ( stream -- )
    stdio set
    { 0 0 0 "" } clone spot set
    f record set f now-recording? set
    next
    "1.0" "iso-8859-1" f <prolog> prolog-data set
    init-xml-stack
    init-ns-stack ;

: init-xml-string ( string -- ) ! for debugging
    <string-reader> init-xml ;

TUPLE: notags ;
M: notags error.
    drop "XML document lacks a main tag" print ;

TUPLE: multitags ;
M: multitags error.
    drop "XML document contains multiple main tags" print ;

: make-xml-doc ( seq -- xml-doc )
    prolog-data get swap dup [ tag? ] find
    >r dup -1 = [ <notags> throw ] when
    swap cut 1 tail
    dup [ tag? ] contains? [ <multitags> throw ] when r>
    swap <xml-doc> ;

: sax-loop ( quot -- ) ! quot: xml-elem --
    parse-text [ swap dup slip ] each
    get-char [ make-tag swap dup slip sax-loop ]
    [ drop ] if ; inline

: sax ( stream quot -- ) ! quot: xml-elem --
    swap [
        init-xml parse-prolog
        prolog-data get swap dup slip
        sax-loop
    ] with-scope ; inline

: (read-xml) ( -- )
    [ process ] sax-loop ; inline

: (xml-chunk) ( stream -- seq )
    init-xml parse-prolog (read-xml)
    xml-stack get
    dup length 1 = [ <unclosed> throw ] unless
    first second ;

: read-xml ( stream -- xml-doc )
    #! Produces a tree of XML nodes
    [ (xml-chunk) make-xml-doc ] with-scope ;

: xml-chunk ( stream -- seq )
    [ (xml-chunk) ] with-scope ;

: string>xml ( string -- xml-doc )
    <string-reader> read-xml ;

UNION: xml-parse-error multitags notags xml-error extra-attrs nonexist-ns
       not-yes/no unclosed mismatched xml-string-error expected no-entity ;
