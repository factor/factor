! Rewritten by Matthew Willis, July 2006
!
! Copyright (C) 2004 Chris Double.
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
IN: lazy-examples
USING: lazy math kernel sequences ;

: naturals 0 lfrom ;
: positves 1 lfrom ;
: evens 0 [ 2 + ] lfrom-by ;
: odds 1 lfrom [ 2 mod 1 = ] lsubset ;
: powers-of-2 1 [ 2 * ] lfrom-by ;
: ones 1 [ ] lfrom-by ;
: squares naturals [ dup * ] lmap ;
: first-five-squares 5 squares ltake ;

: divisible-by? ( a b -- bool )
    #! Return true if a is divisible by b
    mod 0 = ;

: filter-multiples ( n list - list )
    #! Given a lazy list of numbers, filter multiples of n
	swap [ divisible-by? not ] curry lsubset ;

: primes 2 lfrom [ filter-multiples ] lapply ;

: first-ten-primes 10 primes ltake list>array ;
