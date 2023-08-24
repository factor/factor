! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: accessors compiler.units kernel lexer math multiline
parser sequences splitting ;

IN: literate

TUPLE: literate-lexer < lexer ;

: <literate-lexer> ( text -- lexer ) literate-lexer new-lexer ;

M: literate-lexer skip-blank
    dup column>> zero? [
        dup line-text>> [
            "> " head?
            [ [ 2 + ] change-column call-next-method ]
            [ [ nip length ] change-lexer-column ]
            if
        ] [ drop ] if*
    ] [ call-next-method ] if ;

SYNTAX: <LITERATE
    "LITERATE>" parse-multiline-string string-lines [
        <literate-lexer> (parse-lines) append!
    ] with-nested-compilation-unit ;
