! Copyright (C) 2009, 2010, 2011 Joe Groff, Slava Pestov, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes classes.algebra classes.tuple
classes.struct combinators combinators.short-circuit definitions
effects effects.parser fry generalizations kernel kernel.private
locals.parser quotations sequences slots stack-checker.dependencies
words ;
FROM: classes.tuple.private => tuple-layout ;
IN: typed

ERROR: type-mismatch-error value expected-type word expected-types ;
ERROR: input-mismatch-error < type-mismatch-error ;
ERROR: output-mismatch-error < type-mismatch-error ;
ERROR: no-types-specified word effect ;

PREDICATE: typed-gensym < word "typed-gensym" word-prop >boolean ;
PREDICATE: typed-word < word "typed-word" word-prop >boolean ;

<PRIVATE

: unboxable-tuple-class? ( type -- ? )
    {
        [ only-classoid? not ]
        [ all-slots empty? not ]
        [ immutable-tuple-class? ]
        [ final-class? ]
        [ struct-class? not ] ! for struct boa change
    } 1&& ;

! typed inputs

: typed-stack-effect? ( effect -- ? )
    [ object = ] all? not ;

: add-depends-on-unboxing ( class -- )
    [ dup tuple-layout add-depends-on-tuple-layout ]
    [ add-depends-on-final ]
    bi ;

: (unboxer) ( type -- quot )
    dup unboxable-tuple-class? [
        dup add-depends-on-unboxing
        all-slots [
            [ name>> reader-word 1quotation ]
            [ class>> (unboxer) ] bi compose
        ] map [ cleave ] curry
    ] [ drop [ ] ] if ;

:: unboxer ( error-quot word types type -- quot )
    type word? [ type "coercer" word-prop ] [ f ] if [ ] or
    type type word types error-quot '[ dup _ instance? [ _ _ _ @ ] unless ]
    type (unboxer)
    compose compose ;

: make-unboxer ( error-quot word types -- quot )
    dup [ unboxer ] 3 nwith
    [ swap \ dip [ ] 2sequence prepend ] map-reduce ;

: (unboxed-types) ( type -- types )
    dup unboxable-tuple-class?
    [
        dup add-depends-on-unboxing
        all-slots [ class>> (unboxed-types) ] map concat
    ]
    [ 1array ] if ;

: unboxed-types ( types -- types' )
    [ (unboxed-types) ] map concat ;

:: typed-inputs ( quot word types -- quot' )
    types unboxed-types :> unboxed-types

    [ input-mismatch-error ] word types make-unboxer
    unboxed-types quot '[ _ declare @ ]
    compose ;

! typed outputs

:: typed-outputs ( quot word types -- quot' )
    [ output-mismatch-error ] word types make-unboxer
    quot prepose ;

DEFER: make-boxer

: boxer ( type -- quot )
    dup unboxable-tuple-class?
    [
        dup add-depends-on-unboxing
        [ all-slots [ class>> ] map make-boxer ]
        [ [ boa ] curry ]
        bi compose
    ]
    [ drop [ ] ] if ;

: make-boxer ( types -- quot )
    [ [ ] ]
    [ [ boxer ] [ swap '[ @ _ dip ] ] map-reduce ] if-empty ;

! defining typed words

MACRO: (typed) ( word def effect -- quot )
    swapd
    [
        nip effect-in-types swap
        [ [ unboxed-types ] [ make-boxer ] bi ] dip
        '[ _ declare @ @ ]
    ]
    [
        effect-out-types
        dup typed-stack-effect? [ typed-outputs ] [ 2drop ] if
    ] 2bi ;

: <typed-gensym> ( parent-word -- word )
    [ name>> "( typed " " )" surround f <word> dup ]
    [ "typed-gensym" set-word-prop ] bi ;

: unboxed-effect ( effect -- effect' )
    [ effect-in-types unboxed-types [ "in" swap 2array ] map ]
    [ effect-out-types unboxed-types [ "out" swap 2array ] map ] bi <effect> ;

M: typed-gensym stack-effect call-next-method unboxed-effect ;
M: typed-gensym parent-word "typed-gensym" word-prop ;
M: typed-gensym crossref? parent-word crossref? ;
M: typed-gensym where parent-word where ;

: define-typed-gensym ( word def effect -- gensym )
    [ 2drop <typed-gensym> dup ]
    [ [ (typed) ] 3curry ]
    [ 2nip ] 3tri define-declared ;

MACRO: typed ( quot word effect -- quot' )
    [ effect-in-types dup typed-stack-effect? [ typed-inputs ] [ 2drop ] if ]
    [
        nip effect-out-types dup typed-stack-effect?
        [ [ unboxed-types ] [ make-boxer ] bi '[ @ _ declare @ ] ] [ drop ] if
    ] 2bi ;

: (typed-def) ( word def effect -- quot )
    [ define-typed-gensym ] 3keep
    [ drop [ swap "typed-word" set-word-prop ] [ [ 1quotation ] dip ] 2bi ] dip
    [ typed ] 3curry ;

: typed-def? ( effect -- quot )
    {
        [ effect-in-types typed-stack-effect? ]
        [ effect-out-types typed-stack-effect? ]
    } 1|| ;

: typed-def ( word def effect -- quot )
    dup typed-def?
    [ (typed-def) ] [ nip no-types-specified ] if ;

M: typed-word subwords
    [ call-next-method ]
    [ "typed-word" word-prop ] bi suffix ;

PRIVATE>

: define-typed ( word def effect -- )
    [ [ 2drop ] [ typed-def ] [ 2nip ] 3tri define-inline ]
    [ drop "typed-def" set-word-prop ]
    [ 2drop "typed-word" word-prop set-last-word ] 3tri ;

SYNTAX: TYPED:
    (:) define-typed ;
SYNTAX: TYPED::
    (::) define-typed ;

USE: vocabs.loader

{ "typed" "prettyprint" } "typed.prettyprint" require-when
{ "typed" "compiler.cfg.debugger" } "typed.debugger" require-when
