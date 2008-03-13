! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser sequences words ;
IN: symbols

: SYMBOLS:
    ";" parse-tokens [ create-in define-symbol ] each ;
    parsing
