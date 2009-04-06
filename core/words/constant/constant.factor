! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences words definitions quotations ;
IN: words.constant

PREDICATE: constant < word ( obj -- ? )
    def>> dup length 1 = [ first word? not ] [ drop f ] if ;

: define-constant ( word value -- )
    [ ] curry (( -- value )) define-inline ;

M: constant definer drop \ CONSTANT: f ;

M: constant definition def>> first literalize 1quotation ;