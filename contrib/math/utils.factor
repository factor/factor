IN: math-contrib
USING: errors kernel sequences math ;

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
