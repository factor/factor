! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: errors hashtables kernel lists namespaces parser
sequences strings words vectors ;

! Union metaclass for dispatch on multiple classes.
SYMBOL: union

: union-predicate ( members -- list )
    [
        "predicate" word-prop
        [ dup ] swap add [ drop t ] cons
    ] map [ drop f ] swap alist>quot ;

: set-members ( class members -- )
    2dup [ types ] map concat "types" set-word-prop
    "members" set-word-prop ;

: define-union ( class predicate members -- )
    #! We have to turn the f object into the f word, same for t.
    3dup nip set-members pick union define-class
    union-predicate define-predicate ;

PREDICATE: word union metaclass union = ;
