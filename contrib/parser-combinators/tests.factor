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
USING: kernel lazy-lists test errors strings parser math sequences parser-combinators arrays ;
IN: scratchpad

! Testing <&>
[ { T{ parse-result f { "a" "b" } "cd" } }  ] [
  "abcd" "a" token "b" token <&> call list>array
] unit-test

[ { T{ parse-result f { { "a" "b" } "c" } "d" } } ] [
  "abcd" "a" token "b" token <&> "c" token <&> call list>array
] unit-test

[ { T{ parse-result f { "a" { "b" "c" } } "d" } } ] [
  "abcd" "a" token "b" token "c" token <&> <&> call list>array
] unit-test

[ { } ] [
  "decd" "a" token "b" token <&> call list>array
] unit-test

[ { } ] [
  "dbcd" "a" token "b" token <&> call list>array
] unit-test

[ { } ] [
  "adcd" "a" token "b" token <&> call list>array
] unit-test

! Testing <|>
[ { T{ parse-result f "a" "bcd" } } ] [
  "abcd" "a" token "b" token <|> call list>array
] unit-test

[ { T{ parse-result f "b" "bcd" } }  ] [
  "bbcd" "a" token "b" token <|> call list>array
] unit-test

[ { } ] [
  "cbcd" "a" token "b" token <|> call list>array
] unit-test

! Testing sp
[ { } ] [
  "  abcd" "a" token call list>array 
] unit-test

[ { T{ parse-result f "a" "bcd" } }  ] [
  "  abcd" "a" token sp call list>array 
] unit-test

! Testing just
[ { T{ parse-result f "abcd" "" } T{ parse-result f "abc" "d" } } ] [
  "abcd" "abcd" token "abc" token <|> call list>array
] unit-test

[ { T{ parse-result f "abcd" "" } } ] [
  "abcd" "abcd" token "abc" token <|> just call list>array
] unit-test 

! Testing <@
[ { T{ parse-result f 48 "1234" } } ] [
  "01234" [ digit? ] satisfy call list>array 
] unit-test

[ { T{ parse-result f 0 "1234" } } ] [
  "01234" [ digit? ] satisfy [ digit> ] <@ call list>array 
] unit-test

! Testing some
[ { T{ parse-result f "begin" "1" } } ] [
  "begin1" "begin" token call list>array
] unit-test

[
  "begin1" "begin" token some call 
] unit-test-fails 

[ "begin" ] [
  "begin" "begin" token some call 
] unit-test

! <& parser and &> parser
[ { T{ parse-result f { "a" "b" } "cd" } } ] [
  "abcd" "a" token "b" token <&> call list>array
] unit-test

[ { T{ parse-result f "a" "cd" } } ] [
  "abcd" "a" token "b" token <& call list>array
] unit-test

[ { T{ parse-result f "b" "cd" } } ] [
  "abcd" "a" token "b" token &> call list>array
] unit-test

! Testing <*> and <:&>
[ { T{ parse-result f { "1" } "234" } T{ parse-result f [ ] "1234" } } ] [
  "1234" "1" token <*> call list>array
] unit-test

[ 
  {
    T{ parse-result f { "1" "1" "1" "1" } "234" }
    T{ parse-result f { "1" "1" "1" } "1234" }
    T{ parse-result f { "1" "1" } "11234" }
    T{ parse-result f { "1" } "111234" }
    T{ parse-result f [ ] "1111234" }
  }

] [
  "1111234" "1" token <*> call list>array
] unit-test

[ 
  {
    T{ parse-result f { "1111" } "234" }
    T{ parse-result f { "111" } "1234" }
    T{ parse-result f { "11" } "11234" }
    T{ parse-result f { "1" } "111234" }
    T{ parse-result f { [ ] } "1111234" }
  }
] [
  "1111234" "1" token <*> [ concat 1array ] <@ call list>array
] unit-test

[ { T{ parse-result f [ ] "234" } } ] [
  "234" "1" token <*> call list>array
] unit-test

! Testing <+>
[ { T{ parse-result f { "1" } "234" } } ] [
  "1234" "1" token <+> call list>array
] unit-test

[ 
  {
    T{ parse-result f { "1" "1" "1" "1" } "234" }
    T{ parse-result f { "1" "1" "1" } "1234" }
    T{ parse-result f { "1" "1" } "11234" }
    T{ parse-result f { "1" } "111234" }
  }
] [
  "1111234" "1" token <+> call list>array
] unit-test

[ { } ] [
  "234" "1" token <+> call list>array
] unit-test


