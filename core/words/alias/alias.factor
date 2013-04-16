! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors definitions effects kernel quotations
sequences words ;
IN: words.alias

PREDICATE: alias < word "alias" word-prop ;

: define-alias ( new old -- )
    [ [ 1quotation ] [ stack-effect ] bi define-inline ]
    [ drop t "alias" set-word-prop ]
    [ parsing-word? [ t "parsing" set-word-prop ] [ drop ] if ] 2tri ;

M: alias reset-word
    [ call-next-method ] [ f "alias" set-word-prop ] bi ;

M: alias definer drop \ ALIAS: f ;
