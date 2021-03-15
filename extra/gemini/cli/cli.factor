! Copyright (C) 2021 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs combinators
combinators.short-circuit command-loop formatting gemini
gemini.private io io.directories io.encodings.string
io.encodings.utf8 io.files io.files.temp io.launcher io.pipes
kernel math math.parser namespaces present sequences splitting
system urls webbrowser ;

IN: gemini.cli

CONSTANT: DEFAULT-URL "gemini://gemini.circumlunar.space"

CONSTANT: HISTORY V{ }
CONSTANT: LINKS V{ }
CONSTANT: STACK V{ }
CONSTANT: PAGE V{ }
CONSTANT: URL V{ }

: add-stack ( args -- )
    dup PAGE keys index [ STACK delete-all ] unless
    URL ?first STACK index [
        1 + dup STACK ?nth pick = [
            2drop
        ] [
            STACK [ length ] [ delete-slice ] bi
            STACK push
            STACK length 10 > [
                0 STACK remove-nth! drop
            ] when
        ] if
    ] [
        STACK push
    ] if* ;

: add-history ( args -- )
    HISTORY dup length 10 > [
        0 swap remove-nth!
    ] when dupd remove! push ;

: gemini-history ( -- )
    HISTORY [ 1 + swap "[%d] %s\n" printf ] each-index
    LINKS delete-all HISTORY LINKS push-all ;

: gemini-print ( url body meta -- )
    f pre [
        PAGE delete-all
        gemini-charset decode string-lines [
            { [ pre get not ] [ "=>" ?head ] } 0&& [
                swap gemini-link present over 2array PAGE push
                PAGE length swap "[%s] %s\n" printf
            ] [
                gemini-line.
            ] if
        ] with each
        LINKS delete-all PAGE keys LINKS push-all
    ] with-variable ;

: gemini-get ( args -- )
    dup URL set-first
    >url dup gemini [ drop ] 2dip swap "text/" ?head [
        "gemini.txt" temp-file
        [ utf8 [ gemini-print ] with-file-writer ]
        [ utf8 file-contents print ] bi
    ] [
        "ERROR: Cannot display '" "'" surround print 2drop
    ] if ;

: gemini-go ( args -- )
    present [ DEFAULT-URL ] when-empty
    { [ "://" over subseq? ] [ "gemini://" head? ] } 1||
    [ "gemini://" prepend ] unless
    dup "gemini://" head? [
        [ add-history ] [ add-stack ] [ gemini-get ] tri
    ] [ open-url ] if ;

: gemini-reload ( -- )
    HISTORY ?last gemini-go ;

: gemini-back ( -- )
    URL ?first STACK index [
        1 - STACK ?nth [ gemini-get ] when*
    ] when* ;

: gemini-forward ( -- )
    URL ?first STACK index [
        1 + STACK ?nth [ gemini-get ] when*
    ] when* ;

: gemini-up ( -- )
    URL ?first [
        >url f >>query f >>anchor
        [ "/" ?tail drop "/" split1-last drop "/" append ] change-path
        gemini-go
    ] when* ;

: gemini-less ( -- )
    "gemini.txt" temp-file dup exists? [
        "less" swap 2array try-process
    ] [ drop ] if ;

 : gemini-ls ( args -- )
    PAGE swap "-l" = '[
        1 + swap first2 swap
        _ [ " (" ")" surround ] [ drop f ] if
        "[%d] %s%s\n" printf
    ] each-index
    LINKS delete-all PAGE keys LINKS push-all ;

: gemini-quit ( -- )
    "gemini.txt" temp-file ?delete-file 0 exit ;

: gemini-url ( -- )
    URL ?first [ print ] when* ;

: gemini-root ( -- )
    URL ?first [ >url "/" >>path gemini-go ] when* ;

: gemini-shell ( args -- )
    "|" split "gemini.txt" temp-file dup exists? [
        "cat" swap 2array prefix run-pipeline drop
    ] [ 2drop ] if ;

: gemini-stack ( -- )
    STACK [
        1 + swap dup URL ?first = " (*)" f ?
        "[%d] %s%s\n" printf
    ] each-index
    LINKS delete-all STACK LINKS push-all ;

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
        { name "stack" }
        { quot [ drop gemini-stack ] }
        { help "Display the current navigation stack." }
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
