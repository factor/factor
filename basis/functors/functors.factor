! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes.mixin classes.parser
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
    parse-definition >fake-quotations suffix!
    [ fake-quotations> first ] append! ;

: parse-declared* ( accum -- accum )
    complete-effect
    [ parse-definition* ] dip
    suffix! ;

FUNCTOR-SYNTAX: TUPLE:
    scan-param suffix!
    scan {
        { ";" [ tuple suffix! f suffix! ] }
        { "<" [ scan-param suffix! [ parse-tuple-slots ] { } make suffix! ] }
        [
            [ tuple suffix! ] dip
            [ parse-slot-name [ parse-tuple-slots ] when ] { }
            make suffix!
        ]
    } case
    \ define-tuple-class suffix! ;

FUNCTOR-SYNTAX: SINGLETON:
    scan-param suffix!
    \ define-singleton-class suffix! ;

FUNCTOR-SYNTAX: MIXIN:
    scan-param suffix!
    \ define-mixin-class suffix! ;

FUNCTOR-SYNTAX: M:
    scan-param suffix!
    scan-param suffix!
    [ create-method-in dup method-body set ] append! 
    parse-definition*
    \ define* suffix! ;

FUNCTOR-SYNTAX: C:
    scan-param suffix!
    scan-param suffix!
    complete-effect
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
    complete-effect suffix!
    \ define-simple-generic* suffix! ;

FUNCTOR-SYNTAX: MACRO:
    scan-param suffix!
    parse-declared*
    \ define-macro suffix! ;

FUNCTOR-SYNTAX: inline [ word make-inline ] append! ;

FUNCTOR-SYNTAX: call-next-method T{ fake-call-next-method } suffix! ;

: (INTERPOLATE) ( accum quot -- accum )
    [ scan interpolate-locals ] dip
    '[ _ with-string-writer @ ] suffix! ;

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

: parse-functor-body ( -- form )
    push-functor-words
    "WHERE" parse-bindings*
    [ \ ;FUNCTOR parse-until >quotation ] ((parse-lambda)) <let*> 1quotation
    pop-functor-words ;

: (FUNCTOR:) ( -- word def effect )
    CREATE-WORD [ parse-functor-body ] parse-locals-definition ;

PRIVATE>

SYNTAX: FUNCTOR: (FUNCTOR:) define-declared ;
