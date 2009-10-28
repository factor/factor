! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes.mixin classes.parser
classes.singleton classes.tuple classes.tuple.parser
combinators effects.parser fry functors.backend generic
generic.parser interpolate io.streams.string kernel lexer
locals.parser locals.types macros make namespaces parser
quotations sequences vocabs.parser words words.symbol ;
IN: functors

! This is a hack

<PRIVATE

TUPLE: fake-call-next-method ;

TUPLE: fake-quotation seq ;

GENERIC: >fake-quotations ( quot -- fake )

M: callable >fake-quotations
    >array >fake-quotations fake-quotation boa ;

M: array >fake-quotations [ >fake-quotations ] { } map-as ;

M: object >fake-quotations ;

GENERIC: (fake-quotations>) ( fake -- )

: fake-quotations> ( fake -- quot )
    [ (fake-quotations>) ] [ ] make ;

M: fake-quotation (fake-quotations>)
    [ seq>> [ (fake-quotations>) ] each ] [ ] make , ;

M: array (fake-quotations>)
    [ [ (fake-quotations>) ] each ] { } make , ;

M: fake-call-next-method (fake-quotations>)
    drop method-body get literalize , \ (call-next-method) , ;

M: object (fake-quotations>) , ;

: parse-definition* ( accum -- accum )
    parse-definition >fake-quotations parsed
    [ fake-quotations> first ] over push-all ;

: parse-declared* ( accum -- accum )
    complete-effect
    [ parse-definition* ] dip
    parsed ;

FUNCTOR-SYNTAX: TUPLE:
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

FUNCTOR-SYNTAX: SINGLETON:
    scan-param parsed
    \ define-singleton-class parsed ;

FUNCTOR-SYNTAX: MIXIN:
    scan-param parsed
    \ define-mixin-class parsed ;

FUNCTOR-SYNTAX: M:
    scan-param parsed
    scan-param parsed
    [ create-method-in dup method-body set ] over push-all
    parse-definition*
    \ define* parsed ;

FUNCTOR-SYNTAX: C:
    scan-param parsed
    scan-param parsed
    complete-effect
    [ [ [ boa ] curry ] over push-all ] dip parsed
    \ define-declared* parsed ;

FUNCTOR-SYNTAX: :
    scan-param parsed
    parse-declared*
    \ define-declared* parsed ;

FUNCTOR-SYNTAX: SYMBOL:
    scan-param parsed
    \ define-symbol parsed ;

FUNCTOR-SYNTAX: SYNTAX:
    scan-param parsed
    parse-definition*
    \ define-syntax parsed ;

FUNCTOR-SYNTAX: INSTANCE:
    scan-param parsed
    scan-param parsed
    \ add-mixin-instance parsed ;

FUNCTOR-SYNTAX: GENERIC:
    scan-param parsed
    complete-effect parsed
    \ define-simple-generic* parsed ;

FUNCTOR-SYNTAX: MACRO:
    scan-param parsed
    parse-declared*
    \ define-macro parsed ;

FUNCTOR-SYNTAX: inline [ word make-inline ] over push-all ;

FUNCTOR-SYNTAX: call-next-method T{ fake-call-next-method } parsed ;

: (INTERPOLATE) ( accum quot -- accum )
    [ scan interpolate-locals ] dip
    '[ _ with-string-writer @ ] parsed ;

PRIVATE>

SYNTAX: IS [ dup search [ ] [ no-word ] ?if ] (INTERPOLATE) ;

SYNTAX: DEFERS [ current-vocab create ] (INTERPOLATE) ;

SYNTAX: DEFINES [ create-in ] (INTERPOLATE) ;

SYNTAX: DEFINES-PRIVATE [ begin-private create-in end-private ] (INTERPOLATE) ;

SYNTAX: DEFINES-CLASS [ create-class-in ] (INTERPOLATE) ;

DEFER: ;FUNCTOR delimiter

<PRIVATE

: push-functor-words ( -- )
    functor-words use-words ;

: pop-functor-words ( -- )
    functor-words unuse-words ;

: (parse-bindings) ( end -- )
    dup parse-binding dup [
        first2 [ make-local ] dip 2array ,
        (parse-bindings)
    ] [ 2drop ] if ;

: with-bindings ( quot -- words assoc )
    '[
        in-lambda? on
        _ H{ } make-assoc
    ] { } make swap ; inline

: parse-bindings ( end -- words assoc )
    [
        namespace use-words
        (parse-bindings)
        namespace unuse-words
    ] with-bindings ;

: parse-functor-body ( -- form )
    push-functor-words
    "WHERE" parse-bindings
    [ [ swap <def> suffix ] { } assoc>map concat ]
    [ [ \ ;FUNCTOR parse-until >quotation ] ((parse-lambda)) ] bi*
    [ ] append-as
    pop-functor-words ;

: (FUNCTOR:) ( -- word def effect )
    CREATE-WORD [ parse-functor-body ] parse-locals-definition ;

PRIVATE>

SYNTAX: FUNCTOR: (FUNCTOR:) define-declared ;
