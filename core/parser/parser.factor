! Copyright (C) 2005, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes combinators compiler.units
continuations definitions effects io io.encodings.utf8 io.files
kernel lexer math.parser namespaces parser.notes quotations
sequences sets slots source-files vectors vocabs vocabs.parser
words words.symbol ;
IN: parser

: location ( -- loc/f )
    current-source-file get lexer get 2dup and
    [ [ path>> ] [ line>> ] bi* 2array ] [ 2drop f ] if ;

: save-location ( definition -- )
    location remember-definition ;

M: parsing-word stack-effect drop ( parsed -- parsed ) ;

: create-word-in ( str -- word )
    current-vocab create-word dup set-last-word dup save-location ;

SYMBOL: auto-use?

: no-word-restarted ( restart-value -- word )
    dup word? [
        dup vocabulary>>
        [ auto-use-vocab ]
        [ "Added \"" "\" vocabulary to search path" surround note. ] bi
    ] [ create-word-in ] if ;

: ignore-forwards ( seq -- seq' )
    [ forward-reference? ] reject ;

: private? ( word -- ? ) vocabulary>> ".private" tail? ;

: use-first-word? ( words -- ? )
    [ length 1 = ] [ ?first dup or* [ private? not ] when ] bi and
    auto-use? get and ;

! True branch is a singleton public word with no name conflicts
! False branch, singleton private words need confirmation regardless
! of name conflicts
: no-word ( name -- newword )
    dup words-named ignore-forwards
    dup use-first-word? [ nip first ] [ <no-word-error> throw-restarts ] if
    no-word-restarted ;

: parse-word ( string -- word )
    [ search ] [ no-word ] ?unless ;

ERROR: number-expected ;

: parse-number ( string -- number )
    string>number [ number-expected ] unless* ;

: parse-datum ( string -- word/number )
    [ search ]
    [ [ string>number ] [ no-word ] ?unless ] ?unless ;

: ?scan-datum ( -- word/number/f )
    ?scan-token [ parse-datum ] ?call ;

: scan-datum ( -- word/number )
    ?scan-datum [ \ word throw-unexpected-eof ] unless* ;

: scan-word ( -- word )
    ?scan-token parse-word ;

: scan-number ( -- number )
    ?scan-token parse-number ;

ERROR: invalid-word-name string ;

: check-word-name ( string -- string )
    dup "\"" = [ t ] [ dup string>number ] if
    [ invalid-word-name ] when ;

: scan-word-name ( -- string )
    scan-token check-word-name ;

: scan-new ( -- word )
    scan-word-name create-word-in ;

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

: ?execute-parsing ( word/number -- seq )
    dup parsing-word?
    [ V{ } clone swap execute-parsing ] [ 1array ] if ;

: scan-object ( -- object )
    scan-datum
    dup parsing-word? [
        V{ } clone swap execute-parsing first
    ] when ;

ERROR: classoid-expected object ;

: scan-class ( -- class )
    scan-object \ f or
    dup classoid? [ classoid-expected ] unless ;

: parse-until-step ( accum end -- accum ? )
    ?scan-datum {
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

: parse-array-def ( -- array )
    \ ; parse-until >array ;

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

: parse-fresh ( lines -- quot )
    [
        parse-lines
        auto-used? [ print-use-hook get call( -- ) ] when
    ] with-file-vocabs ;

: parsing-file ( path -- )
    parser-quiet? get [ drop ] [ "Loading " write print flush ] if ;

: filter-moved ( set1 set2 -- seq )
    swap diff members [
        {
            { [ dup where ?first current-source-file get path>> = not ] [ f ] }
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
    ! If a class word had a compound definition which was
    ! removed, it must go back to being a symbol.
    new-definitions get first2
    filter-moved [ [ reset-generic ] [ define-symbol ] bi ] each ;

: forget-smudged ( -- )
    forget-removed-definitions
    reset-removed-classes
    fix-class-words ;

: finish-parsing ( lines quot -- )
    current-source-file get
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

: parse-file-restarts ( path -- restarts )
    "Load " " again" surround t 2array 1array ;

: parse-file ( path -- quot )
    [
        [ parsing-file ] keep
        [ utf8 <file-reader> ] keep
        parse-stream
    ] [
        over parse-file-restarts rethrow-restarts
        drop parse-file
    ] recover ;

: run-file ( path -- )
    parse-file call( -- ) ;

: ?run-file ( path -- )
    dup file-exists? [ run-file ] [ drop ] if ;

ERROR: version-control-merge-conflict ;
