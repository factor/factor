! Copyright (C) 2017 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.smart fry kernel parser sequences
sequences.generalizations ;
IN: combinators.smart.syntax

SYNTAX: \quotation[ parse-quotation '[ _ [ ] output>sequence ] append! ;

! SYNTAX: \array[ parse-quotation '[ _ { } output>sequence ] append! ;
SYNTAX: \array[ parse-quotation '[ _ { } output>sequence ] call( -- a ) suffix! ;

SYNTAX: \vector[ parse-quotation '[ _ V{ } output>sequence ] call( -- a ) suffix! ;

SYNTAX: \assoc[ parse-quotation '[ _ { } output>assoc ] call( -- a ) suffix! ;

SYNTAX: \hashtable[ parse-quotation '[ _ H{ } output>assoc ] call( -- a ) suffix! ;

ERROR: wrong-number-of-outputs quot expected got ;
: check-outputs ( quot n -- quot )
    2dup [ outputs dup ] dip = [ 2drop ] [ wrong-number-of-outputs ] if ;

: 2suffix! ( seq obj1 obj2 -- seq ) [ suffix! ] dip suffix! ; inline
: 3suffix! ( seq obj1 obj2 obj3 -- seq ) [ 2suffix! ] dip suffix! ; inline
: 4suffix! ( seq obj1 obj2 obj3 obj4 -- seq ) [ 3suffix! ] dip suffix! ; inline
: 5suffix! ( seq obj1 obj2 obj3 obj4 obj5 -- seq ) [ 4suffix! ] dip suffix! ; inline

SYNTAX: \1[ parse-quotation 1 check-outputs '[ _ { } output>sequence 1 firstn ] call( -- a ) suffix! ; foldable
SYNTAX: \2[ parse-quotation 2 check-outputs '[ _ { } output>sequence 2 firstn ] call( -- a b ) 2suffix! ; foldable
SYNTAX: \3[ parse-quotation 3 check-outputs '[ _ { } output>sequence 3 firstn ] call( -- a b c ) 3suffix! ; foldable
SYNTAX: \4[ parse-quotation 4 check-outputs '[ _ { } output>sequence 4 firstn ] call( -- a b c d ) 4suffix! ; foldable
SYNTAX: \5[ parse-quotation 5 check-outputs '[ _ { } output>sequence 5 firstn ] call( -- a b c d e ) 5suffix! ; foldable
