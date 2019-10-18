USING: kernel math errors math-contrib ;
IN: crypto

! As per http://www.cyphercalc.com/index.htm
:  montgomery-image ( a n -- a' )
    #! a' = a * nextpowerof2(a) mod n
    >r dup next-power-of-2 * r> mod ;

! : montgomery* ( a b -- a*b )
    ! "todo" throw ;

: montgomery-r^2 ( n -- a )
    #! ans = r^2 mod n, where r = nextpowerof2(n)
    [ next-power-of-2 sq ] keep mod ;

: montgomery-n0' ( n0 size -- n0' )
    #! size should be a multiple of 2, n0 is odd and n0 < 2^size
    #! n0 * n0' = -1 mod 2^w
    2 swap ^ swap neg mod-inv ;

