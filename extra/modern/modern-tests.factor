! Copyright (C) 2017 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: modern modern.slices tools.test ;
IN: modern.tests

! Comment
{
    { { "!" "" } }
} [ "!" string>literals >strings ] unit-test

{
    { { "!" " lol" } }
} [ "! lol" string>literals >strings ] unit-test

{
    { "lol!" }
} [ "lol!" string>literals >strings ] unit-test

{
    { { "!" "lol" } }
} [ "!lol" string>literals >strings ] unit-test

! Colon
{
    { ":asdf:" }
} [ ":asdf:" string>literals >strings ] unit-test

{
    { { "one:" "1" } }
} [ "one: 1" string>literals >strings ] unit-test

{
    { "1" ":>" "one" }
} [ "1 :> one" string>literals >strings ] unit-test

! Acute
{
    { { "<A" { } "A>" } }
} [ "<A A>" string>literals >strings ] unit-test

{
    { { "<B:" { "hi" } ";B>" } }
} [ "<B: hi ;B>" string>literals >strings ] unit-test

{ { "<foo>" } } [ "<foo>" string>literals >strings ] unit-test
{ { ">foo<" } } [ ">foo<" string>literals >strings ] unit-test

{ { "foo>" } } [ "foo>" string>literals >strings ] unit-test
{ { ">foo" } } [ ">foo" string>literals >strings ] unit-test
{ { ">foo>" } } [ ">foo>" string>literals >strings ] unit-test
{ { ">>foo>" } } [ ">>foo>" string>literals >strings ] unit-test
{ { ">>foo>>" } } [ ">>foo>>" string>literals >strings ] unit-test

{ { "foo<" } } [ "foo<" string>literals >strings ] unit-test
{ { "<foo" } } [ "<foo" string>literals >strings ] unit-test
{ { "<foo<" } } [ "<foo<" string>literals >strings ] unit-test
{ { "<<foo<" } } [ "<<foo<" string>literals >strings ] unit-test
{ { "<<foo<<" } } [ "<<foo<<" string>literals >strings ] unit-test

! Backslash
{
    { { "SYNTAX\\" "AVL{" } }
} [ "SYNTAX\\ AVL{" string>literals >strings ] unit-test

[ "\\" string>literals >strings ] must-fail
[ "SYNTAX\\" string>literals >strings ] must-fail

{
    { "foo\\bar" }
} [ "foo\\bar" string>literals >strings ] unit-test

[ "foo\\bar{" string>literals >strings ] must-fail

{
    { { "foo\\bar{" { "1" } "}" } }
} [ "foo\\bar{ 1 }" string>literals >strings ] unit-test
