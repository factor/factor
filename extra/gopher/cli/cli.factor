! Copyright (C) 2021 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays combinators.short-circuit command-loop
environment formatting gopher gopher.private io io.directories
io.encodings.utf8 io.files io.files.temp io.launcher io.pipes
kernel literals math math.parser namespaces present sequences
splitting system urls webbrowser ;

IN: gopher.cli

CONSTANT: DEFAULT-URL "gopher://gopher.quux.org"

CONSTANT: HISTORY V{ }
CONSTANT: LINKS V{ }
CONSTANT: STACK V{ }
CONSTANT: PAGE V{ }
CONSTANT: URL V{ }

: find-url ( url items -- i item )
    [ dup array? [ first ] when = ] with find ;

: nth-url ( i items -- url )
    ?nth dup array? [ first ] when ;

: stack-url ( delta -- url )
    URL ?first STACK find-url drop
    [ + STACK nth-url ] [ drop f ] if* ;

: add-stack ( args -- )
    dup dup array? [ first ] when
    dup STACK find-url drop [
        2drop
    ] [
        URL ?first STACK find-url drop [
            over PAGE find-url drop [
                1 + dup STACK nth-url rot = [
                    2drop
                ] [
                    STACK [ length ] [ delete-slice ] bi
                    STACK push
                    STACK length 10 > [
                        0 STACK remove-nth! drop
                    ] when
                ] if
            ] [
                2drop
                STACK push
            ] if
        ] [
            drop
            STACK delete-all
            STACK push
        ] if*
    ] if ;

: add-history ( args -- )
    HISTORY dup length 10 > [
        0 swap remove-nth!
    ] when dupd remove! push ;

: print-links ( links verbose? -- )
    LINKS delete-all over LINKS push-all
    '[
        1 + swap [ dup array? [ first ] when URL ?first = [ drop "*" ] when ] keep
        _ [ dup array? [ dup second empty? not ] [ f ] if ] [ f ] if [
            first2 swap "[%s] %s (%s)\n" printf
        ] [
            dup array? [ first2 ] [ f ] if
            dup empty? -rot ? "[%s] %s\n" printf
        ] if
    ] each-index ;

: gopher-history ( -- )
    HISTORY t print-links ;

: gopher-print ( item-type body -- )
    PAGE delete-all
    gopher-text swap ${ A_MENU A_INDEX } member?
    [ [ dup empty? [ <gopher-link> ] unless ] map ] when
    [
        dup gopher-link? [
            dup type>> CHAR: i = [
                name>> print
            ] [
                [ name>> ] [ >url present ] bi
                over 2array PAGE push
                PAGE length swap "[%s] %s\n" printf
            ] if
        ] [
            print
        ] if
    ] each
    LINKS delete-all PAGE LINKS push-all ;

: gopher-get ( args -- )
    dup array? [ first ] when dup URL set-first
    >url gopher over ${ A_TEXT A_MENU A_INDEX } member? [
        "gopher.txt" temp-file
        [ utf8 [ gopher-print ] with-file-writer ]
        [ utf8 file-contents print ] bi
    ] [
        "ERROR: Cannot display '" "'" surround print drop
    ] if ;

: gopher-go ( args -- )
    dup array? [ first ] when present [ DEFAULT-URL ] when-empty
    { [ "://" over subseq? ] [ "gopher://" head? ] } 1||
    [ "gopher://" prepend ] unless
    dup "gopher://" head? [
        [ add-history ] [ add-stack ] [ gopher-get ] tri
    ] [ open-url ] if ;

: gopher-reload ( -- )
    URL ?first gopher-go ;

: gopher-back ( -- )
    -1 stack-url [ gopher-get ] when* ;

: gopher-forward ( -- )
    1 stack-url [ gopher-get ] when* ;

: gopher-less ( -- )
    "gopher.txt" temp-file [
        utf8 [
            <process>
                "PAGER" os-env [ "less" ] unless* >>command
                input-stream get >>stdin
            try-process
        ] with-file-reader
    ] when-file-exists ;

: gopher-ls ( args -- )
    [ PAGE ] [ "-l" = ] bi* print-links ;

: gopher-quit ( -- )
    "gopher.txt" temp-file ?delete-file quit ;

: gopher-url ( -- )
    URL ?first [ print ] when* ;

: gopher-root ( -- )
    URL ?first [ >url "/" >>path gopher-go ] when* ;

: gopher-shell ( args -- )
    "|" split "gopher.txt" temp-file dup file-exists? [
        "cat" swap 2array prefix run-pipeline drop
    ] [ 2drop ] if ;

CONSTANT: COMMANDS {
    T{ command
        { name "back" }
        { quot [ drop gopher-back ] }
        { help "Go back to the previous gopher URL." }
        { abbrevs { "b" } } }
    T{ command
        { name "forward" }
        { quot [ drop gopher-forward ] }
        { help "Go forward to the next gopher URL." }
        { abbrevs { "f" } } }
    T{ command
        { name "history" }
        { quot [ drop gopher-history ] }
        { help "Display recently viewed gopher URLs." }
        { abbrevs { "h" "hist" } } }
    T{ command
        { name "less" }
        { quot [ drop gopher-less ] }
        { help "View the most recent gopher URL in a pager." }
        { abbrevs { "l" } } }
    T{ command
        { name "ls" }
        { quot [ gopher-ls ] }
        { help "List the currently available links." }
        { abbrevs f } }
    T{ command
        { name "go" }
        { quot [ gopher-go ] }
        { help "Go to a gopher URL" }
        { abbrevs { "g" } } }
    T{ command
        { name "url" }
        { quot [ drop gopher-url ] }
        { help "Print the most recent gopher URL." }
        { abbrevs f } }
    T{ command
        { name "reload" }
        { quot [ drop gopher-reload ] }
        { help "Reload the most recent gopher URL." }
        { abbrevs { "r" } } }
    T{ command
        { name "root" }
        { quot [ drop gopher-root ] }
        { help "Navigate to the most recent gopher URL's root." }
        { abbrevs f } }
    T{ command
        { name "shell" }
        { quot [ gopher-shell ] }
        { help "'cat' the most recent gopher URL through a shell." }
        { abbrevs { "!" } } }
    T{ command
        { name "home" }
        { quot [ drop DEFAULT-URL gopher-go ] }
        { help "Go to the default gopher URL" }
        { abbrevs f } }
    T{ command
        { name "quit" }
        { quot [ drop gopher-quit ] }
        { help "Quit the program." }
        { abbrevs { "q" "exit" } } }
}

TUPLE: gopher-command-loop < command-loop ;

M: gopher-command-loop missing-command
    over string>number [ 1 - LINKS ?nth ] [ f ] if* [
        gopher-go 3drop
    ] [
        call-next-method
    ] if* ;

: gopher-main ( -- )
    "Welcome to Gopher!" "GOPHER>"
    gopher-command-loop new-command-loop
    COMMANDS [ over add-command ] each
    run-command-loop ;

MAIN: gopher-main
