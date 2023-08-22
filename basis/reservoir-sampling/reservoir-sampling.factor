! Copyright (C) 2020 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math math.functions random sequences ;
IN: reservoir-sampling

: reservoir-sample-iteration ( iteration k obj sampled -- sampled' )
    pick over length > [
        [ push ] keep 2nip
    ] [
        roll random roll dupd < [
            swap [ set-nth ] keep
        ] [
           drop nip
        ] if
    ] if ;

TUPLE: reservoir-sampler iteration k sampled ;
: <reservoir-sampler> ( k -- sampler )
    reservoir-sampler new
        V{ } clone >>sampled
        0 >>iteration
        swap >>k ; inline

: reservoir-sample ( obj sampler -- )
    [ sampled>> length ] [ k>> ] [ [ 1 + ] change-iteration -rot ] tri < [
        sampled>> push
    ] [
        [ ] [ iteration>> random dup ] [ k>> ] tri < [
            swap sampled>> set-nth
        ] [
            3drop
        ] if
    ] if ;

