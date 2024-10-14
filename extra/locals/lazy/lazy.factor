! Copyright (C) 2024 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors assocs compiler.units effects.parser kernel
parser sequences sequences.deep vocabs.parser words ;

IN: locals.lazy

<PRIVATE

TUPLE: lazy token ;

C: <lazy> lazy

: make-lazy-vars ( names -- words )
    [ dup '[ _ <lazy> suffix! ] define-temp-syntax ] H{ } map>assoc ;

: replace-lazy-vars ( quot -- quot' )
    [ dup lazy? [ token>> parse-word ] when ] deep-map ;

PRIVATE>

SYNTAX: EMIT:
    scan-new-word scan-effect in>>
    [ make-lazy-vars ] with-compilation-unit
    [ parse-definition ] with-words
    '[ _ replace-lazy-vars append! ] define-syntax ;
