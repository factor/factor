! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions generic assocs kernel math
namespaces prettyprint sequences strings vectors words
quotations inspector io.styles io combinators sorting
splitting math.parser effects continuations debugger 
io.files io.streams.string io.streams.lines vocabs
source-files classes hashtables ;
IN: parser

SYMBOL: file

TUPLE: lexer text line column ;

: <lexer> ( text -- lexer ) 1 0 lexer construct-boa ;

: line-text ( lexer -- str )
    dup lexer-line 1- swap lexer-text ?nth ;

: location ( -- loc )
    file get lexer get lexer-line 2dup and
    [ >r source-file-path r> 2array ] [ 2drop f ] if ;

SYMBOL: old-definitions
SYMBOL: new-definitions

TUPLE: redefine-error def ;

M: redefine-error error.
    "Re-definition of " write
    redefine-error-def . ;

: redefine-error ( definition -- )
    \ redefine-error construct-boa
    { { "Continue" t } } throw-restarts drop ;

: redefinition? ( definition -- ? )
    dup class? [ drop f ] [ new-definitions get key? ] if ;

: (save-location) ( definition loc -- )
    over redefinition? [ over redefine-error ] when
    over set-where
    dup new-definitions get dup [ set-at ] [ 3drop ] if ;

: save-location ( definition -- )
    location (save-location) ;

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

: next-line ( lexer -- )
    0 over set-lexer-column
    dup lexer-line 1+ swap set-lexer-line ;

: skip ( i seq quot -- n )
    over >r find* drop
    [ r> drop ] [ r> length ] if* ; inline

: change-column ( lexer quot -- )
    swap
    [ dup lexer-column swap line-text rot call ] keep
    set-lexer-column ; inline

GENERIC: skip-blank ( lexer -- )

M: lexer skip-blank ( lexer -- )
    [ [ blank? not ] skip ] change-column ;

GENERIC: skip-word ( lexer -- )

M: lexer skip-word ( lexer -- )
    [
        2dup nth CHAR: " =
        [ drop 1+ ] [ [ blank? ] skip ] if
    ] change-column ;

: still-parsing? ( lexer -- ? )
    dup lexer-line swap lexer-text length <= ;

: still-parsing-line? ( lexer -- ? )
    dup lexer-column swap line-text length < ;

: (parse-token) ( lexer -- str )
    [ lexer-column ] keep
    [ skip-word ] keep
    [ lexer-column ] keep
    line-text subseq ;

:  parse-token ( lexer -- str/f )
    dup still-parsing? [
        dup skip-blank
        dup still-parsing-line?
        [ (parse-token) ] [ dup next-line parse-token ] if
    ] [ drop f ] if ;

: scan ( -- str/f ) lexer get parse-token ;

TUPLE: bad-escape ;

: bad-escape ( -- * ) \ bad-escape construct-empty throw ;

M: bad-escape summary drop "Bad escape code" ;

