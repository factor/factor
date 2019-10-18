! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences accessors definitions words ;
IN: words.symbol

PREDICATE: symbol < word ( obj -- ? )
    [ def>> ] [ [ ] curry ] bi sequence= ;

M: symbol definer drop \ SYMBOL: f ;

M: symbol definition drop f ;

: define-symbol ( word -- )
    dup [ ] curry (( -- value )) define-inline ;
