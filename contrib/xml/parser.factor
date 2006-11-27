! --> Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
IN: xml
USING: errors hashtables io kernel math namespaces prettyprint sequences
    arrays generic strings vectors char-classes ;

TUPLE: opener name props ;
TUPLE: closer name ;
TUPLE: contained name props ;
TUPLE: comment text ;
TUPLE: directive text ;
TUPLE: instruction text ;

: start-tag ( -- name ? )
    #! Outputs the name and whether this is a closing tag
    get-char CHAR: / = dup [ incr-spot ] when
    parse-name swap ;

: (parse-quot) ( ch -- )
    ! The similarities with (parse-text) should be factored out
    get-char {
        { [ dup not ]
          [ "File ended in quote" <xml-string-error> throw ] }
        { [ 2dup = ]
          [ 2drop end-record , incr-spot ] }
        { [ dup CHAR: & = ]
          [ drop parse-entity (parse-quot) ] }
        { [ CHAR: % = ] [ parse-reference (parse-quot) ] }
        { [ t ] [ incr-spot (parse-quot) ] }
    } cond ;

: parse-quot ( ch -- array )
   [ new-record (parse-quot) ] { } make <xml-string> ;

: parse-prop-value ( -- seq )
    get-char dup "'\"" member? [
        incr-spot parse-quot
    ] [
        "Attribute lacks quote" <xml-string-error> throw
    ] if ;

: parse-prop ( -- )
    [ parse-name ] with-scope
    pass-blank CHAR: = expect pass-blank
    [ parse-prop-value ] with-scope
    swap set ;

: (middle-tag) ( -- )
    pass-blank get-char name-start-char?
    [ parse-prop (middle-tag) ] when ;

: middle-tag ( -- hash )
    [ (middle-tag) ] make-hash pass-blank ;

: end-tag ( string hash -- tag )
    pass-blank get-char CHAR: / =
    [ <contained> incr-spot ] [ <opener> ] if ;

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
    CHAR: < expect
    { { [ get-char dup CHAR: ! = ] [ drop incr-spot directive ] }
      { [ CHAR: ? = ] [ incr-spot instruction ] } 
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

TUPLE: contained-tag ;
C: contained-tag ( name props -- contained-tag )
    [ >r { } <tag> r> set-delegate ] keep ;

! A stack of { tag children } pairs
SYMBOL: xml-stack

! A stack of hashtables
SYMBOL: namespace-stack

TUPLE: mismatched open close ;
: write-name ( name -- )
    dup name-space dup "" = [ drop ] [ write ":" write ] if
    name-tag write ;
M: mismatched error.
    "Mismatched tags" print
    "Opening tag: <" write dup mismatched-open write-name ">" print
    "Closing tag: </" write mismatched-close write-name ">" print ;

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

TUPLE: bad-uri string ;
M: bad-uri error.
    "Bad URI:" print bad-uri-string . ;

: xml-string>uri ( xml-string -- string )
    xml-string-array
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

M: xml-string process 
    xml-string-array [ add-child ] each ;

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
    xml-string-array dup [ string? ] all?
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
    incr-spot
    "1.0" "iso-8859-1" f <prolog> prolog-data set
    init-xml-stack
    init-ns-stack ;

UNION: any-tag tag contained-tag ;

TUPLE: notags ;
M: notags error.
    drop "XML document lacks a main tag" print ;

TUPLE: multitags ;
M: multitags error.
    drop "XML document contains multiple main tags" print ;

: make-xml-doc ( seq -- xml-doc )
    prolog-data get swap dup [ any-tag? ] find
    >r dup -1 = [ <notags> throw ] when
    swap cut 1 tail
    dup [ any-tag? ] contains? [ <multitags> throw ] when r>
    swap <xml-doc> ;

: (string>xml) ( -- )
    parse-text process
    get-char [ make-tag process (string>xml) ] when ;

: stream>xml ( stream -- xml-doc )
    #! Produces a tree of XML nodes
    [
        init-xml
        parse-prolog (string>xml)
        xml-stack get
        dup length 1 = [ <unclosed> throw ] unless
        first second
        make-xml-doc
    ] with-scope ;

: string>xml ( string -- xml-doc )
    <string-reader> stream>xml ;

UNION: xml-parse-error multitags notags xml-error extra-attrs nonexist-ns
       not-yes/no unclosed mismatched xml-string-error expected no-entity ;
