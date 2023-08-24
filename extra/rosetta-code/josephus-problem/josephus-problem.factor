USING: kernel math ranges sequences ;
IN: rosetta-code.josephus-problem

! http://rosettacode.org/wiki/Josephus_problem

! Problem: Josephus problem is a math puzzle with a grim
! description: n prisoners are standing on a circle, sequentially
! numbered from 0 to n − 1. An executioner walks along the circle,
! starting from prisoner 0, removing every k-th prisoner and
! killing him. As the process goes on, the circle becomes smaller
! and smaller, until only one prisoner remains, who is then freed.
! For example, if there are n = 5 prisoners and k = 2, the order
! the prisoners are killed in (let's call it the "killing
! sequence") will be 1, 3, 0, and 4, and the survivor will be #2.

! Task: Given any n,k > 0, find out which prisoner will be the
! final survivor. In one such incident, there were 41 prisoners
! and every 3rd prisoner was being killed (k = 3). Among them was
! ! a clever chap name Josephus who worked out the problem, stood at
! the surviving position, and lived on to tell the tale. Which
! number was he?

! Extra: The captors may be especially kind and let m survivors
! free, and Josephus might just have m − 1 friends to save.
! Provide a way to calculate which prisoner is at any given
! position on the killing sequence.

! Notes:
! 1. You can always play the executioner and follow the
!    procedure exactly as described, walking around the circle,
!    counting (and cutting off) heads along the way. This would yield
!    the complete killing sequence and answer the above questions,
!    with a complexity of probably O(kn). However, individually it
!    takes no more than O(m) to find out which prisoner is the m-th
!    to die.
! 2. If it's more convenient, you can number prisoners from 1 to
!    n instead. If you choose to do so, please state it clearly.
! 3. An alternative description has the people committing
!    assisted suicide instead of being executed, and the last person
!    simply walks away. These details are not relevant, at least not
!    mathematically.

:: josephus-k ( n k -- m )
    n [1..b] 0 [ [ k + ] dip mod ] reduce ;

:: josephus-2 ( n -- m )  ! faster for k=2
    n n log2 2^ - 2 * ;

:: josephus ( n k -- m )
    k 2 = [ n josephus-2 ] [ n k josephus-k ] if ;
