! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: objc
USING: alien kernel kernel-internals libc math sequences ;

: <method-lists> ( -- lists )
    "void*" <malloc-object> -1 over 0 set-alien-unsigned-cell ;

: <objc-class> ( name info -- class )
    "objc-class" <malloc-object>
    [ set-objc-class-info ] keep
    [ >r <malloc-string> r> set-objc-class-name ] keep
    <method-lists> over set-objc-class-methodLists ;

! Every class has a metaclass.

! The superclass of the metaclass of X is the metaclass of the
! superclass of X.

! The metaclass of the metaclass of X is the metaclass of the
! root class of X.
: meta-meta-class ( class -- class ) root-class objc-class-isa ;

: <meta-class> ( superclass name -- class )
    CLS_META <objc-class>
    [ >r dup objc-class-isa r> set-objc-class-super-class ] keep
    [ >r meta-meta-class r> set-objc-class-isa ] keep ;

: <new-class> ( metaclass superclass name -- class )
    CLS_CLASS <objc-class>
    [ set-objc-class-super-class ] keep
    [ set-objc-class-isa ] keep ;

: (define-objc-class) ( superclass name -- class )
    >r objc-class r> [ <meta-class> ] 2keep <new-class>
    dup objc_addClass ;

: define-objc-class ( superclass name -- class )
    dup class-exists?
    [ nip objc-class ] [ (define-objc-class) ] if ;
