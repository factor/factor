! Copyright (C) 2007, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser kernel sequences words effects combinators assocs
definitions quotations namespaces memoize accessors arrays
compiler.units ;
IN: macros

<PRIVATE

! The macro expander is split off into its own word. This allows
! the optimizing compiler to optimize and check the stack effect
! of the expander, even though the actual macro word does not
! infer.

: real-macro-effect ( effect -- effect' )
    in>> { "quot" } <effect> ;

PREDICATE: macro-body < memoized "macro-owner" word-prop >boolean ;

: <macro-body> ( word quot effect -- macro-body )
    real-macro-effect
    [ name>> "( macro body: " " )" surround <uninterned-word> dup ] 2dip
    define-memoized ;

M: macro-body crossref? "forgotten" word-prop not ;

M: macro-body reset-word
    [ call-next-method ] [ "macro-body" remove-word-prop ] bi ;

M: macro-body where "macro-owner" word-prop where ;

: reset-macro ( word -- )
    [ "macro" word-prop forget ] [ f "macro" set-word-prop ] bi ;

PRIVATE>

: define-macro ( word quot effect -- )
    [ 2drop ] [ <macro-body> ] 3bi
    {
        [ "macro" set-word-prop ]
        [ swap "macro-owner" set-word-prop ]
        [ [ \ call [ ] 2sequence ] [ stack-effect ] bi define-declared ]
        [ drop changed-effect ]
    } 2cleave ;

SYNTAX: MACRO: (:) define-macro ;

PREDICATE: macro < word "macro" word-prop >boolean ;

M: macro make-inline cannot-be-inline ;

M: macro definer drop \ MACRO: \ ; ;

M: macro definition "macro" word-prop definition ;

M: macro subwords "macro" word-prop 1array ;

M: macro reset-word [ call-next-method ] [ reset-macro ] bi ;

M: macro forget* [ call-next-method ] [ reset-macro ] bi ;

M: macro always-bump-effect-counter? drop t ;
