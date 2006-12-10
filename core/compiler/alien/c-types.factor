! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
USING: arrays compiler errors generic
hashtables kernel kernel-internals libc math namespaces
parser sequences strings words ;

TUPLE: c-type
boxer prep unboxer
getter setter
reg-class size align ;

C: c-type ( -- type )
    T{ int-regs f } over set-c-type-reg-class ;

SYMBOL: c-types

TUPLE: no-c-type name ;
: no-c-type ( type -- * ) <no-c-type> throw ;

: c-type ( name -- type )
    dup c-types get hash [ ] [ no-c-type ] ?if ;

GENERIC: c-type-unbox ( n type -- )

M: c-type c-type-unbox
    dup c-type-reg-class swap c-type-unboxer %unbox ;

GENERIC: c-type-box ( n type -- )

M: c-type c-type-box
    dup c-type-reg-class swap c-type-boxer %box ;

: c-size ( name -- size ) c-type c-type-size ;

: c-getter ( name -- quot ) c-type c-type-getter ;

: c-setter ( name -- quot ) c-type c-type-setter ;

: <c-array> ( n type -- array )
    global [ c-size * <byte-array> ] bind ;

: <c-object> ( type -- array ) 1 swap <c-array> ;

: <malloc-array> ( n type -- alien )
    global [ c-size calloc ] bind check-ptr ;

: <malloc-object> ( type -- alien ) 1 swap <malloc-array> ;

: <malloc-string> ( string -- alien )
    0 add dup length malloc check-ptr
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
    >r "set-" over "-nth" 3append r> create
    swap dup c-setter (define-nth) ;

: define-out ( name vocab -- )
    over [ <c-object> tuck 0 ] over c-setter append swap
    >r >r constructor-word r> r> add* define-compound ;

: init-c-type ( name vocab -- )
    over define-pointer define-nth ;

: <primitive-type> ( getter setter width boxer unboxer -- type )
    <c-type>
    [ set-c-type-unboxer ] keep
    [ set-c-type-boxer ] keep
    [ set-c-type-size ] 2keep
    [ set-c-type-align ] keep
    [ set-c-type-setter ] keep
    [ set-c-type-getter ] keep ;

: define-c-type ( type name vocab -- )
    >r [ c-types get set-hash ] keep r>
    over define-pointer
    define-nth ;

: define-primitive-type ( getter setter width boxer unboxer name -- )
    >r <primitive-type> r> "alien"
    [ define-c-type ] 2keep
    [ define-deref ] 2keep
    [ define-set-nth ] 2keep
    define-out ;

: typedef ( old new -- )
    over "*" append over "*" append (typedef) (typedef) ;
