! Copyright (C) 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces parser kernel sequences words quotations ;
IN: multiline

: next-line-text ( -- str )
    lexer get dup next-line line-text ;

: (parse-here) ( -- )
    next-line-text dup ";" =
    [ drop lexer get next-line ] [ % "\n" % (parse-here) ] if ;

: parse-here ( -- str )
    [ (parse-here) ] "" make
    lexer get next-line ;

: STRING:
    CREATE dup reset-generic
    parse-here 1quotation define-compound ; parsing
