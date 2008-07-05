! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: parser lexer sequences words kernel classes.singleton
classes.parser ;
IN: symbols

: SYMBOLS:
    ";" parse-tokens
    [ create-in dup reset-generic define-symbol ] each ;
    parsing

: SINGLETONS:
    ";" parse-tokens
    [ create-class-in define-singleton-class ] each ;
    parsing
