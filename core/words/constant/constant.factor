! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: definitions kernel quotations words ;
IN: words.constant

PREDICATE: constant < word "constant" word-prop >boolean ;

: define-constant ( word value -- )
    [ "constant" set-word-prop ]
    [ [ ] curry ( -- value ) define-inline ] 2bi ;

M: constant reset-word
    [ call-next-method ] [ f "constant" set-word-prop ] bi ;

M: constant definer drop \ CONSTANT: f ;

M: constant definition "constant" word-prop literalize 1quotation ;
