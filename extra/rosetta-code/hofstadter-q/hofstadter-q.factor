! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math prettyprint sequences ;
IN: rosetta-code.hofstadter-q

! https://rosettacode.org/wiki/Hofstadter_Q_sequence

! The Hofstadter Q sequence is defined as:
!    Q(1) = Q(2) = 1
!    Q(n) = Q(n - Q(n-1)) + Q(n - Q(n-2))     , n > 2

! It is defined like the Fibonacci sequence, but whereas the
! next term in the Fibonacci sequence is the sum of the previous
! two terms, in the Q sequence the previous two terms tell you how
! far to go back in the Q sequence to find the two numbers to sum
! to make the next term of the sequence.

! Task

! 1. Confirm and display that the first ten terms of the sequence
!    are: 1, 1, 2, 3, 3, 4, 5, 5, 6, and 6

! 2. Confirm and display that the 1000'th term is: 502

! Optional extra credit

! * Count and display how many times a member of the sequence is
!   less than its preceding term for terms up to and including the
!   100,000'th term.

! * Ensure that the extra credit solution 'safely' handles being
!   initially asked for an n'th term where n is large.

! (This point is to ensure that caching and/or recursion limits,
! if it is a concern, is correctly handled).

: next ( seq -- newseq )
    dup 2 tail* over length [ swap - ] curry map
    [ dupd swap nth ] map 0 [ + ] reduce suffix ;

: qs-main ( -- )
    { 1 1 } 1000 [ next ] times  dup 10 head .  999 swap nth . ;
