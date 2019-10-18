! Copyright (c) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel locals math math.constants math.functions
math.vectors sequences sequences.extras sequences.private ;
IN: math.transforms.fft

<PRIVATE

! Discrete Fourier Transform
:: (slow-fft) ( seq inverse? -- seq' )
    seq length :> N
    inverse? 1 -1 ? 2pi * i* N / N iota n*v :> omega
    N iota [| k |
        0 seq omega [ k * e^ * + ] 2each
        inverse? [ N / ] when
    ] map ; inline

! Cooley–Tukey Algorithm
:: (fft) ( seq inverse? -- seq' )
    seq length :> N
    N 1 = [ seq ] [
        seq even-indices inverse? (fft)
        seq odd-indices inverse? (fft)
        inverse? 1 -1 ? 2pi * i* N /
        [ * e^ * ] curry map-index!
        [ [ + inverse? [ 2 / ] when ] 2map ]
        [ [ - inverse? [ 2 / ] when ] 2map ]
        2bi append
    ] if ; inline recursive

PRIVATE>

ERROR: not-enough-data ;

: fft ( seq -- seq' )
    [ not-enough-data ] [
        f over length even? [ (fft) ] [ (slow-fft) ] if
    ] if-empty ;

: ifft ( seq -- seq' )
    [ not-enough-data ] [
        t over length even? [ (fft) ] [ (slow-fft) ] if
    ] if-empty ;

: correlate ( x y -- z )
    [ fft ] [ reverse fft ] bi* v* ifft ;
