! Copyright (C) 2017 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: modern modern.slices multiline tools.test ;
IN: modern.tests

{ f } [ "" upper-colon? ] unit-test
{ t } [ ":" upper-colon? ] unit-test
{ t } [ "::" upper-colon? ] unit-test
{ t } [ ":::" upper-colon? ] unit-test
{ t } [ "FOO:" upper-colon? ] unit-test
{ t } [ "FOO::" upper-colon? ] unit-test
{ t } [ "FOO:::" upper-colon? ] unit-test

! 'FOO:
{ f } [ "'" upper-colon? ] unit-test
{ t } [ "':" upper-colon? ] unit-test
{ t } [ "'::" upper-colon? ] unit-test
{ t } [ "':::" upper-colon? ] unit-test
{ t } [ "'FOO:" upper-colon? ] unit-test
{ t } [ "'FOO::" upper-colon? ] unit-test
{ t } [ "'FOO:::" upper-colon? ] unit-test

! \FOO: is not an upper-colon form, it is deactivated by the \
{ f } [ "\\" upper-colon? ] unit-test
{ f } [ "\\:" upper-colon? ] unit-test
{ f } [ "\\::" upper-colon? ] unit-test
{ f } [ "\\:::" upper-colon? ] unit-test
{ f } [ "\\FOO:" upper-colon? ] unit-test
{ f } [ "\\FOO::" upper-colon? ] unit-test
{ f } [ "\\FOO:::" upper-colon? ] unit-test


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
    { { "one:" { "1" } } }
} [ "one: 1" string>literals >strings ] unit-test

{
    { { "two::" { "1" "2" } } }
} [ "two:: 1 2" string>literals >strings ] unit-test

{
    { "1" ":>" "one" }
} [ "1 :> one" string>literals >strings ] unit-test

{
    { { ":" { "foo" } ";" } }
} [ ": foo ;" string>literals >strings ] unit-test

{
    {
        { "FOO:" { "a" } }
        { "BAR:" { "b" } }
    }
} [ "FOO: a BAR: b" string>literals >strings ] unit-test

{
    { { "FOO:" { "a" } ";" } }
} [ "FOO: a ;" string>literals >strings ] unit-test

{
    { { "FOO:" { "a" } "FOO;" } }
} [ "FOO: a FOO;" string>literals >strings ] unit-test


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

! Backslash \AVL{ foo\bar foo\bar{
{
    { { "SYNTAX:" { "\\AVL{" } } }
} [ "SYNTAX: \\AVL{" string>literals >strings ] unit-test

[ "\\" string>literals >strings ] must-fail ! \ alone should be legal eventually (?)

{ { "\\FOO" } } [ "\\FOO" string>literals >strings ] unit-test

{
    { "foo\\bar" }
} [ "foo\\bar" string>literals >strings ] unit-test

[ "foo\\bar{" string>literals >strings ] must-fail

{
    { { "foo\\bar{" { "1" } "}" } }
} [ "foo\\bar{ 1 }" string>literals >strings ] unit-test

{ { { "char:" { "\\{" } } } } [ "char: \\{" string>literals >strings ] unit-test
[ "char: {" string>literals >strings ] must-fail
[ "char: [" string>literals >strings ] must-fail
[ "char: {" string>literals >strings ] must-fail
[ "char: \"" string>literals >strings ] must-fail
! { { { "char:" { "\\\\" } } } } [ "char: \\\\" string>literals >strings ] unit-test

[ "char: \\" string>literals >strings ] must-fail ! char: \ should be legal eventually

{ { { "\\" { "(" } } } } [ "\\ (" string>literals >strings ] unit-test

{ { "\\[[" } } [ "\\[[" string>literals >strings ] unit-test
{ { "\\[=[" } } [ "\\[=[" string>literals >strings ] unit-test
{ { "\\[==[" } } [ "\\[==[" string>literals >strings ] unit-test


{ t } [ "FOO:" strict-upper? ] unit-test
{ t } [ ":" strict-upper? ] unit-test
{ f } [ "<FOO" strict-upper? ] unit-test
{ f } [ "<FOO:" strict-upper? ] unit-test
{ f } [ "->" strict-upper? ] unit-test
{ f } [ "FOO>" strict-upper? ] unit-test
{ f } [ ";FOO>" strict-upper? ] unit-test

{ f } [ "FOO" section-open? ] unit-test
{ f } [ "FOO:" section-open? ] unit-test
{ f } [ ";FOO" section-close? ] unit-test
{ f } [ "FOO" section-close? ] unit-test


! Strings
{
    { { "url\"" "google.com" "\"" } }
} [ [[ url"google.com" ]] string>literals >strings ] unit-test

{
    { { "\"" "google.com" "\"" } }
} [ [[ "google.com" ]] string>literals >strings ] unit-test

{
    {
        { "(" { "a" "b" } ")" }
        { "[" { "a" "b" "+" } "]" }
        { "(" { "c" } ")" }
    }
} [ "( a b ) [ a b + ] ( c )" string>literals >strings ] unit-test

![[
! Concatenated syntax
{
    {
        {
            { "(" { "a" "b" } ")" }
            { "[" { "a" "b" "+" } "]" }
            { "(" { "c" } ")" }
        }
    }
} [ "( a b )[ a b + ]( c )" string>literals >strings ] unit-test

{
    {
        {
            { "\"" "abc" "\"" }
            { "[" { "0" } "]" }
        }
    }
} [ "\"abc\"[ 0 ]" string>literals >strings ] unit-test
]]


{
    {
        { "<FOO" { { "BAR:" { "bar" } } } "FOO>" }
    }
} [ "<FOO BAR: bar FOO>" string>literals >strings ] unit-test

{
    {
        { "<FOO:" { "foo" { "BAR:" { "bar" } } } ";FOO>" }
    }
} [ "<FOO: foo BAR: bar ;FOO>" string>literals >strings ] unit-test


![[
{
    {
        {
            {
                "foo::"
                {
                    {
                        { "<FOO" { } "FOO>" }
                        { "[" { "0" } "]" }
                        { "[" { "1" } "]" }
                        { "[" { "2" } "]" }
                        { "[" { "3" } "]" }
                    }
                    { { "<BAR" { } "BAR>" } }
                }
            }
        }
    }
} [ "foo:: <FOO FOO>[ 0 ][ 1 ][ 2 ][ 3 ] <BAR BAR>" string>literals >strings ] unit-test
]]

{
    {
        { "foo::" { { "<FOO" { } "FOO>" } { "[" { "0" } "]" } } }
        { "[" { "1" } "]" }
        { "[" { "2" } "]" }
        { "[" { "3" } "]" }
        { "<BAR" { } "BAR>" }
    }
} [ "foo:: <FOO FOO> [ 0 ] [ 1 ] [ 2 ] [ 3 ] <BAR BAR>" string>literals >strings ] unit-test
