! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser kernel sequences words effects
inference.transforms combinators assocs definitions quotations
namespaces memoize ;
IN: macros

: real-macro-effect ( word -- effect' )
    "declared-effect" word-prop effect-in 1 <effect> ;

: define-macro ( word definition -- )
    over "declared-effect" word-prop effect-in length >r
    2dup "macro" set-word-prop
    2dup over real-macro-effect memoize-quot [ call ] append define
    r> define-transform ;

: MACRO:
    (:) define-macro ; parsing

PREDICATE: macro < word "macro" word-prop >boolean ;

M: macro definer drop \ MACRO: \ ; ;

M: macro definition "macro" word-prop ;

: macro-expand ( ... word -- quot ) "macro" word-prop call ;

: n*quot ( n seq -- seq' ) <repetition> concat >quotation ;

: saver \ >r <repetition> >quotation ;

: restorer \ r> <repetition> >quotation ;
