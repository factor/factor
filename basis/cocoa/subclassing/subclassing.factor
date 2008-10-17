! Copyright (C) 2006, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.strings arrays assocs
combinators compiler hashtables kernel libc math namespaces
parser sequences words cocoa.messages cocoa.runtime
compiler.units io.encodings.ascii generalizations
continuations make ;
IN: cocoa.subclassing

: init-method ( method -- sel imp types )
    first3 swap
    [ sel_registerName ] [ execute ] [ ascii string>alien ]
    tri* ;

: throw-if-false ( YES/NO -- )
    zero? [ "Failed to add method or protocol to class" throw ]
    when ;

: add-methods ( methods class -- )
    swap
    [ init-method class_addMethod throw-if-false ] with each ;

: add-protocols ( protocols class -- )
    swap [ objc-protocol class_addProtocol throw-if-false ]
    with each ;

: (define-objc-class) ( protocols superclass name imeth -- )
    -rot
    [ objc-class ] dip 0 objc_allocateClassPair
    [ add-methods ] [ add-protocols ] [ objc_registerClassPair ]
    tri ;

: encode-types ( return types -- encoding )
    swap prefix [
        alien>objc-types get at "0" append
    ] map concat ;

: prepare-method ( ret types quot -- type imp )
    >r [ encode-types ] 2keep r> [
        "cdecl" swap 4array % \ alien-callback ,
    ] [ ] make define-temp ;

: prepare-methods ( methods -- methods )
    [
        [ first4 prepare-method 3array ] map
    ] with-compilation-unit ;

: types= ( a b -- ? )
    [ ascii alien>string ] bi@ = ;

: (verify-method-type) ( class sel types -- )
    [ class_getInstanceMethod method_getTypeEncoding ]
    dip types=
    [ "Objective-C method types cannot be changed once defined" throw ]
    unless ;
: verify-method-type ( class sel imp types -- class sel imp types )
    4 ndup nip (verify-method-type) ;

: (redefine-objc-method) ( class method -- )
    init-method ! verify-method-type
    drop
    [ class_getInstanceMethod ] dip method_setImplementation drop ;
    
: redefine-objc-methods ( imeth name -- )
    dup class-exists? [
        objc_getClass swap [ (redefine-objc-method) ] with each
    ] [
        2drop
    ] if ;

SYMBOL: +name+
SYMBOL: +protocols+
SYMBOL: +superclass+

: define-objc-class ( imeth hash -- )
    clone [
        prepare-methods
        +name+ get "cocoa.classes" create drop
        +name+ get 2dup redefine-objc-methods swap [
            +protocols+ get , +superclass+ get , +name+ get , ,
            \ (define-objc-class) ,
        ] [ ] make import-objc-class
    ] bind ;

: CLASS:
    parse-definition unclip
    >hashtable define-objc-class ; parsing
