! Copyright (C) 2017 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions math.order math.vectors
sequences ;
IN: machine-learning.functions

: relu ( x -- x' ) 0 max ; inline

: relu6 ( x -- x' ) 0 6 clamp ; inline

: leaky-relu ( x a -- x' )
    over 0 < [ * ] [ drop ] if ; inline

! https://arxiv.org/pdf/1706.02515.pdf
: selu ( x a -- x' )
    over 0 < [ [ [ e^ ] dip * ] keep - ] [ drop ] if ; inline

: default-leaky-relu ( x -- x' )
    .01 leaky-relu ; inline

: vexp-sum ( seq -- seq' sum )
    [ e^ ] map dup sum ; inline

: softmax ( seq -- softmax )
    vexp-sum '[ _ /f ] map ; inline

: log-softmax ( seq -- softmax )
    vexp-sum '[ e^ _ * recip log ] map ;

: softmin ( seq -- softmin )
    vneg softmax ; inline

: stable-softmax ( seq -- softmax )
    dup maximum v-n softmax ; inline

: stable-log-softmax ( seq -- softmax )
    dup maximum v-n dup [ e^ ] map-sum log v-n ;
