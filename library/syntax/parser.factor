! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: parser
USING: kernel lists namespaces sequences words ;

: parse-loop ( -- )
    scan-word [
        dup parsing? [ execute ] [ swons ] if  parse-loop
    ] when* ;

: (parse) ( str -- )
    line-text set 0 column set
    parse-loop
    line-text off column off ;

: parse ( str -- code )
    #! Parse the string into a parse tree that can be executed.
    [ f swap (parse) reverse ] with-parser ;

: eval ( "X" -- X ) parse call ;
