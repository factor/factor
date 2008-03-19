! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: parser sequences words kernel ;
IN: symbols

: SYMBOLS:
    ";" parse-tokens
    [ create-in dup reset-generic define-symbol ] each ;
    parsing
