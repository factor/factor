! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io kernel lexer math.parser namespaces
source-files ;
IN: parser.notes

SYMBOL: parser-quiet?

t parser-quiet? set-global

: note. ( str -- )
    parser-quiet? get [
        current-source-file get [ path>> write ":" write ] when*
        lexer get [ line>> number>string write ": " write ] when*
        "Note:" print dup print
    ] unless drop ;