: escape ( escape -- ch )
    H{
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

: next-escape ( m str -- n ch )
    2dup nth CHAR: u =
    [ >r 1+ dup 4 + tuck r> subseq hex> ]
    [ over 1+ -rot nth escape ] if ;

: next-char ( m str -- n ch )
    2dup nth CHAR: \\ =
    [ >r 1+ r> next-escape ] [ over 1+ -rot nth ] if ;

: (parse-string) ( m str -- n )
    2dup nth CHAR: " =
    [ drop 1+ ] [ [ next-char , ] keep (parse-string) ] if ;

: parse-string ( -- str )
    lexer get [
        [ (parse-string) ] "" make swap
    ] change-column ;

TUPLE: parse-error file line col text ;

: <parse-error> ( msg -- error )
    file get
    lexer get lexer-line
    lexer get lexer-column
    lexer get line-text
    parse-error construct-boa
    [ set-delegate ] keep ;

: parse-dump ( error -- )
    dup parse-error-file file.
    dup parse-error-line number>string print
    dup parse-error-text dup string? [ print ] [ drop ] if
    parse-error-col 0 or CHAR: \s <string> write
    "^" print ;

M: parse-error error.
    dup parse-dump  delegate error. ;

SYMBOL: use
SYMBOL: in

: word/vocab% ( word -- )
    "(" % dup word-vocabulary % " " % word-name % ")" % ;

: shadow-warning ( new old -- )
    2dup eq? [
        2drop
    ] [
        [ word/vocab% " shadowed by " % word/vocab% ] "" make
        note.
    ] if ;

: shadow-warnings ( vocab vocabs -- )
    [
        swapd assoc-stack dup
        [ shadow-warning ] [ 2drop ] if
    ] curry assoc-each ;

: (use+) ( vocab -- )
    vocab-words use get 2dup shadow-warnings push ;

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

: create-in ( string -- word )
    in get create dup set-word dup save-location ;

TUPLE: unexpected want got ;

: unexpected ( want got -- * )
    \ unexpected construct-boa throw ;

PREDICATE: unexpected unexpected-eof
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

: CREATE ( -- word ) scan create-in ;

: CREATE-CLASS ( -- word )
    scan create-in dup predicate-word save-location ;

: word-restarts ( possibilities -- restarts )
    natural-sort [
        [ "Use the word " swap summary append ] keep
    ] { } map>assoc ;

TUPLE: no-word name ;

M: no-word summary
    drop "Word not found in current vocabulary search path" ;

: no-word ( name -- newword )
    dup \ no-word construct-boa
    swap words-named word-restarts throw-restarts
    dup word-vocabulary (use+) ;

: forward-reference? ( word -- ? )
    dup old-definitions get key?
    swap new-definitions get key? not and ;

TUPLE: forward-error word ;

M: forward-error error.
    "Forward reference to " write forward-error-word . ;

: forward-error ( word -- )
    \ forward-error construct-boa throw ;

: check-forward ( str word -- word )
    dup forward-reference? [
        drop
        dup use get
        [ at ] curry* map [ ] subset
        [ forward-reference? not ] find nip
        [ ] [ forward-error ] ?if
    ] [
        nip
    ] if ;

: search ( str -- word )
    dup use get assoc-stack [ check-forward ] [ no-word ] if* ;

: scan-word ( -- word/number/f )
    scan dup [ dup string>number [ ] [ search ] ?if ] when ;

: parse-step ( accum end -- accum ? )
    scan-word {
        { [ 2dup eq? ] [ 2drop f ] }
        { [ dup not ] [ drop unexpected-eof t ] }
        { [ dup delimiter? ] [ unexpected t ] }
        { [ dup parsing? ] [ nip execute t ] }
        { [ t ] [ pick push drop t ] }
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
    ")" parse-tokens { "--" } split1 dup [
        <effect>
    ] [
        "Stack effect declaration must contain --" throw
    ] if ;

TUPLE: bad-number ;

: bad-number ( -- * ) \ bad-number construct-boa throw ;

: parse-base ( parsed base -- parsed )
    scan swap base> [ bad-number ] unless* parsed ;

: parse-literal ( accum end quot -- accum )
    >r parse-until r> call parsed ; inline

: parse-definition ( -- quot )
    \ ; parse-until >quotation ;

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

: file-vocabs ( -- )
    "scratchpad" in set
    { "syntax" "scratchpad" } set-use
    bootstrap-syntax get [ use get push ] when* ;

: parse-fresh ( lines -- quot )
    [ file-vocabs parse-lines ] with-scope ;

SYMBOL: parse-hook

: do-parse-hook ( -- ) parse-hook get [ call ] when* ;

: parsing-file ( file -- )
    "quiet" get [
        drop
    ] [
        "Loading " write <pathname> . flush
    ] if ;

: no-parse-hook ( quot -- )
    >r f parse-hook r> with-variable do-parse-hook ; inline

: start-parsing ( stream name -- )
    H{ } clone new-definitions set
    dup [
        source-file
        dup file set
        source-file-definitions clone old-definitions set
    ] [ drop ] if
    contents \ contents set ;

: smudged-usage-warning ( usages removed -- )
    parser-notes? [
        "Warning: the following definitions were removed from sources," print
        "but are still referenced from other definitions:" print
        nl
        dup stack.
        nl
        "The following definitions need to be updated:" print
        nl
        over stack.
    ] when 2drop ;

: outside-usages ( seq -- usages )
    dup [
        over usage [ pathname? not ] subset seq-diff
    ] curry { } map>assoc ;

: filter-moved ( assoc -- newassoc )
    [
        drop where dup [ first ] when
        file get source-file-path =
    ] assoc-subset ;

: smudged-usage ( -- usages referenced removed )
    new-definitions get old-definitions get diff filter-moved
    keys [
        outside-usages
        [ empty? swap pathname? or not ] assoc-subset
        dup values concat prune swap keys
    ] keep ;

: forget-smudged ( -- )
    smudged-usage [ forget ] each
    over empty? [ 2dup smudged-usage-warning ] unless 2drop ;

: record-definitions ( file -- )
    new-definitions get swap set-source-file-definitions ;

: finish-parsing ( quot -- )
    file get dup [
        [ record-form ] keep
        [ record-modified ] keep
        [ \ contents get record-checksum ] keep
        record-definitions
        forget-smudged
    ] [
        2drop
    ] if ;

: undo-parsing ( -- )
    file get [
        dup source-file-definitions new-definitions get union
        swap set-source-file-definitions
    ] when* ;

: parse-stream ( stream name -- quot )
    [
        [
            start-parsing
            \ contents get string-lines parse-fresh
            dup finish-parsing
        ] [ ] [ undo-parsing ] cleanup
    ] no-parse-hook ;

: parse-file-restarts ( file -- restarts )
    "Load " swap " again" 3append t 2array 1array ;

: parse-file ( file -- quot )
    [
        [ parsing-file ] keep
        [ ?resource-path <file-reader> ] keep
        parse-stream
    ] [
        over parse-file-restarts rethrow-restarts
        drop parse-file
    ] recover ;

: run-file ( file -- )
    [ [ parse-file call ] keep ] assert-depth drop ;

: reload ( defspec -- )
    where first [ run-file ] when* ;

: ?run-file ( path -- )
    dup ?resource-path exists? [ run-file ] [ drop ] if ;

: bootstrap-file ( path -- )
    [
        parse-file [ call ] curry %
    ] [
        run-file
    ] if-bootstrapping ;

: ?bootstrap-file ( path -- )
    dup ?resource-path exists? [ bootstrap-file ] [ drop ] if ;

: parse ( str -- quot ) string-lines parse-lines ;

: eval ( str -- ) parse call ;

: eval>string ( str -- output )
    [
        parser-notes off
        [ [ eval ] keep ] try drop
    ] string-out ;

global [
    {
        "scratchpad"
        "arrays"
        "assocs"
        "combinators"
        "compiler"
        "continuations"
        "debugger"
        "definitions"
        "generic"
        "inspector"
        "io"
        "kernel"
        "math"
        "memory"
        "namespaces"
        "parser"
        "prettyprint"
        "sequences"
        "slicing"
        "sorting"
        "strings"
        "syntax"
        "vocabs"
        "vocabs.loader"
        "words"
    } set-use
    "scratchpad" set-in
] bind
