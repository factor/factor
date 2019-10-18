!:folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2003 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

: apply2 (x y [ code ] --)
    ! First applies the code to x, then to y.
    2dup 2>r
        nip call
    2r>
    call ;

~<< binrecP
    ! Put P on top of the data stack, save everything on callstack.
    P T R1 R2 -- P r:P r:T r:R1 r:R2 >>~

~<< binrecT
    ! Put T on top of the data stack, discard all saved objects from
    ! callstack.
    r:P r:T r:R1 r:R2 -- T >>~

~<< binrecR1
    ! Put R1 on top of the data stack, retaining all saved objects on the
    ! callstack.
    r:P r:T r:R1 r:R2 -- R1 r:P r:T r:R1 r:R2 >>~

~<< binrecLeft
    ! Left recursion setup; put second value on callstack, put P, T, R1, R2
    ! on data stack (and leave them on the callstack too).
    Value2 r:P r:T r:R1 r:R2 -- P T R1 R2 r:Value2 r:P r:T r:R1 r:R2 >>~

~<< binrecRight
    ! Right recursion setup; put second value back on datastack, put
    ! P, T, R1, R2 on data stack. All quotations except for R2 are
    ! discarded from the callstack, since they're not needed anymore.
    r:Value2 r:P r:T r:R1 r:R2 -- Value2 P T R1 R2 r:R2 >>~

: binrec ( [ P ] [ T ] [ R1 ] [ R2 ] -- ... )
    ! Evaluate P. If it evaluates to t, evaluate T. Otherwise, evaluate R1,
    ! which is expected to produce two values, recurse on each value, and
    ! evaluate R2.
    binrecP call [
        binrecT call
    ] [
        binrecR1 call
        ! R1 has now produced two values on top of the data stack.
        ! Recurse twice.
        binrecLeft  binrec
        binrecRight binrec
        ! Now call R2.
        r> call
    ] ifte ;

: compare (x y [if x < y] [if x = y] [if x > y] --)
    >=< call ;

: cleave (x [ code1 ] [ code2 ] --)
    ! Executes each quotation, with x on top of the stack.
    >r
        over >r
            call
        r>
    r>
    call ;

: cond (list --)
    ! The list is of this form:
    ! [ [ condition 1 ] [ code 1 ]
    !   [ condition 2 ] [ code 2 ]
    !   ... ]
    ! Each condition is evaluated in turn. If it returns true, the code
    ! is evaluated. If it returns false, the next condition is checked.
    [
        uncons >r
            call
        r>
        swap [
            car call
        ] [
            cdr cond
        ] ifte
    ] when* ;

: dip (a [ b ] -- b a)
    ! Calls b as if b was not even present on the stack -- b has no way of
    ! knowing that a even exists.
    swap
    >r
        call
    r> ;

: 2dip (a b [ c ] -- c a b)
    ! Calls c as if a and b were not even present on the stack -- c has no way
    ! of knowing that a and b even exist.
    -rot
    2>r
        call
    2r> ;

: each ([ list ] [ code ] --)
    ! Applies the code to each element of the list.
    over [
        >r
            uncons
        r>
        tuck
        2>r
            call
        2r>
        each
    ] [
        2drop
    ] ifte ;

: expand (list -- list)
    ! Evaluates the list on a new stack, and pushes the reversed stack onto the
    ! original stack. For example, "[ 0 1 2 dup * + ] expand" will evaluate to
    ! [ 0 5 ].
    unit
    restack
        call
    unstack ;

: interleave ( X list -- ... )
    ! Evaluate each element of the list with X on top of the
    ! stack.
    dup [
        over [ unswons dip ] dip swap interleave
    ] [
        2drop
    ] ifte ;

: ifte (cond [if true] [if false] --)
    ? call ;

: linrec ( [ P ] [ T ] [ R1 ] [ R2 ] -- )
    ! Evaluate P, if it pushes t, evaluate T. Otherwise, evaluate R1, recurse,
    ! and evaluate R2. This combinator is similar to the linrec combinator in
    ! Joy, except in Joy, P does not affect the stack.
    >r >r >r dup >r call [
        r> drop r> call
        r> drop r> drop
    ] [
        r> r> r> dup >r swap >r swap >r call
        r> r> r> r> dup >r linrec
        r> call
    ] ifte ;

: map ([ items ] [ initial ] [ code ] -- [ mapping ])
    ! Applies the code to each item, returns a list that begins with the initial
    ! list and contains the result of each application.
    swapd 2list append
    restack
        each
    unstack ;

: push ([ a b c ... ] -- a b c ...)
    ! Pushes values onto the stack literally (even if they are words).
    [ uncons push ] when* ;

: subset (list code -- list)
    ! Applies code to each element of the given list, creating a new list
    ! containing the elements where the code returned a non-null value.
    [ dupd call [ drop ] unless ] cons 2list
    restack
        each
    unstack ;

: times (n [ code ] --)
    ! Evaluates code n times.
    [
        over 0 >
    ] [
        tuck >r pred >r call r> r>
    ] while 2drop ;

: times* (n [ code ] --)
    ! Evaluates code n times, each time the index is pushed onto the stack.
    ! The index ranges from 0 to n-1.
    0 rot
    [
        2dup <
    ] [
        >r 2dup succ >r >r swap call r> r> r>
    ] while
    drop drop drop ;

: unless (cond [if false] --)
    f swap ? call ;

: when (cond [if true] --)
    f ? call ;

: when* (cond [ code ] --)
    ! If the condition is true, it is left on the stack, and the code is
    ! evaluated. Otherwise, the condition is popped off the stack.
    dupd [ drop ] ifte ;

: while ( [ P ] [ R ] -- ... )
    ! Evaluates P. If it leaves t on the stack, evaluate R, and recurse.
    >r dup >r call [
        r> r> dup >r swap >r call
        r> r> while
    ] [
        r> drop r> drop
    ] ifte ;
