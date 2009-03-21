! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser kernel sequences words effects combinators assocs
definitions quotations namespaces memoize accessors ;
IN: macros

<PRIVATE

: real-macro-effect ( effect -- effect' )
    in>> 1 <effect> ;

PRIVATE>

: define-macro ( word definition effect -- )
    real-macro-effect
    [ drop "macro" set-word-prop ]
    [ [ memoize-quot [ call ] append ] keep define-declared ]
    3bi ;

SYNTAX: MACRO: (:) define-macro ;

PREDICATE: macro < word "macro" word-prop >boolean ;

M: macro definer drop \ MACRO: \ ; ;

M: macro definition "macro" word-prop ;

M: macro reset-word
    [ call-next-method ] [ f "macro" set-word-prop ] bi ;
