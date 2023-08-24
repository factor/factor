! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: definitions kernel words ;
IN: words.constant

PREDICATE: constant < word "constant" word-prop >boolean ;

: define-constant ( word value -- )
    [ drop t "constant" set-word-prop ]
    [ [ ] curry ( -- value ) define-inline ] 2bi ;

M: constant reset-word
    [ call-next-method ] [ "constant" remove-word-prop ] bi ;

M: constant definer drop \ CONSTANT: f ;
