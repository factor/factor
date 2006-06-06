! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help
USING: arrays kernel namespaces prettyprint sequences words ;

M: word article-title
    dup word-name swap stack-effect [ " " swap append3 ] when* ;

: word-article ( word -- article ) "help" word-prop ;

: word-help ( word -- article )
    [
        \ $synopsis over 2array ,
        dup word-article [
            %
        ] [
            "predicating" word-prop [
                \ $predicate swap 2array ,
            ] when*
        ] ?if
    ] { } make ;

M: word article-content
    dup word-help { $definition } rot add add ;
