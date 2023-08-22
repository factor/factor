! Copyright (c) 2008 Eric Mertens.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs combinators kernel math math.order namespaces sequences project-euler.common ;
IN: project-euler.151

! https://projecteuler.net/index.php?section=problems&id=151

! DESCRIPTION
! -----------

! A printing shop runs 16 batches (jobs) every week and each batch requires a
! sheet of special color-proofing paper of size A5.

! Every Monday morning, the foreman opens a new envelope, containing a large
! sheet of the special paper with size A1.

! He proceeds to cut it in half, thus getting two sheets of size A2. Then he
! cuts one of them in half to get two sheets of size A3 and so on until he
! obtains the A5-size sheet needed for the first batch of the week.

! All the unused sheets are placed back in the envelope.

! At the beginning of each subsequent batch, he takes from the envelope one
! sheet of paper at random. If it is of size A5, he uses it. If it is larger,
! he repeats the 'cut-in-half' procedure until he has what he needs and any
! remaining sheets are always placed back in the envelope.

! Excluding the first and last batch of the week, find the expected number of
! times (during each week) that the foreman finds a single sheet of paper in
! the envelope.

! Give your answer rounded to six decimal places using the format x.xxxxxx .


! SOLUTION
! --------

SYMBOL: table

: (pick-sheet) ( seq i -- newseq )
    [
        <=>
        {
            { +lt+ [ ] }
            { +eq+ [ 1 - ] }
            { +gt+ [ 1 + ] }
        } case
    ] curry map-index ;

DEFER: (euler151)

: pick-sheet ( seq i -- res )
    2dup swap nth dup zero? [
        3drop 0
    ] [
        [ (pick-sheet) (euler151) ] dip *
    ] if ;

: (euler151) ( x -- y )
    table get [ {
        { { 0 0 0 1 } [ 0 ] }
        { { 0 0 1 0 } [ { 0 0 0 1 } (euler151) 1 + ] }
        { { 0 1 0 0 } [ { 0 0 1 1 } (euler151) 1 + ] }
        { { 1 0 0 0 } [ { 0 1 1 1 } (euler151) 1 + ] }
        [ [ dup length <iota> [ pick-sheet ] with map-sum ] [ sum ] bi / ]
    } case ] cache ;

: euler151 ( -- answer )
    [
        H{ } clone table set
        { 1 1 1 1 } (euler151)
    ] with-scope ;

! [ euler151 ] 100 ave-time
! ? ms run time - 100 trials

SOLUTION: euler151
