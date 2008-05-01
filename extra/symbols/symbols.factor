! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: parser sequences words kernel classes.singleton ;
IN: symbols

: SYMBOLS:
    ";" parse-tokens
    [ create-in dup reset-generic define-symbol ] each ;
    parsing

: SINGLETONS:
    ";" parse-tokens
    [ create-class-in dup save-location define-singleton-class ] each ;
    parsing
