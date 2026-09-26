! Copyright (c) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.
USING: kernel locals math math.constants math.functions
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
    seq even-indices inverse? (fft) :> evens
    seq odd-indices inverse? (fft) :> odds
    inverse? 1 -1 ? 2pi * N / :> angle
    N 2/ :> half
    N evens [| output |
        evens [| even k |
            k odds nth k angle * cis * :> odd
            even odd + inverse? [ 2 / ] when k output set-nth
            even odd - inverse? [ 2 / ] when k half + output set-nth
        ] each-index
        output
    ] new-like ; inline

: (fft) ( seq inverse? -- seq' )
    over length 1 = [ drop ] [
        over length even?
        [ (fast-fft) ] [ (slow-fft) ] if
    ] if ; inline recursive

PRIVATE>

ERROR: not-enough-data ;

: fft ( seq -- seq' )
    [ not-enough-data ] [ f (fft) ] if-empty ;

: ifft ( seq -- seq' )
    [ not-enough-data ] [ t (fft) ] if-empty ;

: correlate ( x y -- z )
    [ fft ] [ reverse fft ] bi* v* ifft ;
