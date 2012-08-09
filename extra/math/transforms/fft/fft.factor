! Copyright (c) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel locals math math.constants math.functions
math.vectors sequences sequences.extras sequences.private ;
IN: math.transforms.fft

<PRIVATE

:: (slow-fft) ( seq inverse? -- seq' )
    seq length :> N
    inverse? 1 -1 ? 2pi * i* N / :> O
    N iota [| k |
        0 seq [ O k * * e^ * + ] each-index
        inverse? [ N / ] when
    ] map ; inline

:: (fft) ( seq inverse? -- seq' )
    seq length :> N
    N 1 = [ seq ] [
        inverse? 1 -1 ? 2pi * i* N / :> O
        N 2/ :> M
        seq even-indices inverse? (fft)
        seq odd-indices inverse? (fft)
        [ [ O * e^ * + inverse? [ 2 / ] when ] 2map-index ]
        [ [ O * e^ * - inverse? [ 2 / ] when ] 2map-index ]
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
