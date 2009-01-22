! Copyright (C) 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces make parser lexer kernel sequences words
quotations math accessors locals ;
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
    parse-here 1quotation
    (( -- string )) define-inline ; parsing

<PRIVATE

:: (parse-multiline-string) ( i end -- j )
    lexer get line-text>> :> text
    text [
        end text i start* [| j |
            i j text subseq % j end length +
        ] [
            text i short tail % CHAR: \n ,
            lexer get next-line
            0 end (parse-multiline-string)
        ] if*
    ] [ end unexpected-eof ] if ;
        
PRIVATE>

: parse-multiline-string ( end-text -- str )
    [
        lexer get
        [ 1+ swap (parse-multiline-string) ]
        change-column drop
    ] "" make ;

: <"
    "\">" parse-multiline-string parsed ; parsing

: <'
    "'>" parse-multiline-string parsed ; parsing

: {'
    "'}" parse-multiline-string parsed ; parsing

: {"
    "\"}" parse-multiline-string parsed ; parsing

: /* "*/" parse-multiline-string drop ; parsing
