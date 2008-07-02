! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions generic assocs kernel math namespaces
prettyprint sequences strings vectors words quotations summary
io.styles io combinators sorting splitting math.parser effects
continuations debugger io.files io.streams.string vocabs
io.encodings.utf8 source-files classes hashtables
compiler.errors compiler.units accessors sets lexer ;
IN: parser

: location ( -- loc )
    file get lexer get line>> 2dup and
    [ >r path>> r> 2array ] [ 2drop f ] if ;

: save-location ( definition -- )
    location remember-definition ;

SYMBOL: parser-notes

t parser-notes set-global

: parser-notes? ( -- ? )
    parser-notes get "quiet" get not and ;

: note. ( str -- )
    parser-notes? [
        file get [ file. ] when*
        lexer get line>> number>string write ": " write
        "Note: " write dup print
    ] when drop ;

SYMBOL: use
SYMBOL: in

: (use+) ( vocab -- )
    vocab-words use get push ;

: use+ ( vocab -- )
    load-vocab (use+) ;

: add-use ( seq -- ) [ use+ ] each ;

: set-use ( seq -- )
    [ vocab-words ] V{ } map-as sift use set ;

: check-vocab-string ( name -- name )
    dup string?
    [ "Vocabulary name must be a string" throw ] unless ;

: set-in ( name -- )
    check-vocab-string dup in set create-vocab (use+) ;

M: parsing-word stack-effect drop (( parsed -- parsed )) ;

ERROR: no-current-vocab ;

M: no-current-vocab summary ( obj -- )
    drop "Not in a vocabulary; IN: form required" ;

: current-vocab ( -- str )
    in get [ no-current-vocab ] unless* ;

: create-in ( str -- word )
    current-vocab create dup set-word dup save-location ;

: CREATE ( -- word ) scan create-in ;

: CREATE-WORD ( -- word ) CREATE dup reset-generic ;

: word-restarts ( possibilities -- restarts )
    natural-sort [
        [ "Use the word " swap summary append ] keep
    ] { } map>assoc ;

TUPLE: no-word-error name ;

M: no-word-error summary
    drop "Word not found in current vocabulary search path" ;

: no-word ( name -- newword )
    dup no-word-error boa
    swap words-named [ forward-reference? not ] filter
    word-restarts throw-restarts
    dup vocabulary>> (use+) ;

: check-forward ( str word -- word/f )
    dup forward-reference? [
        drop
        use get
        [ at ] with map sift
        [ forward-reference? not ] find nip
    ] [
        nip
    ] if ;

: search ( str -- word/f )
    dup use get assoc-stack check-forward ;

: scan-word ( -- word/number/f )
    scan dup [
        dup search [ ] [
            dup string>number [ ] [ no-word ] ?if
        ] ?if
    ] when ;

ERROR: staging-violation word ;

M: staging-violation summary
    drop
    "A parsing word cannot be used in the same file it is defined in." ;

: execute-parsing ( word -- )
    dup changed-definitions get key? [ staging-violation ] when
    execute ;

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
    dup >r parse-step [ r> (parse-until) ] [ r> drop ] if ;

: parse-until ( end -- vec )
    100 <vector> swap (parse-until) ;

: parsed ( accum obj -- accum ) over push ;

: (parse-lines) ( lexer -- quot )
    [ f parse-until >quotation ] with-lexer ;

: parse-lines ( lines -- quot )
    lexer-factory get call (parse-lines) ;

: parse-literal ( accum end quot -- accum )
    >r parse-until r> call parsed ; inline

: parse-definition ( -- quot )
    \ ; parse-until >quotation ;

: (:) ( -- word def ) CREATE-WORD parse-definition ;

ERROR: bad-number ;

M: bad-number summary
    drop "Bad number literal" ;

: parse-base ( parsed base -- parsed )
    scan swap base> [ bad-number ] unless* parsed ;

SYMBOL: bootstrap-syntax

: with-file-vocabs ( quot -- )
    [
        f in set { "syntax" } set-use
        bootstrap-syntax get [ use get push ] when*
        call
    ] with-scope ; inline

SYMBOL: interactive-vocabs

{
    "accessors"
    "arrays"
    "assocs"
    "combinators"
    "compiler.errors"
    "continuations"
    "debugger"
    "definitions"
    "editors"
    "generic"
    "help"
    "inspector"
    "io"
    "io.files"
    "kernel"
    "listener"
    "math"
    "memory"
    "namespaces"
    "prettyprint"
    "sequences"
    "slicing"
    "sorting"
    "strings"
    "syntax"
    "tools.annotations"
    "tools.crossref"
    "tools.memory"
    "tools.profiler"
    "tools.test"
    "tools.threads"
    "tools.time"
    "tools.vocabs"
    "vocabs"
    "vocabs.loader"
    "words"
    "scratchpad"
} interactive-vocabs set-global

: with-interactive-vocabs ( quot -- )
    [
        "scratchpad" in set
        interactive-vocabs get set-use
        call
    ] with-scope ; inline

: parse-fresh ( lines -- quot )
    [ parse-lines ] with-file-vocabs ;

: parsing-file ( file -- )
    "quiet" get [
        drop
    ] [
        "Loading " write <pathname> . flush
    ] if ;

: filter-moved ( assoc1 assoc2 -- seq )
    swap assoc-diff [
        drop where dup [ first ] when
        file get source-file-path =
    ] assoc-filter keys ;

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
    [ record-form ]
    [ record-definitions ]
    [ record-checksum ]
    tri ;

: parse-stream ( stream name -- quot )
    [
        [
            lines dup parse-fresh
            tuck finish-parsing
            forget-smudged
        ] with-source-file
    ] with-compilation-unit ;

: parse-file-restarts ( file -- restarts )
    "Load " swap " again" 3append t 2array 1array ;

: parse-file ( file -- quot )
    [
        [
            [ parsing-file ] keep
            [ utf8 <file-reader> ] keep
            parse-stream
        ] with-compiler-errors
    ] [
        over parse-file-restarts rethrow-restarts
        drop parse-file
    ] recover ;

: run-file ( file -- )
    [ dup parse-file call ] assert-depth drop ;

: ?run-file ( path -- )
    dup exists? [ run-file ] [ drop ] if ;

: bootstrap-file ( path -- )
    [ parse-file % ] [ run-file ] if-bootstrapping ;

: eval ( str -- )
    [ string-lines parse-fresh ] with-compilation-unit call ;

: eval>string ( str -- output )
    [
        parser-notes off
        [ [ eval ] keep ] try drop
    ] with-string-writer ;
