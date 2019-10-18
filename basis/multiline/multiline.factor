! Copyright (C) 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel lexer locals make math
namespaces parser quotations sequences words ;
IN: multiline

ERROR: bad-heredoc identifier ;

<PRIVATE

: rest-of-line ( lexer -- seq )
    [ line-text>> ] [ column>> ] bi tail ;

: next-line-text ( lexer -- str ? )
    [ next-line ] [ line-text>> ] [ still-parsing? ] tri ;

: (parse-here) ( lexer -- )
    dup next-line-text [
        dup ";" =
        [ drop next-line ]
        [ % CHAR: \n , (parse-here) ] if
    ] [ ";" throw-unexpected-eof ] if ;

PRIVATE>

ERROR: text-found-before-eol string ;

: parse-here ( -- str )
    [
        lexer get
        dup rest-of-line [ text-found-before-eol ] unless-empty
        (parse-here)
    ] "" make but-last ;

SYNTAX: STRING:
    scan-new-word
    parse-here 1quotation
    ( -- string ) define-inline ;

<PRIVATE

:: (scan-multiline-string) ( i end lexer -- j )
    lexer line-text>> :> text
    lexer still-parsing? [
        end text i subseq-start-from [| j |
            i j text subseq % j end length +
        ] [
            text i short tail % CHAR: \n ,
            lexer next-line
            0 end lexer (scan-multiline-string)
        ] if*
    ] [ end throw-unexpected-eof ] if ;

:: (parse-multiline-string) ( end-text lexer skip-n-chars -- str )
    [
        lexer
        [ skip-n-chars + end-text lexer (scan-multiline-string) ]
        change-column drop
    ] "" make ;

: advance-same-line ( lexer text -- )
    length [ + ] curry change-column drop ;

:: (parse-til-line-begins) ( begin-text lexer -- )
    lexer still-parsing? [
        lexer line-text>> begin-text sequence= [
            lexer begin-text advance-same-line
        ] [
            lexer line-text>> % CHAR: \n ,
            lexer next-line
            begin-text lexer (parse-til-line-begins)
        ] if
    ] [
        begin-text bad-heredoc
    ] if ;

: parse-til-line-begins ( begin-text lexer -- seq )
    [ (parse-til-line-begins) ] "" make ;

PRIVATE>

: parse-multiline-string ( end-text -- str )
    lexer get 1 (parse-multiline-string) ;

SYNTAX: /* "*/" parse-multiline-string drop ;

SYNTAX: HEREDOC:
    lexer get {
        [ skip-blank ]
        [ rest-of-line ]
        [ next-line ]
        [ parse-til-line-begins ]
    } cleave suffix! ;

SYNTAX: [[ "]]" parse-multiline-string suffix! ;
SYNTAX: [=[ "]=]" parse-multiline-string suffix! ;
SYNTAX: [==[ "]==]" parse-multiline-string suffix! ;
SYNTAX: [===[ "]===]" parse-multiline-string suffix! ;
SYNTAX: [====[ "]====]" parse-multiline-string suffix! ;
SYNTAX: [=====[ "]=====]" parse-multiline-string suffix! ;
SYNTAX: [======[ "]======]" parse-multiline-string suffix! ;

SYNTAX: ![[ "]]" parse-multiline-string drop ;
SYNTAX: ![=[ "]=]" parse-multiline-string drop ;
SYNTAX: ![==[ "]==]" parse-multiline-string drop ;
SYNTAX: ![===[ "]===]" parse-multiline-string drop ;
SYNTAX: ![====[ "]====]" parse-multiline-string drop ;
SYNTAX: ![=====[ "]=====]" parse-multiline-string drop ;
SYNTAX: ![======[ "]======]" parse-multiline-string drop ;
