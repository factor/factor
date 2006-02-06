! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: alien
USING: arrays assembler compiler compiler-backend errors generic
hashtables kernel kernel-internals lists math namespaces parser
sequences sequences-internals strings words ;

: <c-type> ( -- type )
    H{
        { "setter" [ "Cannot read struct fields with type" throw ] }
        { "getter" [ "Cannot write struct fields with type" throw ] }
        { "boxer" [ "Cannot use type as a return value" throw ] }
        { "unboxer" [ "Cannot use type as a parameter" throw ] }
        { "reg-class" T{ int-regs f } }
        { "width" 0 }
    } clone ;

SYMBOL: c-types

: c-type ( name -- type )
    dup c-types get hash
    [ ] [ "No such C type: " swap append throw ] ?if ;

: c-size ( name -- size ) "width" swap c-type hash ;

: c-align ( name -- align ) "align" swap c-type hash ;

: c-getter ( name -- quot ) "getter" swap c-type hash ;

: c-setter ( name -- quot ) "setter" swap c-type hash ;

: define-c-type ( quot name -- )
    >r <c-type> [ swap bind ] keep r> c-types get set-hash ;
    inline

: <c-object> ( type -- c-ptr ) c-size <byte-array> ;

: <c-array> ( size type -- c-ptr ) c-size * <byte-array> ;

: define-pointer ( type -- )
    "void*" c-type swap "*" append c-types get set-hash ;

: define-deref ( name vocab -- )
    >r dup "*" swap append r> create
    swap c-getter 0 swons define-compound ;

: (define-nth) ( word type quot -- )
    >r c-size [ rot * ] cons r> append define-compound ;

: define-nth ( name vocab -- )
    #! Make a word foo-nth ( n alien -- displaced-alien ).
    >r dup "-nth" append r> create
    swap dup c-getter (define-nth) ;

: define-set-nth ( name vocab -- )
    #! Make a word set-foo-nth ( value n alien -- ).
    >r "set-" over "-nth" append3 r> create
    swap dup c-setter (define-nth) ;

: define-out ( name vocab -- )
    #! Out parameter constructor for integral types.
    over [ <c-object> tuck 0 ] over c-setter append
    >r >r constructor-word r> r> cons define-compound ;

: init-c-type ( name vocab -- )
    over define-pointer define-nth ;

: define-primitive-type ( quot name -- )
    [ define-c-type ] keep "alien"
    2dup init-c-type
    2dup define-deref
    2dup define-set-nth
    define-out ;

: (typedef) c-types get [ >r get r> set ] bind ;

: typedef ( old new -- )
    over "*" append over "*" append (typedef) (typedef) ;
