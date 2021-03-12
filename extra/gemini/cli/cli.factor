! Copyright (C) 2021 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays ascii assocs combinators
combinators.short-circuit formatting gemini gemini.private
grouping io io.directories io.encodings.string io.encodings.utf8
io.files io.files.temp io.launcher kernel math math.parser
namespaces present sequences splitting system urls webbrowser ;

IN: gemini.cli

CONSTANT: ABBREVS H{
     { "b"    "back" }
     { "f"    "forward" }
     { "g"    "go" }
     { "h"    "history" }
     { "hist" "history" }
     { "l"    "less" }
     { "q"    "quit" }
     { "r"    "reload" }
     { "u"    "up" }
     { "?"    "help" }
}

CONSTANT: COMMANDS H{
    { "back"    "Go back to the previous Gemini URL." }
    { "forward" "Go forward to the next Gemini URL." }
    { "go"      "Go to a Gemini URL" }
    { "help"    "Get help for commands." }
    { "history" "Display recently viewed Gemini URLs." }
    { "less"    "View the most recent Gemini URL in a pager." }
    { "quit"    "Quit the program." }
    { "reload"  "Reload the most recent Gemini URL." }
    { "up"      "Go up one directory from the recent Gemini URL." }
}

CONSTANT: HISTORY V{ }
CONSTANT: LINKS V{ }
CONSTANT: URL V{ }

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
    [ "gemini://gemini.circumlunar.space" ] when-empty
    { [ "://" over subseq? ] [ "gemini://" head? ] } 1||
    [ "gemini://" prepend ] unless
    dup "gemini://" head? [
        dup add-history gemini-get
    ] [ open-url ] if ;

: gemini-reload ( -- )
    HISTORY ?last gemini-go ;

: gemini-back ( -- )
    URL ?first HISTORY index [
        1 - HISTORY ?nth [ gemini-get ] when*
    ] when* ;

: gemini-forward ( -- )
    URL ?first HISTORY index [
        1 + HISTORY ?nth [ gemini-get ] when*
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

: gemini-help ( args -- )
    [
        COMMANDS keys
        [ 6 <groups> ] [ longest length 4 + ] bi
        '[ [ _ CHAR: \s pad-tail write ] each nl ] each
    ] [
        ABBREVS ?at drop COMMANDS ?at [
            print
        ] [
            "ERROR: Command '" "' not found" surround print
        ] if
    ] if-empty ;

: gemini-cmd ( cmd -- )
    " " split1 swap >lower ABBREVS ?at drop {
        { "help" [ gemini-help ] }
        { "history" [ drop gemini-history ] }
        { "go" [ gemini-go ] }
        { "reload" [ drop gemini-reload ] }
        { "back" [ drop gemini-back ] }
        { "forward" [ drop gemini-forward ] }
        { "up" [ drop gemini-up ] }
        { "less" [ drop gemini-less ] }
        { "quit" [ drop gemini-quit ] }
        { "" [ drop ] }
        [
            dup string>number [ 1 - LINKS ?nth ] [ f ] if* [
                2nip gemini-go
            ] [
                "ERROR: Unknown command '" "'" surround print drop
            ] if*
        ]
    } case flush ;

: gemini-main ( -- )
    "Welcome to Project Gemini!" print flush [
        "GEMINI> " write flush readln
        [ gemini-cmd t ] [ f ] if*
    ] loop ;

MAIN: gemini-main
