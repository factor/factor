! Copyright (C) 2007 Robbert van Dalen.
! See http://factorcode.org/license.txt for BSD license.

IN: isequences.interface
USING: generic kernel ;  

! Unifies sequences, integers and objects, following Enchilada semantics.
! Efficiency is achieved through lazy immutable size-balanced binary trees. 

! - An object is an isequence of size 1 containing itself
! - An integer is an isequence of size itself containing zeros
! - If a sequence is never modified it is also considered an isequence
! - An isequence can have negative sign


GENERIC: -- ( s -- -s )                         ! monadic negate
GENERIC: $$ ( s1 -- h )                         ! monadic hash
GENERIC: ++ ( s1 s2 -- s )                      ! dyadic concatenate  

GENERIC: i-length ( s -- n )                    ! monadic size
GENERIC: i-cmp ( s1 s2 -- n )                   ! dyadic compare
GENERIC# i-at 1 ( s n -- v ) 		         	! dyadic index

GENERIC# ihead 1 ( s n -- s ) 		           	! dyadic head of a cut
GENERIC# itail 1 ( s n -- s ) 		        	! dyadic tail of a cut

GENERIC: ileft ( s -- v )                       ! balanced left side
GENERIC: iright ( s -- v )                      ! balanced right side
GENERIC: ipair ( s1 s2 -- s )                   ! pairing two isequences

GENERIC: ascending? ( s -- ? )                  ! monadic ascending query
GENERIC: descending? ( s -- ? )                 ! monadic descending query    

GENERIC: left-side ( v -- v )
GENERIC: right-side ( v -- v )
GENERIC: left-side-empty? ( s -- ? )
GENERIC: right-side-empty? ( s -- ? )
GENERIC: :v: ( v -- v )


! **** lazy turn of an isequence 
!
GENERIC: :: ( s -- ts )

! **** lazy reversal of an isequence
!
GENERIC: `` ( s -- rs )

! **** lazy right division of an isequence
!
GENERIC: _/ ( n s -- n/s )

! **** lazy left division of an isequence ****
!
GENERIC: /_ ( s1 n -- s1/n )

! **** full division of two isequences ****
!
: // ( s1 s2 -- n1/s2 s1/n2 ) 2dup /_ -rot _/ ; inline

! **** matching two isequences ****
!
GENERIC: >> ( s1 s2 -- s1/s2 )

! **** iota ****
!
GENERIC: ~~ ( s -- s )

! **** lazy maximum of two isequences
!
GENERIC: || ( s1 s2 -- max-s1-s2 )

! **** lazy minimum of two isequences ****
!
GENERIC: && ( s1 s2 -- min-s1-s2 )

! **** strict modulus of two isequences ****
!
GENERIC: %% ( s1 s2 -- ms1 ms2 )

! **** strict right product of an isequence ****
!
GENERIC: _* ( m s -- m*s )

! **** lazy left product of an isequence ****
!
GENERIC# *_ 1 ( s m -- s*m )

! **** full product of two isequences ****
!
: ** ( s1 s2 -- ms1 ms2 ) 2dup *_ -rot _* ; inline

! **** lazy left union ****
!
GENERIC: <_ ( n s -- n/s )

! **** lazy right diff ****
!
GENERIC: _< ( n s -- n/s )

! **** lazy union and diff of two isequences ****
!
: << ( s1 s2 -- u-s1-s2 d-s1-s2 ) 2dup <_ -rot _< ; inline

! **** lazy wiped isequence ****
!
GENERIC: ## ( s -- ws )



