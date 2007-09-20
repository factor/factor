USING: math math.functions kernel sequences io io.styles
prettyprint words hints ;
IN: benchmark.partial-sums

: summing ( n quot -- y )
    [ + ] compose 0.0 -rot 1 -rot (each-integer) ; inline

: 2/3^k ( n -- y ) [ 2.0 3.0 / swap 1- ^ ] summing ;

HINTS: 2/3^k fixnum ;

: k^-0.5 ( n -- y ) [ -0.5 ^ ] summing ;

HINTS: k^-0.5 fixnum ;

: 1/k(k+1) ( n -- y ) [ dup 1+ * recip ] summing ;

HINTS: 1/k(k+1) fixnum ;

: cube ( x -- y ) dup dup * * ; inline

: flint-hills ( n -- y )
    [ dup cube swap sin sq * recip ] summing ;

HINTS: flint-hills fixnum ;

: cookson-hills ( n -- y )
    [ dup cube swap cos sq * recip ] summing ;

HINTS: cookson-hills fixnum ;

: harmonic ( n -- y ) [ recip ] summing ;

HINTS: harmonic fixnum ;

: riemann-zeta ( n -- y ) [ sq recip ] summing ;

HINTS: riemann-zeta fixnum ;

: -1^ 2 mod zero? 1 -1 ? ; inline

: alternating-harmonic ( n -- y ) [ dup -1^ swap / ] summing ;

HINTS: alternating-harmonic fixnum ;

: gregory ( n -- y ) [ dup -1^ swap 2 * 1- / ] summing ;

HINTS: gregory fixnum ;

: functions
    { 2/3^k k^-0.5 1/k(k+1) flint-hills cookson-hills harmonic riemann-zeta alternating-harmonic gregory } ;

: partial-sums ( n -- )
    standard-table-style [
        functions [
            [ tuck execute pprint-cell pprint-cell ] with-row
        ] curry* each
    ] tabular-output ;

: partial-sums-main 2500000 partial-sums ;

MAIN: partial-sums-main
