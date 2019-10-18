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
USING: kernel lazy test errors strings parser lists math sequences parser-combinators ;
IN: scratchpad

! Testing <&>
[ [ [[ "cd" [[ "a" "b" ]] ]] ] ] [
  "abcd" "a" token "b" token <&> call llist>list
] unit-test

[ [ [[ "d" [[ [[ "a" "b" ]] "c" ]] ]] ] ] [
  "abcd" "a" token "b" token <&> "c" token <&> call llist>list
] unit-test

[ [ [[ "d" [[ "a" [[ "b" "c" ]] ]] ]] ] ] [
  "abcd" "a" token "b" token "c" token <&> <&> call llist>list
] unit-test

[ f ] [
  "decd" "a" token "b" token <&> call llist>list
] unit-test

[ f ] [
  "dbcd" "a" token "b" token <&> call llist>list
] unit-test

[ f ] [
  "adcd" "a" token "b" token <&> call llist>list
] unit-test

! Testing <|>
[ [ [[ "bcd" "a" ]] ] ] [
  "abcd" "a" token "b" token <|> call llist>list
] unit-test

[ [ [[ "bcd" "b" ]] ] ] [
  "bbcd" "a" token "b" token <|> call llist>list
] unit-test

[ f ] [
  "cbcd" "a" token "b" token <|> call llist>list
] unit-test

! Testing sp
[ f ] [
  "  abcd" "a" token call llist>list 
] unit-test

[ [ [[ "bcd" "a" ]] ] ] [
  "  abcd" "a" token sp call llist>list 
] unit-test

! Testing just
[ [ [[ "" "abcd" ]] [[ "d" "abc" ]] ] ] [
  "abcd" "abcd" token "abc" token <|> call llist>list
] unit-test

[ [ [[ "" "abcd" ]] ] ] [
  "abcd" "abcd" token "abc" token <|> just call llist>list
] unit-test 

! Testing <@
[ [ [[ "1234" 48 ]] ] ] [
  "01234" [ digit? ] satisfy call llist>list 
] unit-test

[ [ [[ "1234" 0 ]] ] ] [
  "01234" [ digit? ] satisfy [ digit> ] <@ call llist>list 
] unit-test

! Testing some
[ [ [[ "1" "begin" ]] ] ] [
  "begin1" "begin" token call llist>list
] unit-test

[
  "begin1" "begin" token some call 
] unit-test-fails 

[ "begin" ] [
  "begin" "begin" token some call 
] unit-test

! parens test function
: parens ( -- parser )
  #! Return a parser that parses nested parentheses.
  [ "(" token parens <&> ")" token <&> parens <&> epsilon <|> call ]  ;

[ [ [[ "" "" ]] ] ] [
  "" parens call llist>list
] unit-test

[  
  [[ "" [[ [[ [[ "(" "" ]] ")" ]] "" ]] ]]
  [[ "()" "" ]]
] [
  "()" parens call [ ] leach
] unit-test

[ [[ "((()))" "" ]] ] [
  "((()))" parens call lcdr lcar 
] unit-test

! <& parser and &> parser
[ [ [[ "cd" [[ "a" "b" ]] ]] ] ] [
  "abcd" "a" token "b" token <&> call llist>list
] unit-test

[ [ [[ "cd" "a" ]] ] ] [
  "abcd" "a" token "b" token <& call llist>list
] unit-test

[ [ [[ "cd" "b" ]] ] ] [
  "abcd" "a" token "b" token &> call llist>list
] unit-test

! nesting example
: parens-open "(" token ;
: parens-close ")" token ;
: nesting
  [ parens-open 
    nesting &> 
    parens-close <& 
    nesting <&> 
    [ unswons 1 + max ] <@
    0 succeed <|> 
    call ] ;

[ [ [[ "" 0 ]] ] ] [
  "" nesting just call llist>list
] unit-test

[ [ [[ "" 1 ]] ] ] [
  "()" nesting just call llist>list
] unit-test

[ [ [[ "" 2 ]] ] ] [
  "(())" nesting just call llist>list
] unit-test

[ [ [[ "" 3 ]] ] ] [
  "()(()(()()))()" nesting just call llist>list
] unit-test

! Testing <*> and <:&>
[ [ [ "234" [ "1" ] ] [ "1234" ] ] ] [
  "1234" "1" token <*> call llist>list
] unit-test

[ 
  [ "234" [ "1" "1" "1" "1" ] ]
  [ "1234" [ "1" "1" "1" ] ]
  [ "11234" [ "1" "1" ] ]
  [ "111234" [ "1" ] ]
  [ "1111234" ]
] [
  "1111234" "1" token <*> call [ ] leach
] unit-test

[ 
  [ "234" "1111" ]
  [ "1234" "111" ]
  [ "11234" "11" ]
  [ "111234" "1" ]
  [ "1111234" f ]
] [
  "1111234" "1" token <*> [ car concat unit ] <@ call [ ] leach
] unit-test

[ [ "234" ] ] [
  "234" "1" token <*> call [ ] leach
] unit-test

: pdigit [ digit? ] satisfy [ digit> ] <@ ;
: pnatural pdigit <*> ;
: pnatural2 pnatural [ car [ >digit ] map >string dup pempty? [ drop 0 ] [ string>number ] if unit ] <@ ;

[ 
  [ "" 12345 ]
  [ "5" 1234 ]
  [ "45" 123 ]
  [ "345" 12 ]
  [ "2345" 1 ]
  [ "12345" 0 ]
] [
  "12345" pnatural2 call [ ] leach
] unit-test

! Testing <+>
[ [ "234" [ "1" ] ] ] [
  "1234" "1" token <+> call [ ] leach
] unit-test

[ 
  [ "234" [ "1" "1" "1" "1" ] ]
  [ "1234" [ "1" "1" "1" ] ]
  [ "11234" [ "1" "1" ] ]
  [ "111234" [ "1" ] ]
] [
  "1111234" "1" token <+> call [ ] leach
] unit-test

[ ] [
  "234" "1" token <+> call [ ] leach
] unit-test

! Testing <?>
[ [[ "" [[ [ "a" ] "b" ]] ]] ] [
  "ab" "a" token pdigit <?> <&> "b" token <&> call [ ] leach
] unit-test

[ ] [
  "ac" "a" token pdigit <?> <&> "b" token <&> call [ ] leach
] unit-test

[ [[ "" [[ [ "a" 5 ] "b" ]] ]] ] [
  "a5b" "a" token pdigit <?> <&> "b" token <&> call [ ] leach
] unit-test

: pinteger "-" token <?> pnatural2 <&> [ uncons swap [ car -1 * ] when ] <@ ;

[ 
  [ "" 123 ]
  [ "3" 12 ]
  [ "23" 1 ]
  [ "123" 0 ]
] [
  "123" pinteger call [ ] leach
] unit-test

[ 
  [[ "" -123 ]]
  [[ "3" -12 ]]
  [[ "23" -1 ]]
  [[ "123" 0 ]]
  [ "-123" 0 ] 
] [
  "-123" pinteger call [ ] leach
] unit-test

