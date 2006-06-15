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
! Test the sqlite interface
!
! Create a test database like follows:
!
!   sqlite3 test.db < test.txt
!
!  Then run this file.
USE: sqlite
USE: kernel
USE: io
USE: prettyprint

: test.db "contrib/sqlite/test.db" ;

: show-people ( statement -- )
  dup 0 column-text write " from " write 1 column-text . ;

: run-test ( -- )
  test.db sqlite-open
  dup "select * from test" sqlite-prepare
  dup [ show-people ] sqlite-each 
  sqlite-finalize
  sqlite-close ;

: find-person ( name -- )
  test.db sqlite-open  ( name db )
  dup "select * from test where name=?" sqlite-prepare ( name db stmt )
  [ rot 1 swap sqlite-bind-text ] keep ( db stmt )
  [ [ 1 column-text . ] sqlite-each ] keep
  sqlite-finalize
  sqlite-close ;  

: find-all ( -- )
  test.db sqlite-open  ( db )
  dup "select * from test" sqlite-prepare ( db stmt )
  [ [ [ 0 column-text ] keep 1 column-text curry ] sqlite-map ] keep
  sqlite-finalize
  swap sqlite-close ;  

: run-test2 ( -- )
  test.db sqlite-open
  dup "select * from test" sqlite-prepare
  dup [ show-people ] ;

run-test
