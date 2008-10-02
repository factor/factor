! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel parser words sequences quotations ;
IN: values

! Mutating literals in word definitions is not really allowed,
! and the deploy tool takes advantage of this fact to perform
! some aggressive stripping and compression. However, this
! breaks a naive implementation of values. We need to do two
! things:
! 1) Store the value in a subclass of identity-tuple, so that
! two quotations from different value words are never equal.
! This avoids bogus merging of values.
! 2) Set the "no-def-strip" word-prop, so that the shaker leaves
! the def>> slot alone, allowing us to introspect it. Otherwise,
! it will get set to [ ] and we would lose access to the
! value-holder.

<PRIVATE

TUPLE: value-holder < identity-tuple obj ;

PRIVATE>

: VALUE:
    CREATE-WORD
    dup t "no-def-strip" set-word-prop
    T{ value-holder } clone [ obj>> ] curry
    (( -- value )) define-declared ; parsing

: set-value ( value word -- )
    def>> first (>>obj) ;

: to:
    scan-word literalize parsed
    \ set-value parsed ; parsing

: get-value ( word -- value )
    def>> first obj>> ;

: change-value ( word quot -- )
    [ [ get-value ] dip call ] [ drop ] 2bi set-value ; inline
