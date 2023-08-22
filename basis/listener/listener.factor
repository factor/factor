! Copyright (C) 2003, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors colors combinators.short-circuit
compiler.units continuations debugger fry io io.styles kernel lexer
math math.parser namespaces parser parser.notes prettyprint
sequences sets source-files.errors system vocabs vocabs.loader
vocabs.parser ;
IN: listener

GENERIC: stream-read-quot ( stream -- quot/f )
GENERIC#: prompt. 1 ( stream prompt -- )

: prompt ( -- str )
    manifest get current-vocab>> [ name>> "IN: " prepend ] [ "" ] if*
    auto-use? get [ dup empty? "" " " ? "auto-use" 3append ] when ;

SYMBOL: prompt-style
H{
    { background T{ rgba f 1 0.7 0.7 1 } }
    { foreground COLOR: black }
} prompt-style set-global

M: object prompt.
    nip [ prompt-style get-global format bl ] unless-empty ;

SYMBOL: handle-ctrl-break

: maybe-enable-ctrl-break ( -- )
    handle-ctrl-break get-global [ enable-ctrl-break ] when ;

: with-ctrl-break ( quot -- )
    maybe-enable-ctrl-break
    ! Always call disable-ctrl-break, no matter what handle-ctrl-break
    ! says: it might've been changed just now by the user in the Listener.
    ! It's a no-op if it's not enabled.
    [ disable-ctrl-break ] finally ; inline

: parse-lines-interactive ( lines -- quot/f )
    [ [ parse-lines ] with-ctrl-break ] with-compilation-unit ;

: read-quot-step ( lines -- quot/f )
    '[ _ parse-lines-interactive ]
    [ error>> unexpected-eof? ] ignore-error/f ;

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
    call( error continuation -- ) ;

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

: ?datastack. ( datastack -- )
    display-stacks? get [ datastack. ] [ drop ] if ;

:: listener-step ( datastack -- datastack' )
    error-summary? get [ error-summary ] when
    visible-vars.
    datastack ?datastack.
    input-stream get prompt prompt.
    flush
    [
        read-quot [
            '[ [ datastack _ with-datastack ] with-ctrl-break ]
            [ call-error-hook datastack ]
            recover
        ] [ return ] if*
    ] [
        dup lexer-error?
        [ call-error-hook datastack ]
        [ rethrow ]
        if
    ] recover ;

: listener-loop ( datastack -- )
    listener-step listener-loop ;

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
    "ranges"
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
    [
        parser-quiet? off
        [ { } listener-loop ] with-return
    ] with-interactive-vocabs ;

: listener-main ( -- )
    "q" get [ version-info print flush ] unless listener ;

MAIN: listener-main
