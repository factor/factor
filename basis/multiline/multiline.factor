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

SYNTAX: STRING:
    CREATE-WORD
    parse-here 1quotation
    (( -- string )) define-inline ;

<PRIVATE

:: (scan-multiline-string) ( i end -- j )
    lexer get line-text>> :> text
    text [
        end text i start* [| j |
            i j text subseq % j end length +
        ] [
            text i short tail % CHAR: \n ,
            lexer get next-line
            0 end (scan-multiline-string)
        ] if*
    ] [ end unexpected-eof ] if ;
        
:: (parse-multiline-string) ( end-text skip-n-chars -- str )
    [
        lexer get
        [ skip-n-chars + end-text (scan-multiline-string) ]
        change-column drop
    ] "" make ;

PRIVATE>

: parse-multiline-string ( end-text -- str )
    1 (parse-multiline-string) ;

SYNTAX: <"
    "\">" parse-multiline-string parsed ;

SYNTAX: <'
    "'>" parse-multiline-string parsed ;

SYNTAX: {'
    "'}" parse-multiline-string parsed ;

SYNTAX: {"
    "\"}" parse-multiline-string parsed ;

SYNTAX: /* "*/" parse-multiline-string drop ;

SYNTAX: HEREDOC:
    scan
    lexer get next-line
    0 (parse-multiline-string)
    parsed ;
