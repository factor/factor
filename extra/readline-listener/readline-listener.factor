! Copyright (C) 2011 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs colors combinators editors io
io.streams.256color io.streams.ansi io.streams.string kernel
listener readline sequences sets splitting terminfo threads
tools.completion ui.theme ui.theme.switching
ui.tools.listener.history unicode.data vocabs vocabs.hierarchy ;
IN: readline-listener

<PRIVATE

SYMBOL: completions

SYMBOLS: +256color+ +ansi+ ;

TUPLE: readline-reader { prompt initial: f } { mode initial: f } ;

: <readline-reader> ( mode -- reader )
    readline-reader new swap >>mode ;

: with-readline-reader ( reader quot -- )
    over mode>> {
        { +256color+ [ '[ _ with-256color ] with-input-stream* ] }
        { +ansi+ [ '[ _ with-ansi ] with-input-stream* ] }
        { f [ with-input-stream* ] }
    } case ; inline

INSTANCE: readline-reader input-stream

M: readline-reader stream-readln
    flush [ readline f ] change-prompt drop ;

M: readline-reader prompt.
    over [
        [ [ call-next-method ] with-readline-reader ] with-string-writer
    ] keep prompt<< ;

: clear-completions ( -- )
    f completions tset ;

: prefixed ( prefix seq -- seq' )
    swap '[ _ head? ] filter ;

: named ( seq -- seq' )
    [ name>> ] map ;

: qualified ( seq -- seq' )
    [ [ vocabulary>> ] [ name>> ] bi ":" glue ] map ;

: prefixed-words ( prefix -- words )
    all-words ":" pick subseq? [
        [ named ] [ qualified ] bi append
    ] [ named ] if prefixed members ;

: prefixed-vocabs ( prefix -- vocabs )
    all-disk-vocabs-recursive filter-vocabs named prefixed ;

: prefixed-vocab-words ( prefix vocab-name -- words )
    vocab-words named prefixed ;

: prefixed-colors ( prefix -- colors )
    named-colors prefixed ;

: prefixed-editors ( prefix -- editors )
    available-editors [ "editors." ?head drop ] map prefixed ;

: prefixed-chars ( prefix -- chars )
    name-map keys prefixed ;

: prefixed-paths ( prefix -- paths )
    dup paths-matching keys prefixed ;

: get-completions ( prefix -- completions )
    completions tget [ nip ] [
        completion-line " \r\n" split {
            { [ dup complete-vocab? ] [ drop prefixed-vocabs ] }
            { [ dup complete-char? ] [ drop prefixed-chars ] }
            { [ dup complete-color? ] [ drop prefixed-colors ] }
            { [ dup complete-editor? ] [ drop prefixed-editors ] }
            { [ dup complete-pathname? ] [ drop prefixed-paths ] }
            { [ dup complete-vocab-words? ] [ harvest second prefixed-vocab-words ] }
            [ drop prefixed-words ]
        } cond dup completions tset
    ] if* ;

PRIVATE>

: readline-listener ( -- )
    [
        swap get-completions ?nth
        [ clear-completions f ] unless*
    ] set-completion
    history-file [
        dark-theme switch-theme-if-default
        {
            { [ tty-supports-256color? ] [ +256color+ ] }
            { [ tty-supports-ansicolor? ] [ +ansi+ ] }
            [ f ]
        } cond
        <readline-reader> [ listener-main ] with-readline-reader
    ] with-history ;

: ?readline-listener ( -- )
    has-readline? [ readline-listener ] [ listener ] if ;

MAIN: readline-listener
