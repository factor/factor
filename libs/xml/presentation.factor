! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: errors hashtables io kernel math namespaces prettyprint sequences
    arrays generic strings vectors char-classes xml-data xml-errors
    state-parser xml-tokenize xml-writer ;
IN: xml

!   -- Overall parser with data tree

! A stack of { tag children } pairs
SYMBOL: xml-stack

C: unclosed ( -- unclosed )
    xml-stack get 1 tail-slice [ first opener-name ] map
    swap [ set-unclosed-tags  ] keep ;

! A stack of hashtables
SYMBOL: namespace-stack

: add-child ( object -- )
    xml-stack get peek second push ;

: push-xml-stack ( object -- )
    V{ } clone 2array xml-stack get push ;

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

: yes/no>bool ( string -- t/f )
    dup "yes" = [ drop t ] [
        dup "no" = [ drop f ] [
            <not-yes/no> throw
        ] if
    ] if ;

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

: basic-init ( stream -- )
    stdio set
    { 0 0 0 "" } clone spot set
    f record set f now-recording? set
    next
    "1.0" "iso-8859-1" f <prolog> prolog-data set ;

: init-xml ( stream -- )
    basic-init init-xml-stack init-ns-stack ;

: init-xml-string ( string -- ) ! for debugging
    <string-reader> init-xml ;

: assert-blanks ( seq pre? -- )
    swap [ string? ] subset
    [
        dup [ blank? ] all?
        [ drop ] [ swap <pre/post-content> throw ] if
    ] each drop ;

: no-pre/post ( pre post -- pre post/* )
    ! this does *not* affect the contents of the stack
    >r dup t assert-blanks r>
    dup f assert-blanks ;

: no-post-tags ( post -- post/* )
    ! this does *not* affect the contents of the stack
    dup [ tag? ] contains? [ <multitags> throw ] when ; 

: assure-tags ( seq -- seq )
    ! this does *not* affect the contents of the stack
    dup -1 = [ <notags> throw ] when ;

: make-xml-doc ( seq -- xml-doc )
    prolog-data get swap dup [ tag? ] find
    >r assure-tags swap cut 1 tail
    no-pre/post no-post-tags
    r> swap <xml-doc> ;

! * Views of XML

SYMBOL: text-now?

TUPLE: pull-xml scope ;
C: pull-xml ( stream -- pull-xml )
    [
        swap basic-init parse-prolog
        t text-now? set
        [ namestack pop swap set-pull-xml-scope ] keep
    ] with-scope ;

: pull-next ( pull -- xml-elem/f )
    pull-xml-scope [
        text-now? get [ parse-text f ] [
            get-char [ make-tag t ] [ f f ] if
        ] if text-now? set    
    ] bind ;

: call-under ( quot object -- quot )
    swap dup slip ; inline

: sax-loop ( quot -- ) ! quot: xml-elem --
    parse-text [ call-under ] each
    get-char [ make-tag call-under sax-loop ]
    [ drop ] if ; inline

: sax ( stream quot -- ) ! quot: xml-elem --
    swap [
        basic-init parse-prolog
        prolog-data get call-under
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

: xml-reprint ( string -- )
    string>xml print-xml ;

