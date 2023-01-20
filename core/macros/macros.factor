! Copyright (C) 2007, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators compiler.units definitions effects
kernel memoize words ;
IN: macros

<PRIVATE

: real-macro-effect ( effect -- effect' )
    in>> { "quot" } <effect> ;

: check-macro-effect ( word effect -- )
    [ real-macro-effect ] keep 2dup effect=
    [ 3drop ] [ bad-stack-effect ] if ;

PRIVATE>

: define-macro ( word definition effect -- )
    {
        [ nip check-macro-effect ]
        [
            [ '[ _ _ call-effect ] ] keep
            [ memoize-quot '[ @ call ] ] keep
            define-declared
        ]
        [ drop "macro" set-word-prop ]
        [ 2drop changed-effect ]
    } 3cleave ;

PREDICATE: macro < word "macro" word-prop >boolean ;

M: macro make-inline cannot-be-inline ;

M: macro definer drop \ MACRO: \ ; ;

M: macro definition "macro" word-prop ;

M: macro reset-word
    [ call-next-method ] [ "macro" remove-word-prop ] bi ;

M: macro always-bump-effect-counter? drop t ;
