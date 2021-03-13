! Copyright (C) 2021 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays combinators.short-circuit
command-line.loop formatting gemini gemini.private io
io.directories io.encodings.string io.encodings.utf8 io.files
io.files.temp io.launcher kernel math math.parser namespaces
present sequences splitting system urls webbrowser ;

IN: gemini.cli

CONSTANT: DEFAULT-URL "gemini://gemini.circumlunar.space"

CONSTANT: HISTORY V{ }
CONSTANT: LINKS V{ }
CONSTANT: STACK V{ }
CONSTANT: URL V{ }

: add-stack ( args -- )
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
    HISTORY [ 1 + swap "[%s] %s\n" printf ] each-index
    LINKS delete-all HISTORY LINKS push-all ;

: gemini-print ( url body meta -- )
    f pre [
        LINKS delete-all
        gemini-charset decode string-lines [
            { [ pre get not ] [ "=>" ?head ] } 0&& [
                swap gemini-link present LINKS push
                LINKS length swap "[%s] %s\n" printf
            ] [
                gemini-line.
            ] if
        ] with each
    ] with-variable ;

: gemini-get ( args -- )
    dup 0 URL set-nth
    >url dup gemini [ drop ] 2dip swap "text/" ?head [
        "gemini.txt" temp-file
        [ utf8 [ gemini-print ] with-file-writer ]
        [ utf8 file-contents print ] bi
    ] [
        "ERROR: Cannot display '" "'" surround print 2drop
    ] if ;

: gemini-go ( args -- )
    [ DEFAULT-URL ] when-empty
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
        present gemini-go
    ] when* ;

: gemini-less ( -- )
    "less" "gemini.txt" temp-file 2array try-process ;

: gemini-quit ( -- )
    "gemini.txt" temp-file ?delete-file 0 exit ;

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
        { name "reload" }
        { quot [ drop gemini-reload ] }
        { help "Reload the most recent Gemini URL." }
        { abbrevs { "r" } } }
    T{ command
        { name "quit" }
        { quot [ drop gemini-quit ] }
        { help "Quit the program." }
        { abbrevs { "q" } } }
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
