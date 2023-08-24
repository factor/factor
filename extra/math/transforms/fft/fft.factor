! Copyright (c) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.constants math.functions
math.vectors sequences sequences.extras ;
IN: math.transforms.fft

<PRIVATE

DEFER: (fft)

! Discrete Fourier Transform
:: (slow-fft) ( seq inverse? -- seq' )
    seq length :> N
    inverse? 1 -1 ? 2pi * N / N <iota> n*v :> omega
    N <iota> [| k |
        0 seq omega [ k * cis * + ] 2each
        inverse? [ N / ] when
    ] map ; inline

! Cooley–Tukey Algorithm
:: (fast-fft) ( seq inverse? -- seq' )
    seq length :> N
    N 1 = [ seq ] [
        seq even-indices inverse? (fast-fft)
        seq odd-indices inverse? (fast-fft)
        inverse? 1 -1 ? 2pi * N /
        [ * cis * ] curry map-index!
        [ [ + inverse? [ 2 / ] when ] 2map ]
        [ [ - inverse? [ 2 / ] when ] 2map ]
        2bi append
    ] if ; inline recursive

: (fft) ( seq inverse? -- seq' )
    over length power-of-2?
    [ (fast-fft) ] [ (slow-fft) ] if ; inline

PRIVATE>

ERROR: not-enough-data ;

: fft ( seq -- seq' )
    [ not-enough-data ] [ f (fft) ] if-empty ;

: ifft ( seq -- seq' )
    [ not-enough-data ] [ t (fft) ] if-empty ;

: correlate ( x y -- z )
    [ fft ] [ reverse fft ] bi* v* ifft ;
