! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors definitions kernel sequences words ;
IN: words.symbol

PREDICATE: symbol < word
    [ def>> ] [ [ ] curry ] bi sequence= ;

M: symbol definer drop \ SYMBOL: f ;

M: symbol definition drop f ;

: define-symbol ( word -- )
    dup [ ] curry ( -- value ) define-inline ;
