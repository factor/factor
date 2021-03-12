! Copyright (C) 2021 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors ascii assocs combinators
combinators.short-circuit formatting gemini gemini.private io
io.encodings.string kernel math math.parser namespaces present
sequences splitting urls ;

IN: gemini.cli

CONSTANT: ABBREVS H{
     { "b"    "back" }
     { "f"    "forward" }
     { "g"    "go" }
     { "h"    "history" }
     { "hist" "history" }
     { "q"    "quit" }
     { "r"    "reload" }
     { "u"    "up" }
}

CONSTANT: HISTORY V{ }
CONSTANT: LINKS V{ }
CONSTANT: URL V{ }

: add-history ( args -- )
    HISTORY dup length 10 > [
        0 swap remove-nth!
    ] when dupd remove! push ;

: gemini-history ( args -- )
    drop HISTORY [ 1 + swap "[%s] %s\n" printf ] each-index
    LINKS delete-all HISTORY LINKS push-all ;

: gemini-get ( args -- )
    dup 0 URL set-nth
    >url dup gemini [ drop ] 2dip swap "text/" ?head [
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
        ] with-variable
    ] [
        "ERROR: Cannot display '" "'" surround print 2drop
    ] if ;

: gemini-go ( args -- )
    [ "gemini://gemini.circumlunar.space" ] when-empty
    dup "gemini://" head? [ "gemini://" prepend ] unless
    dup add-history gemini-get ;

: gemini-reload ( args -- )
    drop HISTORY ?last gemini-go ;

: gemini-back ( args -- )
    drop URL ?first HISTORY index [
        1 - HISTORY ?nth [ gemini-get ] when*
    ] when* ;

: gemini-forward ( args -- )
    drop URL ?first HISTORY index [
        1 + HISTORY ?nth [ gemini-get ] when*
    ] when* ;

: gemini-up ( args -- )
    drop URL ?first [
        >url f >>query f >>anchor
        [ "/" ?tail drop "/" split1-last drop "/" append ] change-path
        present gemini-go
    ] when* ;

: gemini-cmd ( cmd -- )
    " " split1 swap >lower ABBREVS ?at drop {
        { "history" [ gemini-history ] }
        { "go" [ gemini-go ] }
        { "reload" [ gemini-reload ] }
        { "back" [ gemini-back ] }
        { "forward" [ gemini-forward ] }
        { "up" [ gemini-up ] }
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
