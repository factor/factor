! Factor port of
! http://shootout.alioth.debian.org/gp4/benchmark.php?test=spectralnorm&lang=all
USING: float-arrays kernel math math.functions math.vectors
sequences sequences.private prettyprint words
hints locals ;
IN: benchmark.spectral-norm

:: inner-loop ( u n quot -- seq )
    n [| i |
        n 0.0 [| j |
            u i j quot call +
        ] reduce
    ] F{ } map-as ; inline

: eval-A ( i j -- n )
    [ >float ] bi@
    [ drop ] [ + [ ] [ 1 + ] bi * 0.5 * ] 2bi
    + 1 + recip ; inline

: (eval-A-times-u) ( u i j -- x )
    tuck [ swap nth-unsafe ] [ eval-A ] 2bi* * ; inline

: eval-A-times-u ( n u -- seq )
    [ (eval-A-times-u) ] inner-loop ; inline

: (eval-At-times-u) ( u i j -- x )
    tuck [ swap nth-unsafe ] [ swap eval-A ] 2bi* * ; inline

: eval-At-times-u ( u n -- seq )
    [ (eval-At-times-u) ] inner-loop ; inline

: eval-AtA-times-u ( u n -- seq )
    [ eval-A-times-u ] [ eval-At-times-u ] bi ; inline

:: u/v ( n -- u v )
    n 1.0 <float-array> dup
    10 [
        drop
        n eval-AtA-times-u
        [ n eval-AtA-times-u ] keep
    ] times ; inline

: spectral-norm ( n -- norm )
    u/v [ v. ] keep norm-sq /f sqrt ;

HINTS: spectral-norm fixnum ;

: spectral-norm-main ( -- )
    5500 spectral-norm . ;

MAIN: spectral-norm-main
