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

IN: combinators
USE: kernel
USE: lists
USE: stack

: 2apply ( x y [ code ] -- )
    #! First applies the code to x, then to y.
    #!
    #! If the quotation compiles, this combinator compiles.
    2dup >r >r nip call r> r> call ; inline interpret-only

: cleave ( x [ code1 ] [ code2 ] -- )
    #! Executes each quotation, with x on top of the stack.
    #!
    #! If the quotation compiles, this combinator compiles.
    >r over >r call r> r> call ; inline interpret-only

: dip ( a [ b ] -- b a )
    #! Call b as if b was not present on the stack.
    #!
    #! If the quotation compiles, this combinator compiles.
    swap >r call r> ; inline interpret-only

: 2dip ( a b [ c ] -- c a b )
    #! Call c as if a and b were not present on the stack.
    #!
    #! If the quotation compiles, this combinator compiles.
    -rot >r >r call r> r> ; inline interpret-only

: forever ( code -- )
    #! The code is evaluated in an infinite loop. Typically, a
    #! continuation is used to escape the infinite loop.
    #!
    #! This combinator will not compile.
    dup dip forever ; interpret-only

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
        uncons >r over >r call r> r> rot [
            car call
        ] [
            cdr cond
        ] ifte
    ] [
        2drop
    ] ifte ; interpret-only

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
    ] ifte ; interpret-only

: unless ( cond [ if false ] -- )
    #! Execute a quotation only when the condition is f. The
    #! condition is popped off the stack.
    #!
    #! In order to compile, the quotation must consume as many
    #! values as it produces.
    [ ] swap ifte ; inline interpret-only

: unless* ( cond [ if false ] -- )
    #! If cond is f, pop it off the stack and evaluate the
    #! quotation. Otherwise, leave cond on the stack.
    #!
    #! In order to compile, the quotation must consume one less
    #! value than it produces.
    over [ drop ] [ nip call ] ifte ; inline interpret-only

: when ( cond [ if true ] -- )
    #! Execute a quotation only when the condition is not f. The
    #! condition is popped off the stack.
    #!
    #! In order to compile, the quotation must consume as many
    #! values as it produces.
    [ ] ifte ; inline interpret-only

: when* ( cond [ code ] -- )
    #! If the condition is true, it is left on the stack, and
    #! the quotation is evaluated. Otherwise, the condition is
    #! popped off the stack.
    #!
    #! In order to compile, the quotation must consume one more
    #! value than it produces.
    dupd [ drop ] ifte ; inline interpret-only

: while ( [ P ] [ R ] -- )
    #! Evaluate P. If it leaves t on the stack, evaluate R, and
    #! recurse.
    #!
    #! In order to compile, the stack effect of P * ( X -- ) * R
    #! must consume as many values as it produces.
    2dup >r >r >r call [
        r> call r> r> while
    ] [
        r> drop r> drop r> drop
    ] ifte ; inline interpret-only
