! Copyright (C) 2021 Bruno Arias
! See https://factorcode.org/license.txt for BSD license

USING: arrays continuations kernel quotations sequences ;
IN: continuations.extras

: with-datastacks ( seq quot -- seq )
    '[ dup _ with-datastack 2array ] map ;

: datastack-states ( stack quot -- stack seq )
    [ 1quotation [ with-datastack ] 2keep first 2array ] map ;
