! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces kernel source-files lexer accessors io math.parser ;
IN: parser.notes

SYMBOL: parser-notes

t parser-notes set-global

: parser-notes? ( -- ? )
    parser-notes get "quiet" get not and ;

: note. ( str -- )
    parser-notes? [
        file get [ path>> write ":" write ] when* 
        lexer get [ line>> number>string write ": " write ] when*
        "Note:" print dup print
    ] when drop ;