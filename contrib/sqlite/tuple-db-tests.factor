! Copyright (C) 2005 Chris Double.
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
!
IN: tuple-db
USING: io kernel kernel-internals sequences namespaces hashtables 
       lists sqlite errors math words generic test ;

TUPLE: testdata one two ;

testdata default-mapping set-mapping

SYMBOL: db
"test.db" sqlite-open db set

db get testdata create-tuple-table

[ "two" f ] [
  db get "one" "two" <testdata> insert-tuple
  db get "one" f <testdata> find-tuples 
  first [ testdata-two ] keep
  db get swap delete-tuple    
  db get "one" f <testdata> find-tuples 
] unit-test

[ "junk" ] [
  db get "one" "two" <testdata> insert-tuple
  db get "one" f <testdata> find-tuples 
  first  
  "junk" over set-testdata-two
  db get swap update-tuple
  db get "one" f <testdata> find-tuples 
  first [ testdata-two ] keep
  db get swap delete-tuple      
] unit-test

db get testdata drop-tuple-table

db get sqlite-close