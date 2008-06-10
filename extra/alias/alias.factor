USING: words quotations kernel effects sequences parser ;
IN: alias

PREDICATE: alias < word "alias" word-prop ;

M: alias reset-word
    [ call-next-method ] [ f "alias" set-word-prop ] bi ;

M: alias stack-effect
    word-def first stack-effect ;

: define-alias ( new old -- )
    [ 1quotation define-inline ]
    [ drop t "alias" set-word-prop ] 2bi ;

: ALIAS: CREATE-WORD scan-word define-alias ; parsing
