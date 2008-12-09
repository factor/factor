! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel quotations classes.tuple make combinators generic
words interpolate namespaces sequences io.streams.string fry
classes.mixin effects lexer parser classes.tuple.parser
effects.parser locals.types locals.parser locals.rewrite.closures ;
IN: functors

: scan-param ( -- obj )
    scan-object dup special? [ literalize ] unless ;

: define* ( word def effect -- ) pick set-word define-declared ;

: DEFINE* ( accum -- accum ) effect get parsed \ define* parsed ;

: `TUPLE:
    scan-param parsed
    scan {
        { ";" [ tuple parsed f parsed ] }
        { "<" [ scan-param parsed [ parse-tuple-slots ] { } make parsed ] }
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

: DEFINES [ create-in ] (INTERPOLATE) ; parsing

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
    parse-locals dup push-locals
    parse-functor-body swap pop-locals <lambda>
    rewrite-closures first ;

: FUNCTOR: (FUNCTOR:) define ; parsing
