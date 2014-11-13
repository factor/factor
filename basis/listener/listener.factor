! Copyright (C) 2003, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors colors.constants
combinators.short-circuit compiler.units continuations debugger
fry io io.styles kernel lexer locals math math.parser namespaces
parser parser.notes prettyprint sequences sets
source-files.errors system vocabs vocabs.loader vocabs.parser ;
IN: listener

GENERIC: stream-read-quot ( stream -- quot/f )
GENERIC# prompt. 1 ( stream prompt -- )

: prompt ( -- str )
    manifest get current-vocab>> [ name>> "IN: " prepend ] [ "" ] if* 
    auto-use? get [ " auto-use" append ] when ;

M: object prompt.
    nip H{
        { background T{ rgba f 1 0.7 0.7 1 } }
        { foreground COLOR: black }
    } format bl flush ;

: parse-lines-interactive ( lines -- quot/f )
    [ parse-lines ] with-compilation-unit ;

: read-quot-step ( lines -- quot/f )
    [ parse-lines-interactive ] [
        dup error>> unexpected-eof?
        [ 2drop f ] [ rethrow ] if
    ] recover ;

: read-quot-loop ( stream accum -- quot/f )
    over stream-readln dup [
        over push
        dup read-quot-step dup
        [ 2nip ] [ drop read-quot-loop ] if
    ] [
        3drop f
    ] if ;

M: object stream-read-quot
    V{ } clone read-quot-loop ;

: read-quot ( -- quot/f ) input-stream get stream-read-quot ;

SYMBOL: visible-vars

: show-var ( var -- ) visible-vars [ swap suffix ] change ;

: show-vars ( seq -- ) visible-vars [ swap union ] change ;

: hide-var ( var -- ) visible-vars [ remove ] change ;

: hide-vars ( seq -- ) visible-vars [ swap diff ] change ;

: hide-all-vars ( -- ) visible-vars off ;

SYMBOL: error-hook

: call-error-hook ( error -- )
    error-continuation get error-hook get
    call( continuation error -- ) ;

[ drop print-error-and-restarts ] error-hook set-global

SYMBOL: display-stacks?

t display-stacks? set-global

SYMBOL: max-stack-items

10 max-stack-items set-global

SYMBOL: error-summary?

t error-summary? set-global

<PRIVATE

: title. ( string -- )
    H{ { foreground T{ rgba f 0.3 0.3 0.3 1 } } } format nl ;

: visible-vars. ( -- )
    visible-vars get [
        nl "--- Watched variables:" title.
        standard-table-style [
            [
                [
                    [ [ short. ] with-cell ]
                    [ [ get short. ] with-cell ]
                    bi
                ] with-row
            ] each
        ] tabular-output nl
    ] unless-empty ;

: trimmed-stack. ( seq -- )
    dup length max-stack-items get > [
        max-stack-items get cut*
        [
            [ length number>string "(" " more items)" surround ] keep
            write-object nl
        ] dip
    ] when stack. ;

: datastack. ( datastack -- )
    display-stacks? get [
        [ nl "--- Data stack:" title. trimmed-stack. ] unless-empty
    ] [ drop ] if ;

:: (listener) ( datastack -- )
    parser-quiet? off
    error-summary? get [ error-summary ] when
    visible-vars.
    datastack datastack.
    input-stream get prompt prompt.

    [
        read-quot [
            '[ datastack _ with-datastack ]
            [ call-error-hook datastack ]
            recover
        ] [ return ] if*
    ] [
        dup lexer-error?
        [ call-error-hook datastack ]
        [ rethrow ]
        if
    ] recover

    (listener) ;

PRIVATE>

SYMBOL: interactive-vocabs

{
    "accessors"
    "arrays"
    "assocs"
    "combinators"
    "compiler.errors"
    "compiler.units"
    "continuations"
    "debugger"
    "definitions"
    "editors"
    "help"
    "help.apropos"
    "help.lint"
    "help.vocabs"
    "inspector"
    "io"
    "io.files"
    "io.pathnames"
    "kernel"
    "listener"
    "math"
    "math.order"
    "memory"
    "namespaces"
    "parser"
    "prettyprint"
    "see"
    "sequences"
    "slicing"
    "sorting"
    "stack-checker"
    "strings"
    "syntax"
    "tools.annotations"
    "tools.crossref"
    "tools.deprecation"
    "tools.destructors"
    "tools.disassembler"
    "tools.dispatch"
    "tools.errors"
    "tools.memory"
    "tools.profiler.sampling"
    "tools.test"
    "tools.threads"
    "tools.time"
    "tools.walker"
    "vocabs"
    "vocabs.loader"
    "vocabs.refresh"
    "vocabs.hierarchy"
    "words"
} interactive-vocabs set-global

: loaded-vocab? ( vocab-spec -- ? )
    {
        [ find-vocab-root not ]
        [ source-loaded?>> +done+ eq? ]
    } 1|| ;

: use-loaded-vocabs ( vocabs -- )
    [
        lookup-vocab [
            dup loaded-vocab? [ use-vocab ] [ drop ] if
        ] when*
    ] each ;

: with-interactive-vocabs ( quot -- )
    [
        "scratchpad" set-current-vocab
        interactive-vocabs get use-loaded-vocabs
        call
    ] with-manifest ; inline

: listener ( -- )
    [ [ { } (listener) ] with-return ] with-interactive-vocabs ;

: listener-main ( -- )
    version-info print flush listener ;

MAIN: listener-main
