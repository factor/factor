! :folding=indent:collapseFolds=0:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
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

IN: math
USE: combinators
USE: kernel
USE: logic
USE: math
USE: real-math
USE: stack

: fac ( n -- n! )
    ! This is the naive implementation, for benchmarking purposes.
    1 swap [ succ * ] times* ;

: mag2 ( x y -- mag )
    #! Returns the magnitude of the vector (x,y).
    swap sq swap sq + fsqrt ;

: abs ( z -- abs )
    #! Compute the complex absolute value.
    dup complex? [ >rect mag2 ] [ dup 0 < [ neg ] when ] ifte ;

: conjugate ( z -- z* )
    >rect neg rect> ;

: arg ( z -- arg )
    #! Compute the complex argument.
    >rect swap fatan2 ; inline

: >polar ( z -- abs arg )
    >rect 2dup swap fatan2 >r mag2 r> ;

: cis ( theta -- cis )
    dup fcos swap fsin rect> ;

: polar> ( abs arg -- z )
    cis * ; inline

: align ( offset width -- offset )
    2dup mod dup 0 = [ 2drop ] [ - + ] ifte ;
