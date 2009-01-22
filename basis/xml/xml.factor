! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays io io.encodings.binary io.files
io.streams.string kernel namespaces sequences strings io.encodings.utf8
xml.backend xml.data xml.errors xml.elements ascii xml.entities
xml.writer xml.state xml.autoencoding assocs xml.tokenize xml.name ;
IN: xml

!   -- Overall parser with data tree

: add-child ( object -- )
    xml-stack get peek second push ;

: push-xml ( object -- )
    V{ } clone 2array xml-stack get push ;

: pop-xml ( -- object )
    xml-stack get pop ;

GENERIC: process ( object -- )

M: object process add-child ;

M: prolog process
    xml-stack get V{ { f V{ } } } =
    [ bad-prolog ] unless drop ;

M: directive process
    xml-stack get dup length 1 =
    swap first second [ tag? ] contains? not and
    [ misplaced-directive ] unless
    add-child ;

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
    V{ } clone xml-stack set
    extra-entities [ H{ } assoc-like ] change
    f push-xml ;

: default-prolog ( -- prolog )
    "1.0" "UTF-8" f <prolog> ;

: reset-prolog ( -- )
    default-prolog prolog-data set ;

: init-xml ( -- )
    reset-prolog init-xml-stack init-ns-stack ;

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
    dup [ tag? ] contains? [ multitags ] when ; 

: assure-tags ( seq -- seq )
    ! this does *not* affect the contents of the stack
    [ notags ] unless* ;

: make-xml-doc ( prolog seq -- xml-doc )
    dup [ tag? ] find
    [ assure-tags cut rest no-pre/post no-post-tags ] dip
    swap <xml> ;

! * Views of XML

SYMBOL: text-now?

TUPLE: pull-xml scope ;
: <pull-xml> ( -- pull-xml )
    [
        input-stream [ ] change ! bring var in this scope
        init-parser reset-prolog init-ns-stack
        text-now? on
    ] H{ } make-assoc
    pull-xml boa ;
! pull-xml needs to call start-document somewhere

: pull-event ( pull -- xml-event/f )
    scope>> [
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

: sax-loop ( quot: ( xml-elem -- ) -- )
    parse-text call-under
    get-char [ make-tag call-under sax-loop ]
    [ drop ] if ; inline recursive

: sax ( stream quot: ( xml-elem -- ) -- )
    swap [
        reset-prolog init-ns-stack
        start-document [ call-under ] when*
        sax-loop
    ] with-state ; inline recursive

: (read-xml) ( -- )
    start-document [ process ] when*
    [ process ] sax-loop ; inline

: (read-xml-chunk) ( stream -- prolog seq )
    [
        init-xml (read-xml)
        done? [ unclosed ] unless
        xml-stack get first second
        prolog-data get swap
    ] with-state ;

: read-xml ( stream -- xml )
    0 depth
    [ (read-xml-chunk) make-xml-doc ] with-variable ;

: read-xml-chunk ( stream -- seq )
    1 depth
    [ (read-xml-chunk) nip ] with-variable ;

: string>xml ( string -- xml )
    <string-reader> read-xml ;

: string>xml-chunk ( string -- xml )
    t string-input?
    [ <string-reader> read-xml-chunk ] with-variable ;

: file>xml ( filename -- xml )
    binary <file-reader> read-xml ;

: (read-dtd) ( -- dtd )
    ! should filter out blanks, throw error on non-dtd stuff
    V{ } clone dup [ push ] curry sax-loop ;

: read-dtd ( stream -- dtd entities )
    [
        t in-dtd? set
        reset-prolog
        H{ } clone extra-entities set
        (read-dtd)
        extra-entities get
    ] with-state ;

: file>dtd ( filename -- dtd entities )
    utf8 <file-reader> read-dtd ;

: string>dtd ( string -- dtd entities )
    <string-reader> read-dtd ;
