! This file will go away very shortly!

IN: arithmetic
USE: combinators
USE: kernel
USE: logic
USE: stack

: integer? dup fixnum? swap bignum? or ;

: max ( x y -- z )
    2dup > [ drop ] [ nip ] ifte ;

: min ( x y -- z )
    2dup < [ drop ] [ nip ] ifte ;

: between? ( x min max -- ? )
    #! Push if min <= x <= max.
    >r dupd max r> min = ;

: pred 1 - ; inline
: succ 1 + ; inline

: neg 0 swap - ; inline
