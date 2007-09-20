! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: classes classes.union words kernel sequences ;
IN: classes.mixin

PREDICATE: union-class mixin-class "mixin" word-prop ;

M: mixin-class reset-class
    { "metaclass" "members" "mixin" } reset-props ;

: redefine-mixin-class ( class members -- )
    dupd define-union-class
    t "mixin" set-word-prop ;

: define-mixin-class ( class -- )
    dup mixin-class? [
        drop
    ] [
        { } redefine-mixin-class
    ] if ;

: add-mixin-instance ( class mixin -- )
    dup mixin-class? [ "Not a mixin class" throw ] unless
    2dup members memq? [
        2drop
    ] [
        [ members swap bootstrap-word add ] keep swap
        redefine-mixin-class
    ] if ;
