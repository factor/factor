IN: help
USING: arrays kernel namespaces words ;

! Word help
M: word article-title word-name ;

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
