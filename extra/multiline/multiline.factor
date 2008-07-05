! Copyright (C) 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces parser lexer kernel sequences words quotations math ;
IN: multiline

: next-line-text ( -- str )
    lexer get dup next-line lexer-line-text ;

: (parse-here) ( -- )
    next-line-text [
        dup ";" =
        [ drop lexer get next-line ]
        [ % "\n" % (parse-here) ] if
    ] [ ";" unexpected-eof ] if* ;

: parse-here ( -- str )
    [ (parse-here) ] "" make but-last
    lexer get next-line ;

: STRING:
    CREATE-WORD
    parse-here 1quotation define-inline ; parsing

: (parse-multiline-string) ( start-index end-text -- end-index )
    lexer get lexer-line-text [
        2dup start
        [ rot dupd >r >r swap subseq % r> r> length + ] [
            rot tail % "\n" % 0
            lexer get next-line swap (parse-multiline-string)
        ] if*
    ] [ nip unexpected-eof ] if* ;

: parse-multiline-string ( end-text -- str )
    [
        lexer get lexer-column swap (parse-multiline-string)
        lexer get set-lexer-column
    ] "" make rest but-last ;

: <"
    "\">" parse-multiline-string parsed ; parsing

: /* "*/" parse-multiline-string drop ; parsing
