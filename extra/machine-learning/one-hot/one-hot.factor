! Copyright (C) 2012 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays kernel math.statistics math.vectors sequences
sequences.extras ;
IN: machine-learning.one-hot

: one-hot ( indices features -- array )
    [ 1 ] 2dip
    [ length ] map
    [ cum-sum0 v+ ]
    [ nip sum 0 <array> ] 2bi [ set-nths ] keep ;
