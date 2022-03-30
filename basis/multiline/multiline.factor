! Copyright (C) 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel lexer locals make math
namespaces parser quotations sequences strings.parser
strings.parser.private words ;
IN: multiline

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
        change-column check-space
    ] "" make ;

: advance-same-line ( lexer text -- )
    length [ + ] curry change-column drop ;

PRIVATE>

: parse-multiline-string ( end-text -- str )
    lexer get 1 (parse-multiline-string) ;

SYNTAX: /* "*/" parse-multiline-string drop ;

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
