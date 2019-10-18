! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: kernel lists math vectors words ;

! Catch-all metaclass for providing a default method.
SYMBOL: object

object [
    drop num-types count
] "builtin-supertypes" set-word-prop

object [
    ( generic vtable definition class -- )
    drop over vector-length [
        3dup rot set-vector-nth
    ] repeat 3drop
] "add-method" set-word-prop

object [ drop t ] "predicate" set-word-prop

object 100 "priority" set-word-prop

object [ 2drop t ] "class<" set-word-prop

object object define-class
