! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: alien
USING: arrays compiler compiler-backend errors generic
hashtables kernel kernel-internals libc lists math namespaces
parser sequences strings words ;

: <c-type> ( -- type )
    H{
        { "setter" [ "Cannot read struct fields with type" throw ] }
        { "getter" [ "Cannot write struct fields with type" throw ] }
        { "boxer" [ "boxer-function" get %box ] }
        { "unboxer" [ "unboxer-function" get %unbox ] }
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

: <c-array> ( size type -- c-ptr )
    global [ c-size * <byte-array> ] bind ;

: <c-object> ( type -- c-ptr ) 1 swap <c-array> ;

: <malloc-array> ( size type -- malloc-ptr )
    global [ c-size calloc ] bind check-ptr ;

: <malloc-object> ( type -- malloc-ptr ) 1 swap <malloc-array> ;

: <malloc-string> ( string -- alien )
    "\0" append dup length malloc check-ptr
    [ alien-address string>memory ] keep ;

: (typedef) ( old new -- ) c-types get [ >r get r> set ] bind ;

: define-pointer ( type -- ) "*" append "void*" swap (typedef) ;

: define-deref ( name vocab -- )
    >r dup "*" swap append r> create
    swap c-getter 0 swons define-compound ;

: (define-nth) ( word type quot -- )
    >r c-size [ rot * ] curry r> append define-compound ;

: define-nth ( name vocab -- )
    >r dup "-nth" append r> create
    swap dup c-getter (define-nth) ;

: define-set-nth ( name vocab -- )
    >r "set-" over "-nth" append3 r> create
    swap dup c-setter (define-nth) ;

: define-out ( name vocab -- )
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

: typedef ( old new -- )
    over "*" append over "*" append (typedef) (typedef) ;
