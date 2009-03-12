! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel quotations classes.tuple make combinators generic
words interpolate namespaces sequences io.streams.string fry
classes.mixin effects lexer parser classes.tuple.parser
effects.parser locals.types locals.parser generic.parser
locals.rewrite.closures vocabs.parser classes.parser
arrays accessors ;
IN: functors

! This is a hack

<PRIVATE

: scan-param ( -- obj ) scan-object literalize ;

: define* ( word def effect -- ) pick set-word define-declared ;

TUPLE: fake-quotation seq ;

GENERIC: >fake-quotations ( quot -- fake )

M: callable >fake-quotations
    >array >fake-quotations fake-quotation boa ;

M: array >fake-quotations [ >fake-quotations ] { } map-as ;

M: object >fake-quotations ;

GENERIC: fake-quotations> ( fake -- quot )

M: fake-quotation fake-quotations>
    seq>> [ fake-quotations> ] [ ] map-as ;

M: array fake-quotations> [ fake-quotations> ] map ;

M: object fake-quotations> ;

: parse-definition* ( -- )
    parse-definition >fake-quotations parsed \ fake-quotations> parsed ;

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
    \ create-method-in parsed
    parse-definition*
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
    parse-definition*
    DEFINE* ; parsing

: `INSTANCE:
    scan-param parsed
    scan-param parsed
    \ add-mixin-instance parsed ; parsing

: `inline [ word make-inline ] over push-all ; parsing

: `parsing [ word make-parsing ] over push-all ; parsing

: `(
    ")" parse-effect effect set ; parsing

: (INTERPOLATE) ( accum quot -- accum )
    [ scan interpolate-locals ] dip
    '[ _ with-string-writer @ ] parsed ;

PRIVATE>

: IS [ dup search [ ] [ no-word ] ?if ] (INTERPOLATE) ; parsing

: DEFINES [ create-in ] (INTERPOLATE) ; parsing

: DEFINES-CLASS [ create-class-in ] (INTERPOLATE) ; parsing

DEFER: ;FUNCTOR delimiter

<PRIVATE

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
    push-functor-words
    "WHERE" parse-bindings*
    [ \ ;FUNCTOR parse-until >quotation ] ((parse-lambda)) <let*> 1quotation
    pop-functor-words ;

: (FUNCTOR:) ( -- word def )
    CREATE-WORD [ parse-functor-body ] parse-locals-definition ;

PRIVATE>

: FUNCTOR: (FUNCTOR:) define ; parsing
