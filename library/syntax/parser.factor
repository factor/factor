! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: parser
USING: kernel lists namespaces words ;

: parse-loop ( -- )
    scan-word [
        dup parsing? [ execute ] [ swons ] ifte  parse-loop
    ] when* ;

: (parse) ( str -- )
    "line" set 0 "col" set
    parse-loop
    "line" off "col" off ;

: parse ( str -- code )
    #! Parse the string into a parse tree that can be executed.
    [ f swap (parse) reverse ] with-parser ;

: eval ( "X" -- X ) parse call ;
