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
USE: combinators
USE: kernel
USE: logic
USE: stack

: integer? dup fixnum? swap bignum? or ;
: rational? dup integer? swap ratio? or ;
: real? dup number? swap complex? not and ;

: odd? 2 mod 1 = ;
: even? 2 mod 0 = ;

: i #{ 0 1 } ; inline
: -i #{ 0 -1 } ; inline
: inf 1.0 0.0 / ; inline
: -inf -1.0 0.0 / ; inline
: e 2.7182818284590452354 ; inline
: pi 3.14159265358979323846 ; inline
: pi/2 1.5707963267948966 ; inline

: f>0 ( obj -- obj )
    #! If f at the top of the stack, turn it into 0.
    f 0 replace ;

: 0>f ( obj -- obj )
    #! If 0 at the top of the stack, turn it into f.
    0 f replace ;

: max ( x y -- z )
    2dup > [ drop ] [ nip ] ifte ;

: min ( x y -- z )
    2dup < [ drop ] [ nip ] ifte ;

: between? ( x min max -- ? )
    #! Push if min <= x <= max.
    >r dupd max r> min = ;

: sq dup * ; inline

: pred 1 - ; inline
: succ 1 + ; inline

: neg 0 swap - ; inline
: recip 1 swap / ; inline

: deg2rad pi * 180 / ;

: rad2deg 180 * pi / ;
