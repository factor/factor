! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math math.functions kernel io io.styles prettyprint
combinators hints fry namespaces sequences ;
IN: benchmark.partial-sums

! Helper words
: summing-integers ( n quot -- y ) [ 0.0 ] [ iota ] [ ] tri* '[ 1 + @ + ] each ; inline
: summing-floats ( n quot -- y ) '[ >float @ ] summing-integers ; inline
: cube ( x -- y ) dup dup * * ; inline
: -1^ ( n -- -1/1 ) 2 mod 2 * 1 - ; inline

! The functions
: 2/3^k ( n -- y ) [ 2.0 3.0 / swap 1 - ^ ] summing-floats ; inline
: k^-0.5 ( n -- y ) [ -0.5 ^ ] summing-floats ; inline
: 1/k(k+1) ( n -- y ) [ dup 1 + * recip ] summing-floats ; inline
: flint-hills ( n -- y ) [ [ cube ] [ sin sq ] bi * recip ] summing-floats ; inline
: cookson-hills ( n -- y ) [ [ cube ] [ cos sq ] bi * recip ] summing-floats ; inline
: harmonic ( n -- y ) [ recip ] summing-floats ; inline
: riemann-zeta ( n -- y ) [ sq recip ] summing-floats ; inline
: alternating-harmonic ( n -- y ) [ [ -1^ ] keep /f ] summing-integers ; inline
: gregory ( n -- y ) [ [ -1^ ] [ 2.0 * 1 - ] bi / ] summing-integers ; inline

: partial-sums ( n -- results )
    [
        {
            [ 2/3^k                 \ 2/3^k                set ]
            [ k^-0.5                \ k^-0.5               set ]
            [ 1/k(k+1)              \ 1/k(k+1)             set ]
            [ flint-hills           \ flint-hills          set ]
            [ cookson-hills         \ cookson-hills        set ]
            [ harmonic              \ harmonic             set ]
            [ riemann-zeta          \ riemann-zeta         set ]
            [ alternating-harmonic  \ alternating-harmonic set ]
            [ gregory               \ gregory              set ]
        } cleave
    ] { } make-assoc ;

HINTS: partial-sums fixnum ;

: partial-sums-main ( -- )
    2500000 partial-sums simple-table. ;

MAIN: partial-sums-main
