! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: quotations effects accessors sequences words kernel definitions ;
IN: words.alias

PREDICATE: alias < word "alias" word-prop ;

: define-alias ( new old -- )
    [ [ 1quotation ] [ stack-effect ] bi define-inline ]
    [ drop t "alias" set-word-prop ] 2bi ;

M: alias reset-word
    [ call-next-method ] [ f "alias" set-word-prop ] bi ;

M: alias definer drop \ ALIAS: f ;

M: alias definition def>> first 1quotation ;