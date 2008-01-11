! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.

USING: parser kernel sequences words effects inference.transforms
combinators assocs definitions quotations namespaces memoize ;

IN: macros

: (:) ( -- word definition effect-in )
    CREATE dup reset-generic parse-definition
    over "declared-effect" word-prop effect-in length ;

: real-macro-effect ( word -- effect' )
    "declared-effect" word-prop effect-in 1 <effect> ;

: (MACRO:) ( word definition effect-in -- )
    >r 2dup "macro" set-word-prop
    2dup over real-macro-effect memoize-quot
    [ call ] append define
    r> define-transform ;

: MACRO:
    (:) (MACRO:) ; parsing

PREDICATE: word macro "macro" word-prop >boolean ;

M: macro definer drop \ MACRO: \ ; ;

M: macro definition "macro" word-prop ;

: macro-expand ( ... word -- quot ) "macro" word-prop call ;

: n*quot ( n seq -- seq' ) <repetition> concat >quotation ;

: saver \ >r <repetition> >quotation ;

: restorer \ r> <repetition> >quotation ;
