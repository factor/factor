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
    drop \ method get literalize , \ (call-next-method) , ;

M: object (fake-quotations>) , ;

: parse-definition* ( accum -- accum )
    parse-definition >fake-quotations suffix!
    [ fake-quotations> first ] append! ;

: parse-declared* ( accum -- accum )
    scan-effect
    [ parse-definition* ] dip
    suffix! ;

FUNCTOR-SYNTAX: TUPLE:
    scan-param suffix!
    scan-token {
        { ";" [ tuple suffix! f suffix! ] }
        { "<" [ scan-param suffix! [ parse-tuple-slots ] { } make suffix! ] }
        [
            [ tuple suffix! ] dip
            [ parse-slot-name [ parse-tuple-slots ] when ] { }
            make suffix!
        ]
    } case
    \ define-tuple-class* suffix! ;

FUNCTOR-SYNTAX: final
    [ last-word make-final ] append! ;

FUNCTOR-SYNTAX: SINGLETON:
    scan-param suffix!
    \ define-singleton-class suffix! ;

FUNCTOR-SYNTAX: MIXIN:
    scan-param suffix!
    \ define-mixin-class suffix! ;

FUNCTOR-SYNTAX: M:
    scan-param suffix!
    scan-param suffix!
    [ create-method-in dup \ method set ] append!
    parse-definition*
    \ define* suffix! ;

FUNCTOR-SYNTAX: C:
    scan-param suffix!
    scan-param suffix!
    scan-effect
    [ [ [ boa ] curry ] append! ] dip suffix!
    \ define-declared* suffix! ;

FUNCTOR-SYNTAX: :
    scan-param suffix!
    parse-declared*
    \ define-declared* suffix! ;

FUNCTOR-SYNTAX: SYMBOL:
    scan-param suffix!
    \ define-symbol suffix! ;

FUNCTOR-SYNTAX: SYNTAX:
    scan-param suffix!
    parse-definition*
    \ define-syntax suffix! ;

FUNCTOR-SYNTAX: INSTANCE:
    scan-param suffix!
    scan-param suffix!
    \ add-mixin-instance suffix! ;

FUNCTOR-SYNTAX: GENERIC:
    scan-param suffix!
    scan-effect suffix!
    \ define-simple-generic* suffix! ;

FUNCTOR-SYNTAX: MACRO:
    scan-param suffix!
    parse-declared*
    \ define-macro suffix! ;

FUNCTOR-SYNTAX: inline [ last-word make-inline ] append! ;

FUNCTOR-SYNTAX: call-next-method T{ fake-call-next-method } suffix! ;

: (INTERPOLATE) ( accum quot -- accum )
    [ scan-token interpolate-locals ] dip
    '[ _ with-string-writer @ ] suffix! ;

PRIVATE>

SYNTAX: IS [ parse-word ] (INTERPOLATE) ;

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

: (parse-bindings) ( end -- words )
    [ dup parse-binding dup ]
    [ first2 [ make-local ] dip 2array ]
    produce 2nip ;

: with-bindings ( quot -- words assoc )
    in-lambda? on H{ } make ; inline

: parse-bindings ( end -- words assoc )
    [
        building get use-words
        (parse-bindings)
        building get unuse-words
    ] with-bindings ;

: parse-functor-body ( -- form )
    push-functor-words
    "WHERE" parse-bindings
    [ [ swap <def> suffix ] { } assoc>map concat ]
    [ [ \ ;FUNCTOR parse-until >quotation ] ((parse-lambda)) ] bi*
    [ ] append-as
    pop-functor-words ;

: (FUNCTOR:) ( -- word def effect )
    scan-new-word [ parse-functor-body ] parse-locals-definition ;

PRIVATE>

SYNTAX: FUNCTOR: (FUNCTOR:) define-declared ;
