! Copyright (C) 2005, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes combinators
compiler.units continuations definitions effects io
io.encodings.utf8 io.files kernel lexer math.parser namespaces
parser.notes quotations sequences sets slots source-files
vectors vocabs vocabs.parser words words.symbol ;
FROM: sets => members ;
IN: parser

: location ( -- loc )
    file get lexer get line>> 2dup and
    [ [ path>> ] dip 2array ] [ 2drop f ] if ;

: save-location ( definition -- )
    location remember-definition ;

M: parsing-word stack-effect drop ( parsed -- parsed ) ;

: create-in ( str -- word )
    current-vocab create dup set-last-word dup save-location ;

SYMBOL: auto-use?

: auto-use ( -- ) auto-use? on ;

: no-word-restarted ( restart-value -- word )
    dup word? [
        dup vocabulary>>
        [ auto-use-vocab ]
        [ "Added \"" "\" vocabulary to search path" surround note. ] bi
    ] [ create-in ] if ;

: ignore-forwards ( seq -- seq' )
    [ forward-reference? not ] filter ;

: private? ( word -- ? ) vocabulary>> ".private" tail? ;

: ignore-privates ( seq -- seq' )
    dup [ private? ] all? [ [ private? not ] filter ] unless ;

: no-word ( name -- newword )
    dup words-named ignore-forwards
    dup ignore-privates dup length 1 = auto-use? get and
    [ 2nip first no-word-restarted ]
    [ drop <no-word-error> throw-restarts no-word-restarted ]
    if ;

: parse-word ( string -- word )
    dup search [ ] [ no-word ] ?if ;

ERROR: number-expected ;

: parse-number ( string -- number )
    string>number [ number-expected ] unless* ;

: parse-datum ( string -- word/number )
    dup search [ ] [
        dup string>number [ ] [ no-word ] ?if
    ] ?if ;

: (scan-datum) ( -- word/number/f )
    (scan-token) dup [ parse-datum ] when ;

: scan-datum ( -- word/number )
    (scan-datum) [ \ word throw-unexpected-eof ] unless* ;

: scan-word ( -- word )
    (scan-token) parse-word ;

: scan-number ( -- number )
    (scan-token) parse-number ;

: scan-word-name ( -- string )
    scan-token
    dup string>number [
        "Word names cannot be numbers" throw
    ] when ;

: scan-new ( -- word )
    scan-word-name create-in ;

: scan-new-word ( -- word )
    scan-new dup reset-generic ;

ERROR: staging-violation word ;

: (execute-parsing) ( accum word -- accum )
    dup push-parsing-word
    execute( accum -- accum )
    pop-parsing-word ; inline

: execute-parsing ( accum word -- accum )
    dup changed-definitions get in? [ staging-violation ] when
    (execute-parsing) ;

: scan-object ( -- object )
    scan-datum
    dup parsing-word? [
        V{ } clone swap execute-parsing first
    ] when ;

: scan-class ( -- class )
    scan-object \ f or ;

: parse-until-step ( accum end -- accum ? )
    (scan-datum) {
        { [ 2dup eq? ] [ 2drop f ] }
        { [ dup not ] [ drop throw-unexpected-eof t ] }
        { [ dup delimiter? ] [ unexpected t ] }
        { [ dup parsing-word? ] [ nip execute-parsing t ] }
        [ pick push drop t ]
    } cond ;

: (parse-until) ( accum end -- accum )
    [ parse-until-step ] keep swap [ (parse-until) ] [ drop ] if ;

: parse-until ( end -- vec )
    100 <vector> swap (parse-until) ;

SYMBOL: quotation-parser

HOOK: parse-quotation quotation-parser ( -- quot )

M: f parse-quotation \ ] parse-until >quotation ;

: (parse-lines) ( lexer -- quot )
    [ f parse-until >quotation ] with-lexer ;

: parse-lines ( lines -- quot )
    >array <lexer> (parse-lines) ;

: parse-literal ( accum end quot -- accum )
    [ parse-until ] dip call suffix! ; inline

: parse-definition ( -- quot )
    \ ; parse-until >quotation ;

ERROR: bad-number ;

: scan-base ( base -- n )
    scan-token swap base> [ bad-number ] unless* ;

SYMBOL: bootstrap-syntax

: with-file-vocabs ( quot -- )
    [
        "syntax" use-vocab
        bootstrap-syntax get [ use-words ] when*
        call
    ] with-manifest ; inline

SYMBOL: print-use-hook

print-use-hook [ [ ] ] initialize

: parse-fresh ( lines -- quot )
    [
        parse-lines
        auto-used? [ print-use-hook get call( -- ) ] when
    ] with-file-vocabs ;

: parsing-file ( file -- )
    parser-quiet? get [ drop ] [ "Loading " write print flush ] if ;

: filter-moved ( set1 set2 -- seq )
    swap diff members [
        {
            { [ dup where dup [ first ] when file get path>> = not ] [ f ] }
            { [ dup reader-method? ] [ f ] }
            { [ dup writer-method? ] [ f ] }
            [ t ]
        } cond nip
    ] filter ;

: removed-definitions ( -- set1 set2 )
    new-definitions old-definitions
    [ get first2 union ] bi@ ;

: removed-classes ( -- set1 set2 )
    new-definitions old-definitions
    [ get second ] bi@ ;

: forget-removed-definitions ( -- )
    removed-definitions filter-moved forget-all ;

: reset-removed-classes ( -- )
    removed-classes
    filter-moved [ class? ] filter [ forget-class ] each ;

: fix-class-words ( -- )
    #! If a class word had a compound definition which was
    #! removed, it must go back to being a symbol.
    new-definitions get first2
    filter-moved [ [ reset-generic ] [ define-symbol ] bi ] each ;

: forget-smudged ( -- )
    forget-removed-definitions
    reset-removed-classes
    fix-class-words ;

: finish-parsing ( lines quot -- )
    file get
    [ record-top-level-form ]
    [ record-definitions ]
    [ record-checksum ]
    tri ;

: parse-stream ( stream name -- quot )
    [
        [
            stream-lines dup parse-fresh
            [ nip ] [ finish-parsing ] 2bi
            forget-smudged
        ] with-source-file
    ] with-compilation-unit ;

: parse-file-restarts ( file -- restarts )
    "Load " " again" surround t 2array 1array ;

: parse-file ( file -- quot )
    [
        [ parsing-file ] keep
        [ utf8 <file-reader> ] keep
        parse-stream
    ] [
        over parse-file-restarts rethrow-restarts
        drop parse-file
    ] recover ;

: run-file ( file -- )
    parse-file call( -- ) ;

: ?run-file ( path -- )
    dup exists? [ run-file ] [ drop ] if ;

ERROR: version-control-merge-conflict ;
