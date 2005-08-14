! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: kernel lists math sequences vectors words ;

! Catch-all metaclass for providing a default method.
SYMBOL: object

object [
    drop num-types >list
] "builtin-supertypes" set-word-prop

object [
    ( generic vtable definition class -- )
    drop over length [
        3dup rot set-nth
    ] repeat 3drop
] "add-method" set-word-prop

object [ drop t ] "predicate" set-word-prop

object object define-class
