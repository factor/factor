USING: tools.test sequences.parser unicode kernel accessors ;

{ "hello" }
[ "hello" [ take-rest ] parse-sequence ] unit-test

{ "hi" " how are you?" }
[
    "hi how are you?"
    [ [ [ current blank? ] take-until ] [ take-rest ] bi ] parse-sequence
] unit-test

{ "foo" ";bar" }
[
    "foo;bar" [
        [ CHAR: ; take-until-object ] [ take-rest ] bi
    ] parse-sequence
] unit-test

{ "foo " "and bar" }
[
    "foo and bar" [
        [ "and" take-until-sequence ] [ take-rest ] bi
    ] parse-sequence
] unit-test

{ "foo " " bar" }
[
    "foo and bar" [
        [ "and" take-until-sequence ]
        [ "and" take-sequence drop ]
        [ take-rest ] tri
    ] parse-sequence
] unit-test

{ "foo " " bar" }
[
    "foo and bar" [
        [ "and" take-until-sequence* ]
        [ take-rest ] bi
    ] parse-sequence
] unit-test

{ { 1 2 } }
[ { 1 2 3 4 } <sequence-parser> { 3 4 } take-until-sequence ] unit-test

{ f "aaaa" }
[
    "aaaa" <sequence-parser>
    [ "b" take-until-sequence ] [ take-rest ] bi
] unit-test

{ 6 }
[
    "      foo   " [ skip-whitespace n>> ] parse-sequence
] unit-test

{ { 1 2 } }
[ { 1 2 3 } <sequence-parser> [ current 3 = ] take-until ] unit-test

{ "ab" }
[ "abcd" <sequence-parser> "ab" take-sequence ] unit-test

{ f }
[ "abcd" <sequence-parser> "lol" take-sequence ] unit-test

{ "ab" }
[
    "abcd" <sequence-parser>
    [ "lol" take-sequence drop ] [ "ab" take-sequence ] bi
] unit-test

{ "" }
[ "abcd" <sequence-parser> "" take-sequence ] unit-test

{ "cd" }
[ "abcd" <sequence-parser> [ "ab" take-sequence drop ] [ "cd" take-sequence ] bi ] unit-test

{ f }
[ "" <sequence-parser> take-rest ] unit-test

{ f }
[ "abc" <sequence-parser> dup "abc" take-sequence drop take-rest ] unit-test

{ f }
[ "abc" <sequence-parser> "abcdefg" take-sequence ] unit-test

{ "1234" }
[ "1234f" <sequence-parser> take-integer ] unit-test

{ "yes" }
[
    "yes1234f" <sequence-parser>
    [ take-integer drop ] [ "yes" take-sequence ] bi
] unit-test

{ f } [ "" <sequence-parser> 4 take-n ] unit-test
{ "abcd" } [ "abcd" <sequence-parser> 4 take-n ] unit-test
{ "abcd" "efg" } [ "abcdefg" <sequence-parser> [ 4 take-n ] [ take-rest ] bi ] unit-test

{ f }
[ "\n" <sequence-parser> take-integer ] unit-test

{ "\n" } [ "\n" <sequence-parser> [ ] take-while ] unit-test
{ f } [ "\n" <sequence-parser> [ not ] take-while ] unit-test


{ f } [
    { } <sequence-parser> next
] unit-test


{ f } [
    { } <sequence-parser> current
] unit-test


{ f } [
    { } <sequence-parser> consume
] unit-test


{ 2 2 } [
    { 2 1 3 7 } <sequence-parser> [ current ] [ current ] bi
] unit-test


{ 1 1 } [
    { 2 1 3 7 } <sequence-parser> [ next ] [ current ] bi
] unit-test


{ 2 1 } [
    { 2 1 3 7 } <sequence-parser> [ consume ] [ current ] bi
] unit-test


{ f } [
    { 2 } <sequence-parser> next
] unit-test


{ 2 f } [
    { 2 } <sequence-parser> [ consume ] [ current ] bi
] unit-test
