! Copyright (C) 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces make parser lexer kernel sequences words
quotations math accessors locals ;
IN: multiline

ERROR: bad-heredoc identifier ;

<PRIVATE

: rest-of-line ( -- seq )
    lexer get [ line-text>> ] [ column>> ] bi tail ;

: next-line-text ( -- str )
    lexer get dup next-line line-text>> ;

: (parse-here) ( -- )
    next-line-text [
        dup ";" =
        [ drop lexer get next-line ]
        [ % "\n" % (parse-here) ] if
    ] [ ";" unexpected-eof ] if* ;

PRIVATE>

ERROR: text-found-before-eol string ;

: parse-here ( -- str )
    [
        rest-of-line dup [ drop ] [ text-found-before-eol ] if-empty
        (parse-here)
    ] "" make but-last ;

SYNTAX: STRING:
    scan-new-word
    parse-here 1quotation
    ( -- string ) define-inline ;

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

:: advance-same-line ( text -- )
    lexer get [ text length + ] change-column drop ;

:: (parse-til-line-begins) ( begin-text -- )
    lexer get still-parsing? [
        lexer get line-text>> begin-text sequence= [
            begin-text advance-same-line
        ] [
            lexer get line-text>> % "\n" %
            lexer get next-line
            begin-text (parse-til-line-begins)
        ] if
    ] [
        begin-text bad-heredoc
    ] if ;

: parse-til-line-begins ( begin-text -- seq )
    [ (parse-til-line-begins) ] "" make ;

PRIVATE>

: parse-multiline-string ( end-text -- str )
    1 (parse-multiline-string) ;

SYNTAX: /* "*/" parse-multiline-string drop ;

SYNTAX: HEREDOC:
    lexer get skip-blank
    rest-of-line
    lexer get next-line
    parse-til-line-begins suffix! ;

SYNTAX: DELIMITED:
    lexer get skip-blank
    rest-of-line
    lexer get next-line
    0 (parse-multiline-string) suffix! ;
