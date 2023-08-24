! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays ascii assocs combinators
combinators.short-circuit io io.encodings.binary
io.encodings.utf8 io.files io.streams.byte-array
io.streams.string kernel namespaces sequences splitting strings
xml.autoencoding xml.data xml.elements xml.errors xml.name
xml.state xml.tokenize ;
IN: xml

<PRIVATE

: add-child ( object -- )
    xml-stack get last second push ;

: push-xml ( object -- )
    V{ } clone 2array xml-stack get push ;

: pop-xml ( -- object )
    xml-stack get pop ;

GENERIC: process ( object -- )

M: object process add-child ;

M: prolog process
    xml-stack get
    { V{ { f V{ "" } } } V{ { f V{ } } } } member?
    [ bad-prolog ] unless add-child ;

: before-main? ( -- ? )
    xml-stack get {
        [ length 1 = ]
        [ first second [ tag? ] none? ]
    } 1&& ;

M: directive process
    before-main? [ misplaced-directive ] unless add-child ;

M: contained process
    [ name>> ] [ attrs>> ] bi
    <contained-tag> add-child ;

M: opener process push-xml ;

: check-closer ( name opener -- name opener )
    dup [ unopened ] unless
    2dup name>> =
    [ name>> swap mismatched ] unless ;

M: closer process
    name>> pop-xml first2
    [ check-closer attrs>> ] dip
    <tag> add-child ;

: init-xml-stack ( -- )
    V{ } clone xml-stack namespaces:set
    f push-xml ;

: default-prolog ( -- prolog )
    "1.0" "UTF-8" f <prolog> ;

: init-xml ( -- )
    init-ns-stack
    extra-entities [ H{ } assoc-like ] change ;

: assert-blanks ( seq pre? -- )
    swap [ string? ] filter
    [
        dup [ blank? ] all?
        [ drop ] [ swap pre/post-content ] if
    ] each drop ;

: no-pre/post ( pre post -- pre post/* )
    ! this does *not* affect the contents of the stack
    [ dup t assert-blanks ] [ dup f assert-blanks ] bi* ;

: no-post-tags ( post -- post/* )
    ! this does *not* affect the contents of the stack
    dup [ tag? ] any? [ multitags ] when ;

: assure-tags ( seq -- seq )
    ! this does *not* affect the contents of the stack
    [ notags ] unless* ;

: get-prolog ( seq -- prolog )
    { "" } ?head drop
    ?first dup prolog?
    [ drop default-prolog ] unless ;

: cut-prolog ( seq -- newseq )
    [ { [ prolog? not ] [ "" = not ] } 1&& ] filter ;

: make-xml-doc ( seq -- xml-doc )
    [ get-prolog ] keep
    dup [ tag? ] find [
        assure-tags cut
        [ cut-prolog ] [ rest ] bi*
        no-pre/post no-post-tags
    ] dip swap <xml> ;

! * Views of XML

SYMBOL: text-now?

: collect-variables ( -- hash )
    {
        input-stream
        extra-entities
        spot
        ns-stack
        text-now?
    } [ dup get ] H{ } map>assoc ;

PRIVATE>

TUPLE: pull-xml scope ;
: <pull-xml> ( -- pull-xml )
    [
        init-parser init-xml text-now? on collect-variables
    ] with-scope pull-xml boa ;
! pull-xml needs to call start-document somewhere

: pull-event ( pull -- xml-event/f )
    scope>> [
        text-now? get [ parse-text f ] [
            get-char [ make-tag t ] [ f f ] if
        ] if text-now? namespaces:set
    ] with-variables ;

<PRIVATE

: done? ( -- ? )
    xml-stack get length 1 = ;

: (pull-elem) ( pull -- xml-elem/f )
    dup pull-event dup closer? done? and [ nip ] [
        process done?
        [ drop xml-stack get first second ]
        [ (pull-elem) ] if
    ] if ;

PRIVATE>

: pull-elem ( pull -- xml-elem/f )
    [ init-xml-stack (pull-elem) ] with-scope ;

<PRIVATE

: call-under ( quot object -- quot )
    swap [ call ] keep ; inline

: xml-loop ( quot: ( xml-elem -- ) -- )
    parse-text call-under get-char
    [ make-tag call-under xml-loop ]
    [ drop ] if ; inline recursive

: read-seq ( stream quot n -- seq )
    rot [
        depth namespaces:set
        init-xml init-xml-stack
        call
        [ process ] xml-loop
        done? [ throw-unclosed ] unless
        xml-stack get first second
    ] with-state ; inline

: make-xml ( stream quot -- xml )
    0 read-seq make-xml-doc ; inline

PRIVATE>

: each-element ( stream quot: ( xml-elem -- ) -- )
    swap [
        init-xml
        start-document [ call-under ] when*
        xml-loop
    ] with-state ; inline

: read-xml ( stream -- xml )
    dup stream-element-type {
        { +character+ [ [ check ] make-xml ] }
        { +byte+ [ [ start-document [ process ] when* ] make-xml ] }
    } case ;

: read-xml-chunk ( stream -- seq )
    [ check ] 1 read-seq <xml-chunk> ;

: string>xml ( string -- xml )
    <string-reader> read-xml ;

: string>xml-chunk ( string -- xml )
    <string-reader> read-xml-chunk ;

: file>xml ( filename -- xml )
    binary <file-reader> read-xml ;

: bytes>xml ( byte-array -- xml )
    binary <byte-reader> read-xml ;

: read-dtd ( stream -- dtd )
    [
        H{ } clone extra-entities namespaces:set
        take-internal-subset
    ] with-state ;

: file>dtd ( filename -- dtd )
    utf8 <file-reader> read-dtd ;

: string>dtd ( string -- dtd )
    <string-reader> read-dtd ;
