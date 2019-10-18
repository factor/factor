! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: errors hashtables io kernel math namespaces prettyprint sequences
    arrays generic strings vectors char-classes xml-data xml-errors
    state-parser xml-tokenize xml-writer xml-utils ;
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

: process-ns ( hash -- hash )
    ! this should check to make sure URIs are valid
    [
        [
            first2 swap dup name-space "xmlns" =
            [ name-tag set ]
            [
                T{ name f "" "xmlns" f } names-match?
                [ "" set ] [ drop ] if
            ] if
        ] each
    ] make-hash ;

: add-ns2name ( name -- )
    dup name-space dup namespace-stack get hash-stack
    [ nip ] [ <nonexist-ns> throw ] if* swap set-name-url ;

: push-ns-stack ( hash -- )
    dup process-ns namespace-stack get push
    [ first add-ns2name ] each ;

: pop-ns-stack ( -- )
    namespace-stack get pop drop ;

GENERIC: process ( object -- )

M: object process add-child ;

M: prolog process
    xml-stack get V{ { f V{ "" } } } =
    [ <bad-prolog> throw ] unless drop ;

M: instruction process
    xml-stack get length 1 =
    [ <bad-instruction> throw ] unless
    add-child ;

M: directive process
    xml-stack get dup length 1 =
    swap first second [ tag? ] contains? not and
    [ <bad-directive> throw ] unless
    add-child ;

M: contained process
    [ contained-name ] keep contained-attrs
    dup push-ns-stack >r dup add-ns2name r>
    pop-ns-stack <contained-tag> add-child ;

M: opener process ! move add-ns2name on name to closer and fix mismatched
    dup opener-attrs push-ns-stack push-xml-stack ;

M: closer process
    closer-name xml-stack get pop first2 >r [ 
        dup [ <unopened> throw ] unless
        opener-name [
            2dup = [ nip add-ns2name ]
            [ swap <mismatched> throw ] if
        ] keep
    ] keep opener-attrs r> <tag> add-child pop-ns-stack ;

: init-ns-stack ( -- )
    V{ H{
        { "xml" "http://www.w3.org/XML/1998/namespace" }
        { "xmlns" "http://www.w3.org/2000/xmlns" }
        { "" "" }
    } } clone
    namespace-stack set ;

: init-xml-stack ( -- )
    V{ } clone xml-stack set f push-xml-stack ;

: basic-init ( -- )
    "1.0" "iso-8859-1" f <prolog> prolog-data set ;

: init-xml ( -- )
    basic-init init-xml-stack init-ns-stack ;

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

: make-xml-doc ( prolog seq -- xml-doc )
    dup [ tag? ] find
    >r assure-tags swap cut 1 tail
    no-pre/post no-post-tags
    r> swap <xml> ;

! * Views of XML

SYMBOL: text-now?

TUPLE: pull-xml scope ;
C: pull-xml ( stream -- pull-xml )
    [
        swap basic-init
        t text-now? set
        [ namestack pop swap set-pull-xml-scope ] keep
    ] state-parse ;

: pull-next ( pull -- xml-elem/f )
    pull-xml-scope [
        text-now? get [ parse-text f ] [
            get-char [ make-tag t ] [ f f ] if
        ] if text-now? set    
    ] bind ;

: call-under ( quot object -- quot )
    swap dup slip ; inline

: sax-loop ( quot -- ) ! quot: xml-elem --
    parse-text call-under
    get-char [ make-tag call-under sax-loop ]
    [ drop ] if ; inline

: sax ( stream quot -- ) ! quot: xml-elem --
    swap [
        basic-init
        prolog-data get call-under
        sax-loop
    ] state-parse ; inline

: (read-xml) ( -- )
    [ process ] sax-loop ; inline

: (xml-chunk) ( stream -- prolog seq )
    [
        init-xml (read-xml)
        xml-stack get
        dup length 1 = [ <unclosed> throw ] unless
        first second
        prolog-data get swap
    ] state-parse ;

: read-xml ( stream -- xml )
    #! Produces a tree of XML nodes
    (xml-chunk) make-xml-doc ;

: xml-chunk ( stream -- seq )
    (xml-chunk) nip ;

: string>xml ( string -- xml )
    <string-reader> read-xml ;

: file>xml ( filename -- xml )
    <file-reader> read-xml ;

: xml-reprint ( string -- )
    string>xml print-xml ;

