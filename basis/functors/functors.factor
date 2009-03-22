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

: define* ( word def -- ) over set-word define ;

: define-declared* ( word def effect -- ) pick set-word define-declared ;

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

: parse-definition* ( accum -- accum )
    parse-definition >fake-quotations parsed \ fake-quotations> parsed ;

: parse-declared* ( accum -- accum )
    complete-effect
    [ parse-definition* ] dip
    parsed ;

: DEFINE* ( accum -- accum ) \ define-declared* parsed ;

SYNTAX: `TUPLE:
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
    \ define-tuple-class parsed ;

SYNTAX: `M:
    scan-param parsed
    scan-param parsed
    \ create-method-in parsed
    parse-definition*
    \ define* parsed ;

SYNTAX: `C:
    scan-param parsed
    scan-param parsed
    complete-effect
    [ [ [ boa ] curry ] over push-all ] dip parsed
    \ define-declared* parsed ;

SYNTAX: `:
    scan-param parsed
    parse-declared*
    \ define-declared* parsed ;

SYNTAX: `SYNTAX:
    scan-param parsed
    parse-definition*
    \ define-syntax parsed ;

SYNTAX: `INSTANCE:
    scan-param parsed
    scan-param parsed
    \ add-mixin-instance parsed ;

SYNTAX: `inline [ word make-inline ] over push-all ;

: (INTERPOLATE) ( accum quot -- accum )
    [ scan interpolate-locals ] dip
    '[ _ with-string-writer @ ] parsed ;

PRIVATE>

SYNTAX: IS [ dup search [ ] [ no-word ] ?if ] (INTERPOLATE) ;

SYNTAX: DEFINES [ create-in ] (INTERPOLATE) ;

SYNTAX: DEFINES-CLASS [ create-class-in ] (INTERPOLATE) ;

DEFER: ;FUNCTOR delimiter

<PRIVATE

: functor-words ( -- assoc )
    H{
        { "TUPLE:" POSTPONE: `TUPLE: }
        { "M:" POSTPONE: `M: }
        { "C:" POSTPONE: `C: }
        { ":" POSTPONE: `: }
        { "INSTANCE:" POSTPONE: `INSTANCE: }
        { "SYNTAX:" POSTPONE: `SYNTAX: }
        { "inline" POSTPONE: `inline }
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

: (FUNCTOR:) ( -- word def effect )
    CREATE-WORD [ parse-functor-body ] parse-locals-definition ;

PRIVATE>

SYNTAX: FUNCTOR: (FUNCTOR:) define-declared ;
