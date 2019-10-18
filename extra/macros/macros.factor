! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser kernel sequences words effects
inference.transforms combinators assocs definitions quotations
namespaces ;
IN: macros

: (:)
    CREATE dup reset-generic parse-definition
    over "declared-effect" word-prop effect-in length ;

: (MACRO:)
    >r
    2dup "macro" set-word-prop
    2dup [ call ] append define-compound
    r> define-transform ;

: MACRO:
    (:) (MACRO:) ; parsing

PREDICATE: word macro
    "macro" word-prop >boolean ;

M: macro definer drop \ MACRO: \ ; ;

M: macro definition "macro" word-prop ;

: macro-expand ( ... word -- quot )
    "macro" word-prop call ;

: short-circuit ( quots quot default -- quot )
    >r { } map>assoc <reversed> r>
    1quotation swap alist>quot ;

MACRO: && ( quots -- ? )
    [ [ not ] append [ f ] ] t short-circuit ;

MACRO: || ( quots -- ? )
    [ [ t ] ] f short-circuit ;

: n*quot ( n seq -- seq' ) <repetition> concat >quotation ;

: saver \ >r <repetition> >quotation ;

: restorer \ r> <repetition> >quotation ;
