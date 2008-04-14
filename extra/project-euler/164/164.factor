! Copyright (c) 2008 Eric Mertens
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs kernel math math.ranges sequences ;

IN: project-euler.164

! http://projecteuler.net/index.php?section=problems&id=164

! DESCRIPTION
! -----------

! How many 20 digit numbers n (without any leading zero) exist such
! that no three consecutive digits of n have a sum greater than 9?

! SOLUTION
! --------

<PRIVATE

: next-keys ( key -- keys )
    [ peek ] [ 10 swap sum - ] bi [ 2array ] with map ;

: next-table ( assoc -- assoc )
    H{ } clone swap
    [ swap next-keys [ pick at+ ] with each ] assoc-each ;

: init-table ( -- assoc )
    9 [1,b] [ 1array 1 ] H{ } map>assoc ;

PRIVATE>

: euler164 ( -- n )
    init-table 19 [ next-table ] times values sum ;