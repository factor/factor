! Copyright (C) 2006, 2008 Slava Pestov, Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.strings arrays assocs
combinators compiler hashtables kernel libc math namespaces
parser sequences words cocoa.messages cocoa.runtime locals
compiler.units io.encodings.utf8 continuations make fry ;
IN: cocoa.subclassing

: init-method ( method -- sel imp types )
    first3 swap
    [ sel_registerName ] [ execute ] [ utf8 string>alien ]
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

: (define-objc-class) ( imeth protocols superclass name -- )
    [ objc-class ] dip 0 objc_allocateClassPair
    [ add-protocols ] [ add-methods ] [ objc_registerClassPair ]
    tri ;

: encode-types ( return types -- encoding )
    swap prefix [
        alien>objc-types get at "0" append
    ] map concat ;

: prepare-method ( ret types quot -- type imp )
    [ [ encode-types ] 2keep ] dip
    '[ _ _ "cdecl" _ alien-callback ]
    (( -- callback )) define-temp ;

: prepare-methods ( methods -- methods )
    [
        [ first4 prepare-method 3array ] map
    ] with-compilation-unit ;

:: (redefine-objc-method) ( class method -- )
    method init-method [| sel imp types |
        class sel class_getInstanceMethod [
            imp method_setImplementation drop
        ] [
            class sel imp types add-method
        ] if*
    ] call ;
    
: redefine-objc-methods ( imeth name -- )
    dup class-exists? [
        objc_getClass '[ [ _ ] dip (redefine-objc-method) ] each
    ] [ 2drop ] if ;

SYMBOL: +name+
SYMBOL: +protocols+
SYMBOL: +superclass+

: define-objc-class ( imeth hash -- )
    clone [
        prepare-methods
        +name+ get "cocoa.classes" create drop
        +name+ get 2dup redefine-objc-methods swap
        +protocols+ get +superclass+ get +name+ get
        '[ _ _ _ _ (define-objc-class) ]
        import-objc-class
    ] bind ;

: CLASS:
    parse-definition unclip
    >hashtable define-objc-class ; parsing
