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

: 2apply (x y [ code ] --)
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

~<< binrec-left
    ! Left recursion setup; put second value on callstack, put P, T, R1, R2
    ! on data stack (and leave them on the callstack too).
    Value2 r:P r:T r:R1 r:R2 -- P T R1 R2 r:Value2 r:P r:T r:R1 r:R2 >>~

~<< binrec-right
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
        binrec-left  binrec
        binrec-right binrec
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

: cond ( x list -- )
    ! The list is of this form:
    ! [ [ condition 1 ] [ code 1 ]
    !   [ condition 2 ] [ code 2 ]
    !   ... ]
    ! Each condition is evaluated in turn. If it returns true,
    ! the code is evaluated. If it returns false, the next
    ! condition is checked. Before evaluating each condition,
    ! the top of the stack is duplicated. After the last
    ! condition is evaluated, the top of the stack is popped.
    dup [
        uncons [ over [ call ] dip ] dip rot [
            car call
        ] [
            cdr cond
        ] ifte
    ] [
        2drop
    ] ifte ;

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

: each ( [ list ] [ code ] -- )
    ! Applies the code to each element of the list.
    over [
        [ uncons ] dip tuck [ call ] 2dip each
    ] [
        2drop
    ] ifte ;

~<< 2each{
    A1 D1 A2 D2 C -- A1 A2 C r:D1 r:D2 r:C >>~

~<< }2each
    r:D1 r:D2 r:C -- D1 D2 C >>~

: 2each ( [ list ] [ list ] [ code ] -- )
    ! Push each pair of elements from the 2 lists in turn, then
    ! execute the code.
    over [
        [ [ uncons ] 2apply ] dip 2each{ call }2each 2each
    ] [
        drop drop drop
    ] ifte ;

: expand (list -- list)
    ! Evaluates the list on a new stack, and pushes the reversed stack onto the
    ! original stack. For example, "[ 0 1 2 dup * + ] expand" will evaluate to
    ! [ 0 5 ].
    unit
    restack
        call
    unstack ;

: forever ( code -- )
    ! The code is evaluated forever. Typically, a continuation
    ! is used to escape the infinite loop.
    dup dip forever ;

: ifte (cond [if true] [if false] --)
    ? call ;

: interleave ( X list -- ... )
    ! Evaluate each element of the list with X on top of the
    ! stack.
    dup [
        over [ unswons dip ] dip swap interleave
    ] [
        2drop
    ] ifte ;

: linrec ( [ P ] [ T ] [ R1 ] [ R2 ] -- )
    ! Evaluate P, if it pushes t, evaluate T. Otherwise, evaluate R1, recurse,
    ! and evaluate R2. This combinator is similar to the linrec combinator in
    ! Joy, except in Joy, P does not affect the stack.
    >r >r >r dup >r call [
        rdrop r> call
        rdrop rdrop
    ] [
        r> r> r> dup >r swap >r swap >r call
        r> r> r> r> dup >r linrec
        r> call
    ] ifte ;

: map ( [ items ] [ code ] -- [ mapping ])
    ! Applies the code to each item, returns a list that
    ! contains the result of each application.
    2list restack each unstack ;

: 2map ( [ list ] [ list ] [ code ] -- [ mapping ] )
    ! Applies the code to each pair of items, returns a list
    ! that contains the result of each application.
    3list restack 2each unstack ;

: subset ( list code -- list )
    [ dupd call [ drop ] unless ] cons 2list
    restack
        each
    unstack ;

: treerec ( list quot -- )
    ! Apply quot to each element of the list; if an element is a
    ! list, first quot is called with the list itself, then a
    ! recursive call to listrec is made.
    over [
        [ uncons ] dip tuck [
            over list? [
                2dup [ treerec ] 2dip
            ] when call
        ] 2dip treerec
    ] [
        2drop
    ] ifte ;

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

: unless* ( cond false -- )
    ! If cond is f, pop it off the stack and evaluate false.
    ! Otherwise, leave it on the stack.
    over [ drop ] [ nip call ] ifte ;

: when (cond [if true] --)
    f ? call ;

: when* (cond [ code ] --)
    ! If the condition is true, it is left on the stack, and the code is
    ! evaluated. Otherwise, the condition is popped off the stack.
    dupd [ drop ] ifte ;

: while ( [ P ] [ R ] -- ... )
    ! Evaluates P. If it leaves t on the stack, evaluate R, and recurse.
    >r dup >r call [
        rover r> call r> r> while
    ] [
        rdrop rdrop
    ] ifte ;
