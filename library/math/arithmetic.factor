! :folding=indent:collapseFolds=0:

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

IN: math
USE: kernel

: integer? dup fixnum? swap bignum? or ;
: rational? dup integer? swap ratio? or ;
: real? dup number? swap complex? not and ;

: max ( x y -- z )
    2dup > [ drop ] [ nip ] ifte ;

: min ( x y -- z )
    2dup < [ drop ] [ nip ] ifte ;

: between? ( x min max -- ? )
    #! Push if min <= x <= max. Handles case where min > max
    #! by swapping them.
    2dup > [ swap ] when  >r dupd max r> min = ;

: sq dup * ; inline

: pred 1 - ; inline
: succ 1 + ; inline

: neg 0 swap - ; inline
: recip 1 swap / ; inline

: rem ( x y -- x%y )
    #! Like modulus, but always gives a positive result.
    [ mod ] keep  over 0 < [ + ] [ drop ] ifte ;

: sgn ( n -- -1/0/1 )
    #! Push the sign of a real number.
    dup 0 = [ drop 0 ] [ 1 < -1 1 ? ] ifte ;
