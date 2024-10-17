! Copyright (C) 2024 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs compiler.units effects.parser
kernel lexer locals.parser locals.types parser quotations
sequences sequences.deep splitting vocabs.parser words ;

IN: locals.lazy

<PRIVATE

TUPLE: lazy token ;
C: <lazy> lazy

: all-lazy-names ( names -- names' )
    [ "!" tail? ] partition over [ "!" ?tail drop ] map 3append ;

: make-lazy-vars ( names -- words )
    [
        all-lazy-names [
            dup '[ _ <lazy> suffix! ] define-temp-syntax
        ] H{ } map>assoc
    ] with-compilation-unit ;

TUPLE: lazy-bind tokens ;
C: <lazy-bind> lazy-bind

SYNTAX: lazy-:>
    scan-token dup "(" = [ drop ")" parse-tokens ] [ 1array ] if
    [ make-lazy-vars update-locals ] [ <lazy-bind> suffix! ] bi ;

: parse-def ( names -- def )
    dup length 1 = [
        first parse-single-def
    ] [
        make-locals [ <multi-def> ] dip
    ] if update-locals ;

: replace-lazy-vars ( quot -- quot' )
    [
        dup lazy? [ token>> parse-word ] when
        dup lazy-bind? [ tokens>> parse-def ] when
    ] deep-map ;

PRIVATE>

SYNTAX: EMIT:
    scan-new-word scan-effect in>> make-lazy-vars
    \ lazy-:> ":>" pick set-at [ parse-definition ] with-words
    '[ _ replace-lazy-vars append! ] define-syntax ;

SYNTAX: EMIT*:
    scan-new-word scan-effect [
        in>> make-lazy-vars \ lazy-:> ":>" pick set-at
        [ parse-definition ] with-words
    ] [
        [ in>> [ <lazy> ] [ ] map-as ]
        [ out>> <lazy-bind> 1quotation ] bi surround
    ] bi '[ _ replace-lazy-vars append! ] define-syntax ;
