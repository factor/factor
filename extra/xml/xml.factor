! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: io io.streams.string io.files kernel math namespaces
prettyprint sequences arrays generic strings vectors
xml.char-classes xml.data xml.errors xml.tokenize xml.writer
xml.utilities state-parser assocs ;
IN: xml

!   -- Overall parser with data tree

! A stack of { tag children } pairs
SYMBOL: xml-stack

: <unclosed> ( -- unclosed )
    xml-stack get 1 tail-slice [ first opener-name ] map
    { set-unclosed-tags } unclosed construct ;

: add-child ( object -- )
    xml-stack get peek second push ;

: push-xml ( object -- )
    V{ } clone 2array xml-stack get push ;

: pop-xml ( -- object )
    xml-stack get pop ;

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
    <contained-tag> add-child ;

M: opener process push-xml ;

: check-closer ( name opener -- name opener )
    dup [ <unopened> throw ] unless
    2dup opener-name =
    [ opener-name swap <mismatched> throw ] unless ;

M: closer process
    closer-name pop-xml first2
    >r check-closer opener-attrs r>
    <tag> add-child ;

: init-xml-stack ( -- )
    V{ } clone xml-stack set f push-xml ;

: default-prolog ( -- prolog )
    "1.0" "iso-8859-1" f <prolog> ;

: reset-prolog ( -- )
    default-prolog prolog-data set ;

: init-xml ( -- )
    reset-prolog init-xml-stack init-ns-stack ;

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
    [ <notags> throw ] unless* ;

: make-xml-doc ( prolog seq -- xml-doc )
    dup [ tag? ] find
    >r assure-tags swap cut 1 tail
    no-pre/post no-post-tags
    r> swap <xml> ;

! * Views of XML

SYMBOL: text-now?

TUPLE: pull-xml scope ;
: <pull-xml> ( -- pull-xml )
    [
        stdio [ ] change ! bring stdio var in this scope
        init-parser reset-prolog init-ns-stack
        text-now? on
    ] H{ } make-assoc
    { set-pull-xml-scope } pull-xml construct ;

: pull-event ( pull -- xml-event/f )
    pull-xml-scope [
        text-now? get [ parse-text f ] [
            get-char [ make-tag t ] [ f f ] if
        ] if text-now? set
    ] bind ;

: done? ( -- ? )
    xml-stack get length 1 = ;

: (pull-elem) ( pull -- xml-elem/f )
    dup pull-event dup closer? done? and [ nip ] [
        process done?
        [ drop xml-stack get first second ]
        [ (pull-elem) ] if
    ] if ;

: pull-elem ( pull -- xml-elem/f )
    [ init-xml-stack (pull-elem) ] with-scope ;

: call-under ( quot object -- quot )
    swap dup slip ; inline

: sax-loop ( quot -- ) ! quot: xml-elem --
    parse-text call-under
    get-char [ make-tag call-under sax-loop ]
    [ drop ] if ; inline

: sax ( stream quot -- ) ! quot: xml-elem --
    swap [
        reset-prolog init-ns-stack
        prolog-data get call-under
        sax-loop
    ] state-parse ; inline

: (read-xml) ( -- )
    [ process ] sax-loop ; inline

: (xml-chunk) ( stream -- prolog seq )
    [
        init-xml (read-xml)
        done? [ <unclosed> throw ] unless
        xml-stack get first second
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

