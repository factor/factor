! Copyright (C) 2005 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel lazy-lists test errors strings parser math sequences parser-combinators arrays ;
IN: scratchpad

! Testing <&>
[ { T{ parse-result f { "a" "b" } T{ slice f "abcd" 2 4 } } }  ] [
  "abcd" "a" token "b" token <&> parse list>array
] unit-test

[ { T{ parse-result f { { "a" "b" } "c" } T{ slice f "abcd" 3 4 } } } ] [
  "abcd" "a" token "b" token <&> "c" token <&> parse list>array
] unit-test

[ { T{ parse-result f { "a" { "b" "c" } } T{ slice f "abcd" 3 4 }  } } ] [
  "abcd" "a" token "b" token "c" token <&> <&> parse list>array
] unit-test

[ { } ] [
  "decd" "a" token "b" token <&> parse list>array
] unit-test

[ { } ] [
  "dbcd" "a" token "b" token <&> parse list>array
] unit-test

[ { } ] [
  "adcd" "a" token "b" token <&> parse list>array
] unit-test

! Testing <|>
[ { T{ parse-result f "a" T{ slice f "abcd" 1 4 } } } ] [
  "abcd" "a" token "b" token <|> parse list>array
] unit-test

[ { T{ parse-result f "b" T{ slice f "bbcd" 1 4 } } }  ] [
  "bbcd" "a" token "b" token <|> parse list>array
] unit-test

[ { } ] [
  "cbcd" "a" token "b" token <|> parse list>array
] unit-test

! Testing sp
[ { } ] [
  "  abcd" "a" token parse list>array 
] unit-test

[ { T{ parse-result f "a" T{ slice f "  abcd" 3 6 } } }  ] [
  "  abcd" "a" token sp parse list>array 
] unit-test

! Testing just
[ { T{ parse-result f "abcd" T{ slice f "abcd" 4 4 } } T{ parse-result f "abc" T{ slice f "abcd" 3 4 } } } ] [
  "abcd" "abcd" token "abc" token <|> parse list>array
] unit-test

[ { T{ parse-result f "abcd" T{ slice f "abcd" 4 4 } } } ] [
  "abcd" "abcd" token "abc" token <|> just parse list>array
] unit-test 

! Testing <@
[ { T{ parse-result f 48 T{ slice f "01234" 1 5 } } } ] [
  "01234" [ digit? ] satisfy parse list>array 
] unit-test

[ { T{ parse-result f 0 T{ slice f "01234" 1 5 } } } ] [
  "01234" [ digit? ] satisfy [ digit> ] <@ parse list>array 
] unit-test

! Testing some
[ { T{ parse-result f "begin" T{ slice f "begin1" 5 6 } } } ] [
  "begin1" "begin" token parse list>array
] unit-test

[
  "begin1" "begin" token some parse 
] unit-test-fails 

[ "begin" ] [
  "begin" "begin" token some parse 
] unit-test

! <& parser and &> parser
[ { T{ parse-result f { "a" "b" } T{ slice f "abcd" 2 4 } } } ] [
  "abcd" "a" token "b" token <&> parse list>array
] unit-test

[ { T{ parse-result f "a" T{ slice f "abcd" 2 4 } } } ] [
  "abcd" "a" token "b" token <& parse list>array
] unit-test

[ { T{ parse-result f "b" T{ slice f "abcd" 2 4 } } } ] [
  "abcd" "a" token "b" token &> parse list>array
] unit-test

! Testing <*> and <:&>
[ { T{ parse-result f { "1" } T{ slice f "1234" 1 4 } } T{ parse-result f [ ] "1234" } } } ] [
  "1234" "1" token <*> parse list>array
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
  "1111234" "1" token <*> parse list>array
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
  "1111234" "1" token <*> [ concat 1array ] <@ parse list>array
] unit-test

[ { T{ parse-result f [ ] "234" } } ] [
  "234" "1" token <*> parse list>array
] unit-test

! Testing <+>
[ { T{ parse-result f { "1" } "234" } } ] [
  "1234" "1" token <+> parse list>array
] unit-test

[ 
  {
    T{ parse-result f { "1" "1" "1" "1" } "234" }
    T{ parse-result f { "1" "1" "1" } "1234" }
    T{ parse-result f { "1" "1" } "11234" }
    T{ parse-result f { "1" } "111234" }
  }
] [
  "1111234" "1" token <+> parse list>array
] unit-test

[ { } ] [
  "234" "1" token <+> parse list>array
] unit-test


