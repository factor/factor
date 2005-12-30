! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sequences-internals
USING: errors kernel kernel-internals math math-internals
sequences ;

GENERIC: underlying
GENERIC: set-underlying
GENERIC: set-fill

: capacity underlying length ; inline
: expand [ underlying resize ] keep set-underlying ;
: new-size 3 * dup 50 < [ drop 50 ] when ;
: ensure
    2dup length >= [
        >r 1+ r>
        2dup capacity > [ over new-size over expand ] when
        2dup set-fill
    ] when 2drop ;
TUPLE: bounds-error index seq ;
: bounds-error <bounds-error> throw ;
: growable-check over 0 < [ bounds-error ] when ; inline
: bounds-check
    2dup bounds-check? [ bounds-error ] unless ; inline
: grow-length
    growable-check 2dup capacity >
    [ 2dup expand ] when set-fill ;
: clone-growable
    (clone) dup underlying clone over set-underlying ;
