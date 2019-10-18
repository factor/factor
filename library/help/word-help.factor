IN: help
USING: arrays kernel namespaces prettyprint sequences words ;

M: word article-title "The " swap word-name " word" append3 ;

M: word article-name word-name ;

: word-help ( word -- )
    dup "help" word-prop [
        % drop
    ] [
        "predicating" word-prop [
            \ $predicate swap 2array ,
        ] when*
    ] if* ;

M: word article-content
    [
        \ $synopsis over 2array ,
        dup word-help
        \ $definition swap 2array ,
    ] { } make ;
