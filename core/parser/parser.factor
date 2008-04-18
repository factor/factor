! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions generic assocs kernel math namespaces
prettyprint sequences strings vectors words quotations inspector
io.styles io combinators sorting splitting math.parser effects
continuations debugger io.files io.streams.string vocabs
io.encodings.utf8 source-files classes classes.tuple hashtables
compiler.errors compiler.units accessors sets ;
IN: parser

TUPLE: lexer text line line-text line-length column ;

: next-line ( lexer -- )
    dup [ line>> ] [ text>> ] bi ?nth >>line-text
    dup line-text>> length >>line-length
    [ 1+ ] change-line
    0 >>column
    drop ;

: new-lexer ( text class -- lexer )
    new
        0 >>line
        swap >>text
    dup next-line ; inline

: <lexer> ( text -- lexer )
    lexer new-lexer ;

: location ( -- loc )
    file get lexer get lexer-line 2dup and
    [ >r source-file-path r> 2array ] [ 2drop f ] if ;

: save-location ( definition -- )
    location remember-definition ;

: save-class-location ( class -- )
    location remember-class ;

SYMBOL: parser-notes

t parser-notes set-global

: parser-notes? ( -- ? )
    parser-notes get "quiet" get not and ;

: file. ( file -- )
    [
        source-file-path <pathname> pprint
    ] [
        "<interactive>" write
    ] if* ":" write ;

: note. ( str -- )
    parser-notes? [
        file get file.
        lexer get [
            lexer-line number>string print
        ] [
            nl
        ] if*
        "Note: " write dup print
    ] when drop ;

: skip ( i seq ? -- n )
    over >r
    [ swap CHAR: \s eq? xor ] curry find* drop
    [ r> drop ] [ r> length ] if* ;

: change-lexer-column ( lexer quot -- )
    swap
    [ dup lexer-column swap lexer-line-text rot call ] keep
    set-lexer-column ; inline

GENERIC: skip-blank ( lexer -- )

M: lexer skip-blank ( lexer -- )
    [ t skip ] change-lexer-column ;

GENERIC: skip-word ( lexer -- )

M: lexer skip-word ( lexer -- )
    [
        2dup nth CHAR: " eq? [ drop 1+ ] [ f skip ] if
    ] change-lexer-column ;

: still-parsing? ( lexer -- ? )
    dup lexer-line swap lexer-text length <= ;

: still-parsing-line? ( lexer -- ? )
    dup lexer-column swap lexer-line-length < ;

: (parse-token) ( lexer -- str )
    [ lexer-column ] keep
    [ skip-word ] keep
    [ lexer-column ] keep
    lexer-line-text subseq ;

:  parse-token ( lexer -- str/f )
    dup still-parsing? [
        dup skip-blank
        dup still-parsing-line?
        [ (parse-token) ] [ dup next-line parse-token ] if
    ] [ drop f ] if ;

: scan ( -- str/f ) lexer get parse-token ;

ERROR: bad-escape ;

M: bad-escape summary drop "Bad escape code" ;

