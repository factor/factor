! Copyright (C) 2008, 2009 Daniel Ehrenberg, Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: wrap.strings tools.test multiline ;
IN: wrap.strings.tests

[
    <" This is a
long piece
of text
that we
wish to
word wrap.">
] [
    <" This is a long piece of text that we wish to word wrap."> 10
    wrap-string
] unit-test
    
[
    <"   This is a
  long piece
  of text
  that we
  wish to
  word wrap.">
] [
    <" This is a long piece of text that we wish to word wrap."> 12
    "  " wrap-indented-string
] unit-test

[ "this text\nhas lots of\nspaces" ]
[ "this text        has lots of       spaces" 12 wrap-string ] unit-test

[ "hello\nhow\nare\nyou\ntoday?" ]
[ "hello how are you today?" 3 wrap-string ] unit-test

[ "aaa\nbb cc\nddddd" ] [ "aaa bb cc ddddd" 6 wrap-string ] unit-test
[ "aaa\nbb ccc\ndddddd" ] [ "aaa bb ccc dddddd" 6 wrap-string ] unit-test
[ "aaa bb\ncccc\nddddd" ] [ "aaa bb cccc ddddd" 6 wrap-string ] unit-test
[ "aaa bb\nccccccc\nddddddd" ] [ "aaa bb ccccccc ddddddd" 6 wrap-string ] unit-test

[ "a b c d e f\ng h" ] [ "a b c d e f g h" 11 wrap-string ] unit-test
