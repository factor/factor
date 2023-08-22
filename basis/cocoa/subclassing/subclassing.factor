! Copyright (C) 2006, 2010 Slava Pestov, Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.parser alien.strings arrays assocs
cocoa.messages cocoa.runtime combinators compiler.units
io.encodings.utf8 kernel lexer locals.parser locals.types
make namespaces parser sequences words ;
IN: cocoa.subclassing

: init-method ( method -- sel imp types )
    first3 swap
    [ sel_registerName ] [ execute( -- xt ) ] [ utf8 string>alien ]
    tri* ;

: throw-if-false ( obj what -- )
    swap { f 0 } member?
    [ "Failed to " prepend throw ] [ drop ] if ;

: add-method ( class sel imp types -- )
    class_addMethod "add method to class" throw-if-false ;

: add-methods ( methods class -- )
    '[ [ _ ] dip init-method add-method ] each ;

: add-protocol ( class protocol -- )
    class_addProtocol "add protocol to class" throw-if-false ;

: add-protocols ( protocols class -- )
    '[ [ _ ] dip objc-protocol add-protocol ] each ;

: (define-objc-class) ( methods protocols superclass name -- )
    [ objc-class ] dip 0 objc_allocateClassPair
    [ add-protocols ] [ add-methods ] [ objc_registerClassPair ]
    tri ;

: encode-type ( type -- encoded )
    [ alien>objc-types get at ] [ no-objc-type ] ?unless ;

: encode-types ( return types -- encoding )
    swap prefix [ encode-type "0" append ] map concat ;

: prepare-method ( ret types quot -- type imp )
    [ [ encode-types ] 2keep ] dip
    '[ _ _ cdecl _ alien-callback ]
    ( -- callback ) define-temp ;

: prepare-methods ( methods -- methods )
    [
        [ first4 prepare-method 3array ] map
    ] with-nested-compilation-unit ;

:: (redefine-objc-method) ( class method -- )
    method init-method :> ( sel imp types )

    class sel class_getInstanceMethod [
        imp method_setImplementation drop
    ] [
        class sel imp types add-method
    ] if* ;

: redefine-objc-methods ( methods name -- )
    dup class-exists? [
        objc_getClass '[ [ _ ] dip (redefine-objc-method) ] each
    ] [ 2drop ] if ;

:: define-objc-class ( name superclass protocols methods -- )
    methods prepare-methods :> methods
    name "cocoa.classes" create-word drop
    methods name redefine-objc-methods
    name [ methods protocols superclass name (define-objc-class) ] import-objc-class ;

TUPLE: cocoa-protocol name ;
C: <cocoa-protocol> cocoa-protocol

SYNTAX: COCOA-PROTOCOL:
    scan-token <cocoa-protocol> suffix! ;

SYMBOL: ;CLASS>

SYNTAX: <CLASS:
    scan-token
    "<" expect
    scan-token
    \ ;CLASS> parse-until [ cocoa-protocol? ] partition
    [ [ name>> ] map ] dip define-objc-class ;

: (parse-selector) ( -- )
    scan-token {
        { [ dup "[" = ] [ drop ] }
        { [ dup ":" tail? ] [ scan-c-type scan-token 3array , (parse-selector) ] }
        [ f f 3array , "[" expect ]
    } cond ;

: parse-selector ( -- selector types names )
    [ (parse-selector) ] { } make
    flip first3
    [ concat ]
    [ sift { id SEL } prepend ]
    [ sift { "self" "selector" } prepend ] tri* ;

: parse-method-body ( names -- quot )
    [ [ make-local ] map ] H{ } make
    (parse-lambda) <lambda> ?rewrite-closures first ;

SYNTAX: METHOD:
    scan-c-type
    parse-selector
    parse-method-body [ swap ] 2dip 4array ";" expect
    suffix! ;
