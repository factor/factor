! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: prettyprint
USING: arrays generic hashtables io kernel math namespaces
sequences styles words ;

PREDICATE: array method-spec
    dup length 2 = [
        first2 generic? >r class? r> and
    ] [
        drop f
    ] if ;

GENERIC: (synopsis) ( spec -- )

: write-vocab ( vocab -- )
    dup <vocab-link> presented associate styled-text ;

: in. ( word -- )
    word-vocabulary [
        H{ } <block \ IN: pprint-word write-vocab block;
    ] when* ;

M: word (synopsis)
    dup in. dup definer pprint-word pprint-word ;

M: method-spec (synopsis)
    \ M: pprint-word [ pprint-word ] each ;

: comment. ( comment -- )
    [ H{ { font-style italic } } [ text ] with-style ] when* ;

: stack-picture ( seq -- string )
    [ [ % CHAR: \s , ] each ] "" make ;

: effect>string ( effect -- string )
    [
        "( " %
        dup first stack-picture %
        "-- " %
        second stack-picture %
        ")" %
    ] "" make ;

: stack-effect ( word -- string )
    dup "stack-effect" word-prop [ ] [
        "infer-effect" word-prop dup [
            [
                dup integer? [ object <array> ] when
                [ word-name ] map
            ] map effect>string
        ] when
    ] ?if ;

: synopsis ( word -- string )
    [
        0 margin set [
            dup (synopsis) stack-effect comment.
        ] with-pprint
    ] string-out ;
