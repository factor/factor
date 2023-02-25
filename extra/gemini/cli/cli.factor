! Copyright (C) 2021 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays combinators.short-circuit command-loop
environment formatting gemini gemini.private io io.directories
io.encodings.string io.encodings.utf8 io.files io.files.temp
io.launcher io.pipes kernel math math.parser namespaces present
sequences splitting system urls webbrowser ;

IN: gemini.cli

CONSTANT: DEFAULT-URL "gemini://gemini.circumlunar.space"

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

: gemini-history ( -- )
    HISTORY t print-links ;

: gemini-print ( url body meta -- )
    f pre [
        PAGE delete-all
        gemini-charset decode split-lines [
            { [ pre get not ] [ "=>" ?head ] } 0&& [
                swap gemini-link present over 2array PAGE push
                PAGE length swap "[%s] %s\n" printf
            ] [
                gemini-line.
            ] if
        ] with each
        LINKS delete-all PAGE LINKS push-all
    ] with-variable ;

: gemini-get ( args -- )
    dup array? [ first ] when dup URL set-first
    >url dup gemini [ drop ] 2dip swap "text/" ?head [
        "gemini.txt" temp-file
        [ utf8 [ gemini-print ] with-file-writer ]
        [ utf8 file-contents print ] bi
    ] [
        "ERROR: Cannot display '" "'" surround print 2drop
    ] if ;

: gemini-go ( args -- )
    dup array? [ first ] when present [ DEFAULT-URL ] when-empty
    { [ dup "://" subseq-of? ] [ "gemini://" head? ] } 1||
    [ "gemini://" prepend ] unless
    dup "gemini://" head? [
        [ add-history ] [ add-stack ] [ gemini-get ] tri
    ] [ open-url ] if ;

: gemini-reload ( -- )
    URL ?first gemini-go ;

: gemini-back ( -- )
    -1 stack-url [ gemini-get ] when* ;

: gemini-forward ( -- )
    1 stack-url [ gemini-get ] when* ;

: gemini-up ( -- )
    URL ?first [
        >url f >>query f >>anchor
        [ dup "/" tail? "./../" "./" ? url-append-path ] change-path
        gemini-go
    ] when* ;

: gemini-less ( -- )
    "gemini.txt" temp-file dup file-exists? [
        utf8 [
            <process>
                "PAGER" os-env [ "less" ] unless* >>command
                input-stream get >>stdin
            try-process
        ] with-file-reader
    ] [ drop ] if ;

: gemini-ls ( args -- )
    [ PAGE ] [ "-l" = ] bi* print-links ;

: gemini-quit ( -- )
    "gemini.txt" temp-file ?delete-file 0 exit ;

: gemini-url ( -- )
    URL ?first [ print ] when* ;

: gemini-root ( -- )
    URL ?first [ >url "/" >>path gemini-go ] when* ;

: gemini-shell ( args -- )
    "|" split "gemini.txt" temp-file dup file-exists? [
        "cat" swap 2array prefix run-pipeline drop
    ] [ 2drop ] if ;

CONSTANT: COMMANDS {
    T{ command
        { name "back" }
        { quot [ drop gemini-back ] }
        { help "Go back to the previous Gemini URL." }
        { abbrevs { "b" } } }
    T{ command
        { name "forward" }
        { quot [ drop gemini-forward ] }
        { help "Go forward to the next Gemini URL." }
        { abbrevs { "f" } } }
    T{ command
        { name "history" }
        { quot [ drop gemini-history ] }
        { help "Display recently viewed Gemini URLs." }
        { abbrevs { "h" "hist" } } }
    T{ command
        { name "less" }
        { quot [ drop gemini-less ] }
        { help "View the most recent Gemini URL in a pager." }
        { abbrevs { "l" } } }
    T{ command
        { name "ls" }
        { quot [ gemini-ls ] }
        { help "List the currently available links." }
        { abbrevs f } }
    T{ command
        { name "go" }
        { quot [ gemini-go ] }
        { help "Go to a Gemini URL" }
        { abbrevs { "g" } } }
    T{ command
        { name "gus" }
        { quot [ drop "gemini://gus.guru/search" gemini-go ] }
        { help "Submit a query to the GUS search engine." }
        { abbrevs f } }
    T{ command
        { name "up" }
        { quot [ drop gemini-up ] }
        { help "Go up one directory from the recent Gemini URL." }
        { abbrevs { "u" } } }
    T{ command
        { name "url" }
        { quot [ drop gemini-url ] }
        { help "Print the most recent Gemini URL." }
        { abbrevs f } }
    T{ command
        { name "reload" }
        { quot [ drop gemini-reload ] }
        { help "Reload the most recent Gemini URL." }
        { abbrevs { "r" } } }
    T{ command
        { name "root" }
        { quot [ drop gemini-root ] }
        { help "Navigate to the most recent Gemini URL's root." }
        { abbrevs f } }
    T{ command
        { name "shell" }
        { quot [ gemini-shell ] }
        { help "'cat' the most recent Gemini URL through a shell." }
        { abbrevs { "!" } } }
    T{ command
        { name "home" }
        { quot [ drop DEFAULT-URL gemini-go ] }
        { help "Go to the default Gemini URL" }
        { abbrevs f } }
    T{ command
        { name "quit" }
        { quot [ drop gemini-quit ] }
        { help "Quit the program." }
        { abbrevs { "q" "exit" } } }
}

TUPLE: gemini-command-loop < command-loop ;

M: gemini-command-loop missing-command
    over string>number [ 1 - LINKS ?nth ] [ f ] if* [
        gemini-go 3drop
    ] [
        call-next-method
    ] if* ;

: gemini-main ( -- )
    "Welcome to Project Gemini!" "GEMINI>"
    gemini-command-loop new-command-loop
    COMMANDS [ over add-command ] each
    run-command-loop ;

MAIN: gemini-main
