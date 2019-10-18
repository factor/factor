! Factor port of
! http://shootout.alioth.debian.org/gp4/benchmark.php?test=spectralnorm&lang=all

IN: spectral-norm
USING: arrays kernel math sequences sequences-internals
prettyprint words tools ;

: eval-A ( i j -- n )
    [ >float ] 2apply
    dupd + dup 1+ * 2 /f truncate + 1+
    recip ; inline

: (eval-A-times-u) ( u i j -- x )
    tuck eval-A >r swap nth-unsafe r> * ; inline

: eval-A-times-u ( n u -- seq )
    over [
        pick 0.0 [
            swap >r >r 2dup r> (eval-A-times-u) r> +
        ] reduce nip
    ] map 2nip ; inline

: (eval-At-times-u) ( u i j -- x )
    tuck swap eval-A >r swap nth-unsafe r> * ; inline

: eval-At-times-u ( n u -- seq )
    over [
        pick 0.0 [
            swap >r >r 2dup r> (eval-At-times-u) r> +
        ] reduce nip
    ] map 2nip ; inline

: eval-AtA-times-u ( n u -- seq )
    dupd eval-A-times-u eval-At-times-u ; inline

: u/v ( n -- u v )
    dup 1.0 <array> f
    10 [
        drop
        dupd eval-AtA-times-u
        2dup eval-AtA-times-u
        swap
    ] times
    rot drop ; inline

: spectral-norm ( n -- norm )
    u/v [ v. ] keep norm-sq /f sqrt ;

\ spectral-norm { fixnum } "specializer" set-word-prop

[ 2000 spectral-norm . ] time
