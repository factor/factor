! Copyright (c) 2008 Eric Mertens.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs kernel math ranges sequences project-euler.common ;
IN: project-euler.164

! https://projecteuler.net/index.php?section=problems&id=164

! DESCRIPTION
! -----------

! How many 20 digit numbers n (without any leading zero) exist such
! that no three consecutive digits of n have a sum greater than 9?


! SOLUTION
! --------

<PRIVATE

: next-keys ( key -- keys )
    [ last ] [ 10 swap sum - <iota> ] bi [ 2array ] with map ;

: next-table ( assoc -- assoc )
    H{ } clone swap
    [ swap next-keys [ pick at+ ] with each ] assoc-each ;

: init-table ( -- assoc )
    9 [1..b] [ 1array 1 ] H{ } map>assoc ;

PRIVATE>

: euler164 ( -- answer )
    init-table 19 [ next-table ] times values sum ;

! [ euler164 ] 100 ave-time
! 7 ms ave run time - 1.23 SD (100 trials)

SOLUTION: euler164
