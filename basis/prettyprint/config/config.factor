! Copyright (C) 2003, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces ;
IN: prettyprint.config

! Configuration
SYMBOL: tab-size
SYMBOL: margin
SYMBOL: nesting-limit
SYMBOL: length-limit
SYMBOL: line-limit
SYMBOL: number-base
SYMBOL: string-limit?
SYMBOL: boa-tuples?
SYMBOL: c-object-pointers?

4 tab-size set-global
64 margin set-global
15 nesting-limit set-global
100 length-limit set-global
10 number-base set-global
string-limit? on

: with-short-limits ( quot -- )
    [
        1 line-limit set
        15 length-limit set
        2 nesting-limit set
        string-limit? on
        boa-tuples? on
        c-object-pointers? on
        call
    ] with-scope ; inline

: without-limits ( quot -- )
    [
        nesting-limit off
        length-limit off
        line-limit off
        string-limit? off
        c-object-pointers? off
        call
    ] with-scope ; inline