: escape ( escape -- ch )
    H{
        { CHAR: a  CHAR: \a }
        { CHAR: e  CHAR: \e }
        { CHAR: n  CHAR: \n }
        { CHAR: r  CHAR: \r }
        { CHAR: t  CHAR: \t }
        { CHAR: s  CHAR: \s }
        { CHAR: \s CHAR: \s }
        { CHAR: 0  CHAR: \0 }
        { CHAR: \\ CHAR: \\ }
        { CHAR: \" CHAR: \" }
    } at [ bad-escape ] unless* ;

SYMBOL: name>char-hook

name>char-hook global [
    [ "Unicode support not available" throw ] or
] change-at

: unicode-escape ( str -- ch str' )
    "{" ?head-slice [
        CHAR: } over index cut-slice
        >r >string name>char-hook get call r>
        1 tail-slice
    ] [
        6 cut-slice >r hex> r>
    ] if ;

: next-escape ( str -- ch str' )
    "u" ?head-slice [
        unicode-escape
    ] [
        unclip-slice escape swap
    ] if ;

: (parse-string) ( str -- m )
    dup [ "\"\\" member? ] find dup [
        >r cut-slice >r % r> 1 tail-slice r>
        dup CHAR: " = [
            drop slice-from
        ] [
            drop next-escape >r , r> (parse-string)
        ] if
    ] [
        "Unterminated string" throw
    ] if ;

: parse-string ( -- str )
    lexer get [
        [ swap tail-slice (parse-string) ] "" make swap
    ] change-lexer-column ;

TUPLE: parse-error file line column line-text error ;

: <parse-error> ( msg -- error )
    \ parse-error new
        file get >>file
        lexer get line>> >>line
        lexer get column>> >>column
        lexer get line-text>> >>line-text
        swap >>error ;

: parse-dump ( error -- )
    {
        [ file>> file. ]
        [ line>> number>string print ]
        [ line-text>> dup string? [ print ] [ drop ] if ]
        [ column>> 0 or CHAR: \s <string> write ]
    } cleave
    "^" print ;

M: parse-error error.
    [ parse-dump ] [ error>> error. ] bi ;

M: parse-error summary
    error>> summary ;

M: parse-error compute-restarts
    error>> compute-restarts ;

M: parse-error error-help
    error>> error-help ;

SYMBOL: use
SYMBOL: in

: word/vocab% ( word -- )
    "(" % dup word-vocabulary % " " % word-name % ")" % ;

: (use+) ( vocab -- )
    vocab-words use get push ;

: use+ ( vocab -- )
    load-vocab (use+) ;

: add-use ( seq -- ) [ use+ ] each ;

: set-use ( seq -- )
    [ vocab-words ] map [ ] subset >vector use set ;

: check-vocab-string ( name -- name )
    dup string?
    [ "Vocabulary name must be a string" throw ] unless ;

: set-in ( name -- )
    check-vocab-string dup in set create-vocab (use+) ;

ERROR: unexpected want got ;

PREDICATE: unexpected-eof < unexpected
    unexpected-got not ;

: unexpected-eof ( word -- * ) f unexpected ;

: (parse-tokens) ( accum end -- accum )
    scan 2dup = [
        2drop
    ] [
        [ pick push (parse-tokens) ] [ unexpected-eof ] if*
    ] if ;

: parse-tokens ( end -- seq )
    100 <vector> swap (parse-tokens) >array ;

: create-in ( string -- word )
    in get create dup set-word dup save-location ;

: CREATE ( -- word ) scan create-in ;

: CREATE-GENERIC ( -- word ) CREATE dup reset-word ;

: CREATE-WORD ( -- word ) CREATE dup reset-generic ;

: create-class-in ( word -- word )
    in get create
    dup save-class-location
    dup predicate-word dup set-word save-location ;

: CREATE-CLASS ( -- word )
    scan create-class-in ;

: word-restarts ( possibilities -- restarts )
    natural-sort [
        [ "Use the word " swap summary append ] keep
    ] { } map>assoc ;

TUPLE: no-word-error name ;

M: no-word-error summary
    drop "Word not found in current vocabulary search path" ;

: no-word ( name -- newword )
    dup no-word-error boa
    swap words-named [ forward-reference? not ] subset
    word-restarts throw-restarts
    dup word-vocabulary (use+) ;

: check-forward ( str word -- word/f )
    dup forward-reference? [
        drop
        use get
        [ at ] with map [ ] subset
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

: create-method-in ( class generic -- method )
    create-method f set-word dup save-location ;

: CREATE-METHOD ( -- method )
    scan-word bootstrap-word scan-word create-method-in ;

: shadowed-slots ( superclass slots -- shadowed )
    >r all-slot-names r> intersect ;

: check-slot-shadowing ( class superclass slots -- )
    shadowed-slots [
        [
            "Definition of slot ``" %
            %
            "'' in class ``" %
            word-name %
            "'' shadows a superclass slot" %
        ] "" make note.
    ] with each ;

ERROR: invalid-slot-name name ;

M: invalid-slot-name summary
    drop
    "Invalid slot name" ;

: (parse-tuple-slots) ( -- )
    #! This isn't meant to enforce any kind of policy, just
    #! to check for mistakes of this form:
    #!
    #! TUPLE: blahblah foo bing
    #!
    #! : ...
    scan {
        { [ dup not ] [ unexpected-eof ] }
        { [ dup { ":" "(" "<" } member? ] [ invalid-slot-name ] }
        { [ dup ";" = ] [ drop ] }
        [ , (parse-tuple-slots) ]
    } cond ;

: parse-tuple-slots ( -- seq )
    [ (parse-tuple-slots) ] { } make ;

: parse-tuple-definition ( -- class superclass slots )
    CREATE-CLASS
    scan {
        { ";" [ tuple f ] }
        { "<" [ scan-word parse-tuple-slots ] }
        [ >r tuple parse-tuple-slots r> prefix ]
    } case 3dup check-slot-shadowing ;

ERROR: staging-violation word ;

M: staging-violation summary
    drop
    "A parsing word cannot be used in the same file it is defined in." ;

: execute-parsing ( word -- )
    new-definitions get [
        dupd first key? [ staging-violation ] when
    ] when*
    execute ;

: parse-step ( accum end -- accum ? )
    scan-word {
        { [ 2dup eq? ] [ 2drop f ] }
        { [ dup not ] [ drop unexpected-eof t ] }
        { [ dup delimiter? ] [ unexpected t ] }
        { [ dup parsing? ] [ nip execute-parsing t ] }
        [ pick push drop t ]
    } cond ;

: (parse-until) ( accum end -- accum )
    dup >r parse-step [ r> (parse-until) ] [ r> drop ] if ;

: parse-until ( end -- vec )
    100 <vector> swap (parse-until) ;

: parsed ( accum obj -- accum ) over push ;

: with-parser ( lexer quot -- newquot )
    swap lexer set
    [ call >quotation ] [ <parse-error> rethrow ] recover ;

: (parse-lines) ( lexer -- quot )
    [ f parse-until ] with-parser ;

SYMBOL: lexer-factory

[ <lexer> ] lexer-factory set-global

: parse-lines ( lines -- quot )
    lexer-factory get call (parse-lines) ;

! Parsing word utilities
: parse-effect ( -- effect )
    ")" parse-tokens "(" over member? [
        "Stack effect declaration must not contain (" throw
    ] [
        { "--" } split1 dup [
            <effect>
        ] [
            "Stack effect declaration must contain --" throw
        ] if
    ] if ;

ERROR: bad-number ;

: parse-base ( parsed base -- parsed )
    scan swap base> [ bad-number ] unless* parsed ;

: parse-literal ( accum end quot -- accum )
    >r parse-until r> call parsed ; inline

: parse-definition ( -- quot )
    \ ; parse-until >quotation ;

: (:) CREATE-WORD parse-definition ;

SYMBOL: current-class
SYMBOL: current-generic

: (M:)
    CREATE-METHOD
    [
        [ "method-class" word-prop current-class set ]
        [ "method-generic" word-prop current-generic set ]
        [ ] tri
        parse-definition
    ] with-scope ;

: scan-object ( -- object )
    scan-word dup parsing?
    [ V{ } clone swap execute first ] when ;

GENERIC: expected>string ( obj -- str )

M: f expected>string drop "end of input" ;
M: word expected>string word-name ;
M: string expected>string ;

M: unexpected error.
    "Expected " write
    dup unexpected-want expected>string write
    " but got " write
    unexpected-got expected>string print ;

M: bad-number summary
    drop "Bad number literal" ;

SYMBOL: bootstrap-syntax

: with-file-vocabs ( quot -- )
    [
        "scratchpad" in set
        { "syntax" "scratchpad" } set-use
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
    assoc-diff [
        drop where dup [ first ] when
        file get source-file-path =
    ] assoc-subset keys ;

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
    filter-moved [ class? ] subset [ reset-class ] each ;

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
