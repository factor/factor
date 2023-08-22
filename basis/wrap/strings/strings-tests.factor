! Copyright (C) 2008, 2009 Daniel Ehrenberg, Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: kernel namespaces strings tools.test wrap.strings ;

{
    "This is a
long piece
of text
that we
wish to
word wrap."
} [
    "This is a long piece of text that we wish to word wrap." 10
    wrap-string
] unit-test

{
    "  This is a
  long piece
  of text
  that we
  wish to
  word wrap."
} [
    "This is a long piece of text that we wish to word wrap." 12
    "  " wrap-indented-string
] unit-test

{
    "   This is
a long
piece of
text that
we wish to
word wrap."
} [
    "  This is a long piece of text that we wish to word wrap." 10
    wrap-string
] unit-test

{
    "     This is
  a long
  piece of
  text that
  we wish to
  word wrap."
} [
    "  This is a long piece of text that we wish to word wrap." 12
    "  " wrap-indented-string
] unit-test

{ t } [
    "This is a long piece of text that we wish to word wrap." 12
    [ "  " wrap-indented-string ] [ 2 wrap-indented-string ] 2bi =
] unit-test

{ "this text\nhas lots of\nspaces" }
[ "this text        has lots of       spaces" 12 wrap-string ] unit-test

{ "hello\nhow\nare\nyou\ntoday?" }
[ "hello how are you today?" 3 wrap-string ] unit-test

{ "aaa\nbb cc\nddddd" } [ "aaa bb cc ddddd" 6 wrap-string ] unit-test
{ "aaa bb\nccc\ndddddd" } [ "aaa bb ccc dddddd" 6 wrap-string ] unit-test
{ "aaa bb\ncccc\nddddd" } [ "aaa bb cccc ddddd" 6 wrap-string ] unit-test
{ "aaa bb\nccccccc\nddddddd" } [ "aaa bb ccccccc ddddddd" 6 wrap-string ] unit-test

{ "a b c d e f\ng h" } [ "a b c d e f g h" 11 wrap-string ] unit-test

{ "" } [ "" 10 wrap-string ] unit-test
{ "Hello" } [ "\nHello\n" 10 wrap-string ] unit-test

{ " > > > " } [ "" 70 " > > > " wrap-indented-string ] unit-test

{ "aaaa\naaaa\naa" } [
    t break-long-words? [
        10 CHAR: a <string> 4 wrap-string
    ] with-variable
] unit-test
