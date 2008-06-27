! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sets namespaces sequences inspector parser
lexer combinators words classes.parser classes.tuple ;
IN: classes.tuple.parser

: shadowed-slots ( superclass slots -- shadowed )
    >r all-slot-names r> intersect ;

: check-slot-shadowing ( class superclass slots -- )
    shadowed-slots [
        [
            "Definition of slot ``" %
            %
            "'' in class ``" %
            word-name %
            "'' shadows a superclass slot" %
        ] "" make note.
    ] with each ;

ERROR: invalid-slot-name name ;

M: invalid-slot-name summary
    drop
    "Invalid slot name" ;

: (parse-tuple-slots) ( -- )
    #! This isn't meant to enforce any kind of policy, just
    #! to check for mistakes of this form:
    #!
    #! TUPLE: blahblah foo bing
    #!
    #! : ...
    scan {
        { [ dup not ] [ unexpected-eof ] }
        { [ dup { ":" "(" "<" } member? ] [ invalid-slot-name ] }
        { [ dup ";" = ] [ drop ] }
        [ , (parse-tuple-slots) ]
    } cond ;

: parse-tuple-slots ( -- seq )
    [ (parse-tuple-slots) ] { } make ;

: parse-tuple-definition ( -- class superclass slots )
    CREATE-CLASS
    scan {
        { ";" [ tuple f ] }
        { "<" [ scan-word parse-tuple-slots ] }
        [ >r tuple parse-tuple-slots r> prefix ]
    } case 3dup check-slot-shadowing ;
