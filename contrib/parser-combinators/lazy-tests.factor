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

[ t ] [ nil nil? ] unit-test
[ 5 ] [ 5 lunit car ] unit-test
[ f ] [ nil nil cons nil? ] unit-test
[ 5 t ] [ 5 lunit uncons nil? ] unit-test
[ 6 ] [ 
		5 6 lunit cons
		1 swap lnth 
	  ] unit-test
[ 12 13 t ] [ 
				5 6 lunit cons 
				[ 7 + ] lmap uncons uncons nil? 
	  		] unit-test
[ 5 6 t ] [
			    5 6 7 lunit cons cons 2 swap ltake 
			    uncons uncons nil? 
		  ] unit-test
[ 6 7 t ] [	5 6 7 lunit cons cons [ 5 > ] lsubset 
			uncons uncons nil? ] unit-test
[ 7 t ] [	5 6 7 lunit cons cons [ 6 > ] lsubset 
			uncons nil? ] unit-test
[ 1 3 5 t ] [ { 1 3 5 } array>list 
			uncons uncons uncons nil? ] unit-test
[ { 1 3 5 } ] [ { 1 3 5 } array>list list>array ] unit-test
[ { 1 2 3 4 5 6 7 8 9 } ] [
	{ 1 2 3 } array>list
	{ 4 5 6 } array>list
	{ 7 8 9 } array>list 
	lunit cons cons lappend* list>array ] unit-test
[ { 1 2 3 4 5 6 } ]
[ { 1 2 3 } array>list { 4 5 6 } array>list 
	lappend list>array ] unit-test
[ ] [ { 1 2 3 } array>list [ 3 + number>string print ] leach ] unit-test
[ { 1 2 3 4 } ]
	[ 0 lfrom [ 5 < ] lsubset [ 0 > ] lsubset 4 swap ltake list>array ] unit-test
