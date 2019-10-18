! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: alien
USING: arrays compiler errors generic
hashtables kernel kernel-internals libc math namespaces
parser sequences strings words ;

: <c-type> ( -- type )
    H{
        { "boxer" [ "boxer-function" get %box ] }
        { "unboxer" [ "unboxer-function" get %unbox ] }
        { "reg-class" T{ int-regs f } }
        { "width" 0 }
    } clone ;

SYMBOL: c-types

TUPLE: no-c-type name ;
: no-c-type ( type -- * ) <no-c-type> throw ;

: c-type ( name -- type )
    dup c-types get hash [ ] [ no-c-type ] ?if ;

: c-size ( name -- size ) "width" swap c-type hash ;

: c-align ( name -- align ) "align" swap c-type hash ;

: c-getter ( name -- quot ) "getter" swap c-type hash ;

: c-setter ( name -- quot ) "setter" swap c-type hash ;

: define-c-type ( quot name -- )
    >r <c-type> [ swap bind ] keep r> c-types get set-hash ;
    inline

: <c-array> ( n type -- array )
    global [ c-size * <byte-array> ] bind ;

: <c-object> ( type -- array ) 1 swap <c-array> ;

: <malloc-array> ( n type -- alien )
    global [ c-size calloc ] bind check-ptr ;

: <malloc-object> ( type -- alien ) 1 swap <malloc-array> ;

: <malloc-string> ( string -- alien )
    "\0" append dup length malloc check-ptr
    [ alien-address string>memory ] keep ;

: (typedef) ( old new -- ) c-types get [ >r get r> set ] bind ;

: define-pointer ( type -- ) "*" append "void*" swap (typedef) ;

: define-deref ( name vocab -- )
    >r dup "*" swap append r> create
    swap c-getter 0 add* define-compound ;

: (define-nth) ( word type quot -- )
    >r c-size [ rot * ] swap add* r> append define-compound ;

: define-nth ( name vocab -- )
    >r dup "-nth" append r> create
    swap dup c-getter (define-nth) ;

: define-set-nth ( name vocab -- )
    >r "set-" over "-nth" append3 r> create
    swap dup c-setter (define-nth) ;

: define-out ( name vocab -- )
    over [ <c-object> tuck 0 ] over c-setter append swap
    >r >r constructor-word r> r> add* define-compound ;

: init-c-type ( name vocab -- )
    over define-pointer define-nth ;

: (define-primitive-type) ( quot name -- )
    [ define-c-type ] keep "alien"
    2dup init-c-type
    2dup define-deref
    over c-setter [ 2dup define-set-nth define-out ] when ;

: define-primitive-type ( quot name -- )
    [ (define-primitive-type) ] keep dup c-setter
    [ "alien" 2dup define-set-nth define-out ] [ drop ] if ;

: typedef ( old new -- )
    over "*" append over "*" append (typedef) (typedef) ;
