! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser kernel sequences words effects combinators assocs
definitions quotations namespaces memoize accessors ;
IN: macros

<PRIVATE

: real-macro-effect ( word -- effect' )
    "declared-effect" word-prop in>> 1 <effect> ;

PRIVATE>

: define-macro ( word definition -- )
    [ "macro" set-word-prop ]
    [ over real-macro-effect memoize-quot [ call ] append define ]
    2bi ;

: MACRO: (:) define-macro ; parsing

PREDICATE: macro < word "macro" word-prop >boolean ;

M: macro definer drop \ MACRO: \ ; ;

M: macro definition "macro" word-prop ;

M: macro reset-word
    [ call-next-method ] [ f "macro" set-word-prop ] bi ;
