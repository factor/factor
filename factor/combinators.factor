!:folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2003, 2004 Slava Pestov.
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

: 2apply ( x y [ code ] -- )
    #! First applies the code to x, then to y.
    #!
    #! If the quotation compiles, this combinator compiles.
    2dup 2>r
        nip call
    2r>
    call ;

: compare ( x y [ if x < y ] [ if x = y ] [ if x > y ] -- )
    >=< call ;

: cleave (x [ code1 ] [ code2 ] --)
    #! Executes each quotation, with x on top of the stack.
    #!
    #! If the quotation compiles, this combinator compiles.
    >r
        over >r
            call
        r>
    r>
    call ;

: cond ( x list -- )
    #! The list is of this form:
    #!
    #! [ [ condition 1 ] [ code 1 ]
    #!   [ condition 2 ] [ code 2 ]
    #!   ... ]
    #!
    #! Each condition is evaluated in turn. If it returns true,
    #! the code is evaluated. If it returns false, the next
    #! condition is checked.
    #!
    #! Before evaluating each condition, the top of the stack is
    #! duplicated. After the last condition is evaluated, the
    #! top of the stack is popped.
    #!
    #! So each condition and code block must have stack effect:
    #! ( X -- )
    #!
    #! This combinator will not compile.
    dup [
        uncons [ over [ call ] dip ] dip rot [
            car call
        ] [
            cdr cond
        ] ifte
    ] [
        2drop
    ] ifte ;

: dip ( a [ b ] -- b a )
    #! Call b as if b was not present on the stack.
    #!
    #! If the quotation compiles, this combinator compiles.
    swap
    >r
        call
    r> ;

: 2dip (a b [ c ] -- c a b)
    #! Call c as if a and b were not present on the stack.
    #!
    #! If the quotation compiles, this combinator compiles.
    -rot
    2>r
        call
    2r> ;

: each ( [ list ] [ quotation ] -- )
    #! Push each element of a proper list in turn, and apply a
    #! quotation to each element.
    #!
    #! In order to compile, the quotation must consume one more
    #! value than it produces.
    over [
        >r uncons r> tuck 2>r call 2r> each
    ] [
        2drop
    ] ifte ;

~<< 2each{
    A1 D1 A2 D2 C -- A1 A2 C r:D1 r:D2 r:C >>~

~<< }2each
    r:D1 r:D2 r:C -- D1 D2 C >>~

: 2each ( [ list ] [ list ] [ quotation ] -- )
    #! Push each pair of elements from 2 proper lists in turn,
    #! applying a quotation each time.
    over [
        [ [ uncons ] 2apply ] dip 2each{ call }2each 2each
    ] [
        drop drop drop
    ] ifte ;

: expand ( list -- list )
    #! Evaluates a quotation on a new stack, and pushes the
    #! reversed stack onto the original stack.
    #!
    #! This combinator will not compile.
    unit
    restack
        call
    unstack ;

: forever ( code -- )
    #! The code is evaluated in an infinite loop. Typically, a
    #! continuation is used to escape the infinite loop.
    #!
    #! This combinator will not compile.
    dup dip forever ;

: inject ( list code -- list )
    #! Applies the code to each item, returns a list that
    #! contains the result of each application.
    #!
    #! In order to compile, the quotation must consume as many
    #! values as it produces.
    f transp [
        ( accum code elem -- accum code )
        transp over >r >r call r> cons r>
    ] each drop nreverse ;

: interleave ( X list -- )
    #! Evaluate each element of the list with X on top of the
    #! stack. When done, X is popped off the stack.
    #!
    #! To avoid unexpected results, each element of the list
    #! must have stack effect ( X -- ).
    #!
    #! This combinator will not compile.
    dup [
        over [ unswons dip ] dip swap interleave
    ] [
        2drop
    ] ifte ;

: map ( [ items ] [ code ] -- [ mapping ] )
    #! Applies the code to each item, returns a list that
    #! contains the result of each application.
    #!
    #! This combinator will not compile.
    2list restack each unstack ;

: 2map ( [ list ] [ list ] [ code ] -- [ mapping ] )
    #! Applies the code to each pair of items, returns a list
    #! that contains the result of each application.
    #!
    #! This combinator will not compile.
    3list restack 2each unstack ;

: subset-add ( car pred accum -- accum )
    >r over >r call r> r> rot [ cons ] [ nip ] ifte ;

: subset-iter ( accum list pred -- accum )
    over [
        >r unswons r> 2swap pick 2>r subset-add 2r> subset-iter
	] [
        2drop
    ] ifte ;

: subset ( list pred -- list )
    #! Applies a quotation to each element of a list; all
    #! elements for which the quotation returned a value other
    #! than f are collected in a new list.
    #!
    #! In order to compile, the quotation must consume as many
    #! values as it produces.
    f -rot subset-iter nreverse ;

: times (n [ code ] --)
    #! Evaluate a quotation n times.
    #!
    #! In order to compile, the code must produce as many values
    #! as it consumes.
    [
        over 0 >
    ] [
        tuck >r pred >r call r> r>
    ] while 2drop ;

: times* (n [ code ] --)
    #! Evaluate a quotation n times, pushing the index at each
    #! iteration. The index ranges from 0 to n-1.
    #!
    #! In order to compile, the code must consume one more value
    #! than it produces.
    0 rot
    [
        2dup <
    ] [
        >r 2dup succ >r >r swap call r> r> r>
    ] while
    drop drop drop ;

: unless ( cond [ if false ] -- )
    #! Execute a quotation only when the condition is f. The
    #! condition is popped off the stack.
    #!
    #! In order to compile, the quotation must consume as many
    #! values as it produces.
    f swap ? call ;

    : unless* ( cond [ if false ] -- )
    #! If cond is f, pop it off the stack and evaluate the
    #! quotation. Otherwise, leave cond on the stack.
    #!
    #! In order to compile, the quotation must consume one less
    #! value than it produces.
    over [ drop ] [ nip call ] ifte ;

: when ( cond [ if true ] -- )
    #! Execute a quotation only when the condition is not f. The
    #! condition is popped off the stack.
    #!
    #! In order to compile, the quotation must consume as many
    #! values as it produces.
    f ? call ;

: when* (cond [ code ] --)
    #! If the condition is true, it is left on the stack, and
    #! the quotation is evaluated. Otherwise, the condition is
    #! popped off the stack.
    #!
    #! In order to compile, the quotation must consume one more
    #! value than it produces.
    dupd [ drop ] ifte ;

: while ( [ P ] [ R ] -- )
    #! Evaluate P. If it leaves t on the stack, evaluate R, and
    #! recurse.
    #!
    #! In order to compile, the stack effect of P * ( X -- ) * R
    #! must consume as many values as it produces.
    >r dup >r call [
        rover r> call r> r> while
    ] [
        rdrop rdrop
    ] ifte ;
