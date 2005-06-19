! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: test
USING: errors inference kernel lists namespaces prettyprint
io strings unparser ;

: try-infer ( quot -- effect error )
    [ infer f ] [ [ >r drop f r> ] when* ] catch ;

: infer-fail ( quot error -- )
    "! " , dup string? [ unparse ] unless , "\n" ,
    [ [ infer ] cons . \ unit-test-fails . ] with-string , ;

: infer-pass ( quot effect -- )
    [ unit . [ infer ] cons . \ unit-test . ] with-string , ;

: infer>test ( quot -- str )
    #! Make a string representing a unit test for the stack
    #! effect of a word.
    [
        dup try-infer [ infer-fail ] [ infer-pass ] ?ifte
    ] make-string ;

: infer>test. ( word -- )
    #! Print a inference unit test for a word.
    infer>test write ;
