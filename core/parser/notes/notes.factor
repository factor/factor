! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors io kernel lexer math.parser namespaces
source-files ;
IN: parser.notes

SYMBOL: parser-quiet?

t parser-quiet? set-global

: note. ( str -- )
    parser-quiet? get [ drop ] [
        current-source-file get [ path>> write ":" write ] when*
        lexer get [ line>> number>string write ": " write ] when*
        "Note:" print print
    ] if ;
