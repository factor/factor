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
USE: lazy
USE: math
USE: lists
USE: parser-combinators
USE: kernel
USE: sequences
USE: namespaces

: lfrom ( n -- llist )
  #! Return a lazy list of increasing numbers starting
  #! from the initial value 'n'.
  dup unit delay swap
  [ 1 + lfrom ] cons delay lcons ;
  
: lfrom-by ( n quot -- llist )
  #! Return a lazy list of values starting from n, with
  #! each successive value being the result of applying quot to
  #! n.
  swap dup unit delay -rot 
  [ , dup , \ call , , \ lfrom-by , ] [ ] make delay lcons ;

: lnaturals 0 lfrom ;
: lpositves 1 lfrom ;
: levens 0 [ 2 + ] lfrom-by ;
: lodds 1 lfrom [ 2 mod 1 = ] lsubset ;
: lpowers-of-2 1 [ 2 * ] lfrom-by ;
: lones 1 [ ] lfrom-by ;
: lsquares lnaturals [ dup * ] lmap ;
: first-five-squares 5 lsquares ltake ;

: divisible-by? ( a b -- bool )
  #! Return true if a is divisible by b
  mod 0 = ;

: sieve ( llist - llist )
  #! Given a lazy list of numbers, use the sieve of eratosthenes
  #! algorithm to return a lazy list of primes.
  luncons over [ divisible-by? not ] 
  cons lsubset [ sieve ] cons delay >r unit delay r> lcons ;

: lprimes 2 lfrom sieve ;

: first-ten-primes 10 lprimes ltake llist>list ;
