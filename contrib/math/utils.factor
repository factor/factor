IN: math-contrib
USING: errors kernel sequences math sequences-internals ;

: deg>rad pi * 180 / ; inline
: rad>deg 180 * pi / ; inline

: lcm ( a b -- c )
    #! Smallest integer such that c/a and c/b are both integers.
    2dup gcd nip >r * r> /i ; foldable

: mod-inv ( x n -- y )
    #! Compute the multiplicative inverse of x mod n.
    gcd 1 = [ "Non-trivial divisor found" throw ] unless ;
    foldable

: (^mod) ( n z w -- z^w )
    1 swap [
        1 number= [ dupd * pick mod ] when >r sq over mod r>
    ] each-bit 2nip ; inline

: ^mod ( z w n -- z^w )
    #! Compute z^w mod n.
    over 0 < [
        [ >r neg r> ^mod ] keep mod-inv
    ] [
        -rot (^mod)
    ] if ; foldable

: ** ( u v -- u*v' ) conjugate * ; inline

: c. ( v v -- x )
    #! Complex inner product.
    0 [ ** + ] 2reduce ;

TUPLE: frange from step length ;

C: frange ( from step to -- seq )
    #! example: 0 .01 10 <frange> >array
    >r pick - swap [ / ] keep -rot swapd >fixnum 1+ r> 
    [ set-frange-length ] keep
    [ set-frange-step ] keep
    [ set-frange-from ] keep ;

M: frange length ( frange -- n )
    frange-length ;

: decrement-length ( frange -- )
    [ frange-length 1- ] keep set-frange-length ;

: increment-start ( frange -- )
    [ [ frange-from ] keep frange-step + ] keep set-frange-from ;

: frange-range ( frange -- range )
    [ frange-step ] keep frange-length 1- * ;

M: frange nth ( n frange -- obj ) [ frange-step * ] keep frange-from + ;
M: frange nth-unsafe ( n frange -- obj ) nth ;


