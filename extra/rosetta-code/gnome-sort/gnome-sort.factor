! Copyright (C) 2017 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math sequences ;
IN: rosetta-code.gnome-sort

! https://rosettacode.org/wiki/Sorting_algorithms/Gnome_sort

! Gnome sort is a sorting algorithm which is similar to
! Insertion sort, except that moving an element to its
! proper place is accomplished by a series of swaps,
! as in Bubble Sort.

: inc-pos ( pos seq -- pos' seq )
    [ 1 + ] dip ; inline

: dec-pos ( pos seq -- pos' seq )
    [ 1 - ] dip ; inline

: take-two ( pos seq -- elt-at-pos-1 elt-at-pos )
    [ dec-pos nth ] [ nth ] 2bi ; inline

: need-swap? ( pos seq -- pos seq ? )
    over 1 < [ f ] [ 2dup take-two > ] if ;

: swap-back ( pos seq -- pos seq' )
    [ take-two ] 2keep
    [ dec-pos set-nth ] 2keep
    [ set-nth ] 2keep ;

: gnome-sort ( seq -- sorted-seq )
    1 swap [ 2dup length < ] [
        2dup [ need-swap? ] [ swap-back dec-pos ] while
        2drop inc-pos
    ] while nip ;
