! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: kernel lists math vectors words ;

! Catch-all metaclass for providing a default method.
SYMBOL: object

object [
    drop num-types count
] "builtin-supertypes" set-word-property

object [
    ( generic vtable definition class -- )
    drop over vector-length [
        3dup rot set-vector-nth
    ] repeat 3drop
] "add-method" set-word-property

object [ drop t ] "predicate" set-word-property

object 100 "priority" set-word-property

object [ 2drop t ] "class<" set-word-property

object object define-class
