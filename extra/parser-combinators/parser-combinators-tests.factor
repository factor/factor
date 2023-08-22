! Copyright (C) 2005 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel lists lists.lazy tools.test strings math
sequences parser-combinators arrays math.parser unicode ;

! Testing <&>
{ { T{ parse-result f { "a" "b" } T{ slice f 2 4 "abcd" } } }  } [
  "abcd" "a" token "b" token <&> parse list>array
] unit-test

{ { T{ parse-result f { { "a" "b" } "c" } T{ slice f 3 4 "abcd" } } } } [
  "abcd" "a" token "b" token <&> "c" token <&> parse list>array
] unit-test

{ { T{ parse-result f { "a" { "b" "c" } } T{ slice f 3 4 "abcd" }  } } } [
  "abcd" "a" token "b" token "c" token <&> <&> parse list>array
] unit-test

{ { } } [
  "decd" "a" token "b" token <&> parse list>array
] unit-test

{ { } } [
  "dbcd" "a" token "b" token <&> parse list>array
] unit-test

{ { } } [
  "adcd" "a" token "b" token <&> parse list>array
] unit-test

! Testing <|>
{ { T{ parse-result f "a" T{ slice f 1 4 "abcd" } } } } [
  "abcd" "a" token "b" token <|> parse list>array
] unit-test

{ { T{ parse-result f "b" T{ slice f 1 4 "bbcd" } } }  } [
  "bbcd" "a" token "b" token <|> parse list>array
] unit-test

{ { } } [
  "cbcd" "a" token "b" token <|> parse list>array
] unit-test

! Testing sp
{ { } } [
  "  abcd" "a" token parse list>array
] unit-test

{ { T{ parse-result f "a" T{ slice f 3 6 "  abcd" } } }  } [
  "  abcd" "a" token sp parse list>array
] unit-test

! Testing just
{ { T{ parse-result f "abcd" T{ slice f 4 4 "abcd" } } T{ parse-result f "abc" T{ slice f 3 4 "abcd" } } } } [
  "abcd" "abcd" token "abc" token <|> parse list>array
] unit-test

{ { T{ parse-result f "abcd" T{ slice f 4 4 "abcd" } } } } [
  "abcd" "abcd" token "abc" token <|> just parse list>array
] unit-test

! Testing <@
{ { T{ parse-result f 48 T{ slice f 1 5 "01234" } } } } [
  "01234" [ digit? ] satisfy parse list>array
] unit-test

{ { T{ parse-result f 0 T{ slice f 1 5 "01234" } } } } [
  "01234" [ digit? ] satisfy [ digit> ] <@ parse list>array
] unit-test

! Testing some
{ { T{ parse-result f "begin" T{ slice f 5 6 "begin1" } } } } [
  "begin1" "begin" token parse list>array
] unit-test

[
  "begin1" "begin" token some parse
] must-fail

{ "begin" } [
  "begin" "begin" token some parse
] unit-test

! <& parser and &> parser
{ { T{ parse-result f { "a" "b" } T{ slice f 2 4 "abcd" } } } } [
  "abcd" "a" token "b" token <&> parse list>array
] unit-test

{ { T{ parse-result f "a" T{ slice f 2 4 "abcd" } } } } [
  "abcd" "a" token "b" token <& parse list>array
] unit-test

{ { T{ parse-result f "b" T{ slice f 2 4 "abcd" } } } } [
  "abcd" "a" token "b" token &> parse list>array
] unit-test

! Testing <*> and <:&>
{ { T{ parse-result f { "1" } T{ slice f 1 4 "1234" } } T{ parse-result f { } "1234" } } } [
  "1234" "1" token <*> parse list>array
] unit-test

{
  {
    T{ parse-result f { "1" "1" "1" "1" } T{ slice f 4 7 "1111234" }  }
    T{ parse-result f { "1" "1" "1" } T{ slice f 3 7 "1111234" } }
    T{ parse-result f { "1" "1" } T{ slice f 2 7 "1111234" } }
    T{ parse-result f { "1" } T{ slice f 1 7 "1111234" } }
    T{ parse-result f { } "1111234" }
  }

} [
  "1111234" "1" token <*> parse list>array
] unit-test

{
  {
    T{ parse-result f { "1111" } T{ slice f 4 7 "1111234" } }
    T{ parse-result f { "111" } T{ slice f 3 7 "1111234" } }
    T{ parse-result f { "11" } T{ slice f 2 7 "1111234" } }
    T{ parse-result f { "1" } T{ slice f 1 7 "1111234" } }
    T{ parse-result f { { } } "1111234" }
  }
} [
  "1111234" "1" token <*> [ concat 1array ] <@ parse list>array
] unit-test

{ { T{ parse-result f { } "234" } } } [
  "234" "1" token <*> parse list>array
] unit-test

! Testing <+>
{ { T{ parse-result f { "1" } T{ slice f 1 4 "1234" } } } } [
  "1234" "1" token <+> parse list>array
] unit-test

{
  {
    T{ parse-result f { "1" "1" "1" "1" } T{ slice f 4 7 "1111234" } }
    T{ parse-result f { "1" "1" "1" }  T{ slice f 3 7 "1111234" } }
    T{ parse-result f { "1" "1" }  T{ slice f 2 7 "1111234" } }
    T{ parse-result f { "1" } T{ slice f 1 7 "1111234" } }
  }
} [
  "1111234" "1" token <+> parse list>array
] unit-test

{ { } } [
  "234" "1" token <+> parse list>array
] unit-test
