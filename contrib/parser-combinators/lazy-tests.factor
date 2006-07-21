! Copyright (C) 2006 Matthew Willis.
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

USING: test kernel math io ;

IN: lazy

[ t ] [ lnil lnil? ] unit-test
[ 5 ] [ 5 lunit lcar ] unit-test
[ f ] [ lnil lnil lcons lnil? ] unit-test
[ 5 t ] [ 5 lunit luncons lnil? ] unit-test
[ 6 ] [ 
		5 6 lunit lcons
		1 swap lnth 
	  ] unit-test
[ 12 13 t ] [ 
				5 6 lunit lcons 
				[ 7 + ] lmap luncons luncons lnil? 
	  		] unit-test
[ 5 6 t ] [
			5 6 7 lunit lcons lcons 2 swap ltake 
			luncons luncons lnil? 
		  ] unit-test
[ 6 7 t ] [	5 6 7 lunit lcons lcons [ 5 > ] lsubset 
			luncons luncons lnil? ] unit-test
[ 7 t ] [	5 6 7 lunit lcons lcons [ 6 > ] lsubset 
			luncons lnil? ] unit-test
[ 1 3 5 t ] [ [ 1 3 5 ] list>llist 
			luncons luncons luncons lnil? ] unit-test
[ [ 1 3 5 ] ] [ [ 1 3 5 ] list>llist llist>list ] unit-test
[ [ 1 2 3 4 5 6 7 8 9 ] ] [
	[ 1 2 3 ] list>llist
	[ 4 5 6 ] list>llist
	[ 7 8 9 ] list>llist 
	lunit lcons lcons lappend* llist>list ] unit-test
[ [ 1 2 3 4 5 6 ] ]
[ [ 1 2 3 ] list>llist [ 4 5 6 ] list>llist 
	lappend llist>list ] unit-test
[ ] [ [ 1 2 3 ] list>llist [ 3 + number>string print ] leach ] unit-test
[ [ 1 2 3 4 ] ]
	[ 0 lfrom [ 5 < ] lsubset [ 0 > ] lsubset 4 swap ltake llist>list ] unit-test
