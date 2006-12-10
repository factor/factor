! Copyright (C) 2003, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: prettyprint
USING: alien arrays generic hashtables io kernel math
namespaces parser sequences strings styles vectors words
prettyprint-internals ;

: with-pprint ( quot -- )
    [
        V{ } clone recursion-check set
        H{ } <flow> f ?push pprinter-stack set
        call end-blocks do-pprint
    ] with-scope ; inline

: pprint ( obj -- ) [ pprint* ] with-pprint ;

: . ( obj -- )
    H{
       { length-limit 1000 }
       { nesting-limit 10 }
    } clone [ pprint ] bind terpri ;

: unparse ( obj -- str ) [ pprint ] string-out ;

: pprint-short ( obj -- )
    H{
       { line-limit 1 }
       { length-limit 15 }
       { nesting-limit 2 }
       { string-limit t }
    } clone [ pprint ] bind ;

: short. ( obj -- ) pprint-short terpri ;

: unparse-short ( obj -- str ) [ pprint-short ] string-out ;

: .b ( n -- ) >bin print ;
: .o ( n -- ) >oct print ;
: .h ( n -- ) >hex print ;

GENERIC: summary ( object -- string )

M: object summary
    "an instance of the " swap class word-name " class" 3append ;

M: input summary
    "Input: " swap input-string dup string?
    [ "\n" split1 "..." "" ? append ] [ unparse-short ] if
    append ;

M: vocab-link summary
    [
        vocab-link-name dup %
        " vocabulary (" %
        words length #
        " words)" %
    ] "" make ;
