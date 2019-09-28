! Copyright (C) 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel lexer make math namespaces sequences ;
IN: multiline

<PRIVATE

:: (scan-multiline-string) ( i end lexer -- j )
    lexer line-text>> :> text
    lexer still-parsing? [
        end text i subseq-start-from |[ j |
            i j text subseq % j end length +
        ] [
            text i shorted tail % char: \n ,
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

PRIVATE>

: parse-multiline-string ( end-text -- str )
    lexer get 1 (parse-multiline-string) ;

: parse-multiline-string0 ( end-text -- str )
    lexer get 0 (parse-multiline-string) ;
