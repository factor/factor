! Copyright (C) 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces parser lexer kernel sequences words quotations math
accessors ;
IN: multiline

<PRIVATE
: next-line-text ( -- str )
    lexer get dup next-line line-text>> ;

: (parse-here) ( -- )
    next-line-text [
        dup ";" =
        [ drop lexer get next-line ]
        [ % "\n" % (parse-here) ] if
    ] [ ";" unexpected-eof ] if* ;
PRIVATE>

: parse-here ( -- str )
    [ (parse-here) ] "" make but-last
    lexer get next-line ;

: STRING:
    CREATE-WORD
    parse-here 1quotation define-inline ; parsing

<PRIVATE
: (parse-multiline-string) ( start-index end-text -- end-index )
    lexer get line-text>> [
        2dup start
        [ rot dupd >r >r swap subseq % r> r> length + ] [
            rot tail % "\n" % 0
            lexer get next-line swap (parse-multiline-string)
        ] if*
    ] [ nip unexpected-eof ] if* ;
PRIVATE>

: parse-multiline-string ( end-text -- str )
    [
        lexer get [ swap (parse-multiline-string) ] change-column drop
    ] "" make rest-slice but-last ;

: <"
    "\">" parse-multiline-string parsed ; parsing

: /* "*/" parse-multiline-string drop ; parsing
