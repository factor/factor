! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces kernel source-files lexer accessors io math.parser ;
IN: parser.notes

SYMBOL: parser-quiet?

t parser-quiet? set-global

: note. ( str -- )
    parser-quiet? get [
        file get [ path>> write ":" write ] when* 
        lexer get [ line>> number>string write ": " write ] when*
        "Note:" print dup print
    ] unless drop ;
