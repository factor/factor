! Copyright (C) 2012 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel math math.statistics math.vectors sequences
sequences.extras ;
IN: machine-learning.one-hot

ERROR: one-hot-length-mismatch vcategories vinput ;

ERROR: one-hot-input-out-of-bounds vcategories vinput ;

: check-one-hot-length ( vcateories vinput -- vcategories vinput )
    2dup [
        [ length ] bi@ = [ one-hot-length-mismatch ] unless
    ] [
        v- [ 1 < ] any?
        [ one-hot-input-out-of-bounds ] when
    ] 2bi ;

: one-hot ( features indices -- array )
    [ 1 ] 2dip
    [ [ length ] map ] dip
    check-one-hot-length
    [ [ cum-sum0 ] dip v+ ]
    [ drop sum 0 <array> ] 2bi
    [ set-nths ] keep ;
