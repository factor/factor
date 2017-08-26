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
