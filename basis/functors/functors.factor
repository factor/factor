! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel locals.private quotations classes.tuple make
combinators generic words interpolate namespaces sequences
io.streams.string fry classes.mixin effects lexer parser
classes.tuple.parser effects.parser ;
IN: functors

: scan-param ( -- obj )
    scan-object dup special? [ literalize ] unless ;

: define* ( word def effect -- ) pick set-word define-declared ;

: DEFINE* ( -- ) effect get parsed \ define* parsed ;

: `TUPLE:
    scan-param parsed
    scan {
        { ";" [ tuple parsed f parsed ] }
        { "<" [ scan-param [ parse-tuple-slots ] { } make parsed ] }
        [
            [ tuple parsed ] dip
            [ parse-slot-name [ parse-tuple-slots ] when ] { }
            make parsed
        ]
    } case
    \ define-tuple-class parsed ; parsing

: `M:
    effect off
    scan-param parsed
    scan-param parsed
    \ create-method parsed
    parse-definition parsed
    DEFINE* ; parsing

: `C:
    effect off
    scan-param parsed
    scan-param parsed
    [ [ boa ] curry ] over push-all
    DEFINE* ; parsing

: `:
    effect off
    scan-param parsed
    parse-definition parsed
    DEFINE* ; parsing

: `INSTANCE:
    scan-param parsed
    scan-param parsed
    \ add-mixin-instance parsed ; parsing

: `inline \ inline parsed ; parsing

: `parsing \ parsing parsed ; parsing

: `(
    ")" parse-effect effect set ; parsing

: (INTERPOLATE) ( accum quot -- accum )
    [ scan interpolate-locals ] dip
    '[ _ with-string-writer @ ] parsed ;

: IS [ dup search [ ] [ no-word ] ?if ] (INTERPOLATE) ; parsing

: DEFINES [ in get create ] (INTERPOLATE) ; parsing

DEFER: ;FUNCTOR delimiter

: functor-words ( -- assoc )
    H{
        { "TUPLE:" POSTPONE: `TUPLE: }
        { "M:" POSTPONE: `M: }
        { "C:" POSTPONE: `C: }
        { ":" POSTPONE: `: }
        { "INSTANCE:" POSTPONE: `INSTANCE: }
        { "inline" POSTPONE: `inline }
        { "parsing" POSTPONE: `parsing }
        { "(" POSTPONE: `( }
    } ;

: push-functor-words ( -- )
    functor-words use get push ;

: pop-functor-words ( -- )
    functor-words use get delq ;

: parse-functor-body ( -- form )
    t in-lambda? [
        V{ } clone
        push-functor-words
        "WHERE" parse-bindings* \ ;FUNCTOR (parse-lambda)
        <let*> parsed-lambda
        pop-functor-words
        >quotation
    ] with-variable ;

: (FUNCTOR:) ( -- word def )
    CREATE
    parse-locals
    parse-functor-body swap pop-locals <lambda>
    lambda-rewrite first ;

: FUNCTOR: (FUNCTOR:) define ; parsing

: APPLY: scan-word scan-word execute swap '[ _ execute ] each ; parsing
