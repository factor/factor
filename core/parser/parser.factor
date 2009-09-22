! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions generic assocs kernel math namespaces
sequences strings vectors words words.symbol quotations io
combinators sorting splitting math.parser effects continuations
io.files vocabs io.encodings.utf8 source-files classes
hashtables compiler.units accessors sets lexer vocabs.parser
effects.parser slots parser.notes ;
IN: parser

: location ( -- loc )
    file get lexer get line>> 2dup and
    [ [ path>> ] dip 2array ] [ 2drop f ] if ;

: save-location ( definition -- )
    location remember-definition ;

M: parsing-word stack-effect drop (( parsed -- parsed )) ;

: create-in ( str -- word )
    current-vocab create dup set-word dup save-location ;

: CREATE ( -- word ) scan create-in ;

: CREATE-WORD ( -- word ) CREATE dup reset-generic ;

SYMBOL: auto-use?

: no-word-restarted ( restart-value -- word )
    dup word? [
        dup vocabulary>>
        [ auto-use-vocab ]
        [ "Added \"" "\" vocabulary to search path" surround note. ] bi
    ] [ create-in ] if ;

: no-word ( name -- newword )
    dup words-named [ forward-reference? not ] filter
    dup length 1 = auto-use? get and
    [ nip first no-word-restarted ]
    [ <no-word-error> throw-restarts no-word-restarted ]
    if ;

: scan-word ( -- word/number/f )
    scan dup [
        dup search [ ] [
            dup string>number [ ] [ no-word ] ?if
        ] ?if
    ] when ;

ERROR: staging-violation word ;

: execute-parsing ( accum word -- accum )
    dup changed-definitions get key? [ staging-violation ] when
    execute( accum -- accum ) ;

: scan-object ( -- object )
    scan-word dup parsing-word?
    [ V{ } clone swap execute-parsing first ] when ;

: parse-step ( accum end -- accum ? )
    scan-word {
        { [ 2dup eq? ] [ 2drop f ] }
        { [ dup not ] [ drop unexpected-eof t ] }
        { [ dup delimiter? ] [ unexpected t ] }
        { [ dup parsing-word? ] [ nip execute-parsing t ] }
        [ pick push drop t ]
    } cond ;

: (parse-until) ( accum end -- accum )
    [ parse-step ] keep swap [ (parse-until) ] [ drop ] if ;

: parse-until ( end -- vec )
    100 <vector> swap (parse-until) ;

SYMBOL: quotation-parser

HOOK: parse-quotation quotation-parser ( -- quot )

M: f parse-quotation \ ] parse-until >quotation ;

: parsed ( accum obj -- accum ) over push ;

: (parse-lines) ( lexer -- quot )
    [ f parse-until >quotation ] with-lexer ;

: parse-lines ( lines -- quot )
    lexer-factory get call( lines -- lexer ) (parse-lines) ;

: parse-literal ( accum end quot -- accum )
    [ parse-until ] dip call parsed ; inline

: parse-definition ( -- quot )
    \ ; parse-until >quotation ;

: (:) ( -- word def effect )
    CREATE-WORD
    complete-effect
    parse-definition swap ;

ERROR: bad-number ;

: scan-base ( base -- n )
    scan swap base> [ bad-number ] unless* ;

: parse-base ( parsed base -- parsed )
    scan-base parsed ;

SYMBOL: bootstrap-syntax

: with-file-vocabs ( quot -- )
    [
        <manifest> manifest set
        "syntax" use-vocab
        bootstrap-syntax get [ use-words ] when*
        call
    ] with-scope ; inline

SYMBOL: print-use-hook

print-use-hook [ [ ] ] initialize

: parse-fresh ( lines -- quot )
    [
        parse-lines
        auto-used? [ print-use-hook get call( -- ) ] when
    ] with-file-vocabs ;

: parsing-file ( file -- )
    "quiet" get [ drop ] [ "Loading " write print flush ] if ;

: filter-moved ( assoc1 assoc2 -- seq )
    swap assoc-diff keys [
        {
            { [ dup where dup [ first ] when file get path>> = not ] [ f ] }
            { [ dup reader-method? ] [ f ] }
            { [ dup writer-method? ] [ f ] }
            [ t ]
        } cond nip
    ] filter ;

: removed-definitions ( -- assoc1 assoc2 )
    new-definitions old-definitions
    [ get first2 assoc-union ] bi@ ;

: removed-classes ( -- assoc1 assoc2 )
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
