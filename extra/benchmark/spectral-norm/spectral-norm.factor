! Factor port of
! http://shootout.alioth.debian.org/gp4/benchmark.php?test=spectralnorm&lang=all
USING: float-arrays kernel math math.functions math.vectors
sequences sequences.private prettyprint words tools.time hints ;
IN: benchmark.spectral-norm

: fast-truncate >fixnum >float ; inline

: eval-A ( i j -- n )
    [ >float ] 2apply
    dupd + dup 1+ * 2 /f fast-truncate + 1+
    recip ; inline

: (eval-A-times-u) ( u i j -- x )
    tuck eval-A >r swap nth-unsafe r> * ; inline

: eval-A-times-u ( n u -- seq )
    over [
        pick 0.0 [
            swap >r >r 2dup r> (eval-A-times-u) r> +
        ] reduce nip
    ] F{ } map-as 2nip ; inline

: (eval-At-times-u) ( u i j -- x )
    tuck swap eval-A >r swap nth-unsafe r> * ; inline

: eval-At-times-u ( n u -- seq )
    over [
        pick 0.0 [
            swap >r >r 2dup r> (eval-At-times-u) r> +
        ] reduce nip
    ] F{ } map-as 2nip ; inline

: eval-AtA-times-u ( n u -- seq )
    dupd eval-A-times-u eval-At-times-u ; inline

: u/v ( n -- u v )
    dup 1.0 <float-array> dup
    10 [
        drop
        dupd eval-AtA-times-u
        2dup eval-AtA-times-u
        swap
    ] times
    rot drop ; inline

: spectral-norm ( n -- norm )
    u/v [ v. ] keep norm-sq /f sqrt ;

HINTS: spectral-norm fixnum ;

: spectral-norm-main ( n -- )
    2000 spectral-norm . ;

MAIN: spectral-norm-main
