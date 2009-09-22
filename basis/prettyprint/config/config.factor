! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic assocs io kernel math
namespaces sequences strings vectors words
continuations ;
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
10 number-base set-global
