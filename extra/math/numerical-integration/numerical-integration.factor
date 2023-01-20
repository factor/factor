! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math ranges math.vectors namespaces
sequences ;
IN: math.numerical-integration

SYMBOL: num-steps

180 num-steps set-global

: setup-simpson-range ( from to -- frange )
    2dup swap - num-steps get / <range> ;

: generate-simpson-weights ( seq -- seq )
    length 1 + 2/ 2 - { 2 4 } <repetition> concat
    { 1 4 } { 1 } surround ;

: integrate-simpson ( from to quot -- x )
    [ setup-simpson-range dup ] dip
    map dup generate-simpson-weights
    vdot swap [ third ] keep first - 6 / * ; inline
