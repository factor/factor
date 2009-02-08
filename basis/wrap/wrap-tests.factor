! Copyright (C) 2008, 2009 Daniel Ehrenberg, Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test wrap multiline sequences ;
IN: wrap.tests
    
[
    {
        {
            T{ element f 1 10 f }
            T{ element f 2 10 f }
            T{ element f 3 2 t }
        }
        {
            T{ element f 4 10 f }
            T{ element f 5 10 f }
        }
    }
] [
    {
        T{ element f 1 10 f }
        T{ element f 2 10 f }
        T{ element f 3 2 t }
        T{ element f 4 10 f }
        T{ element f 5 10 f }
    } 35 35 wrap-elements [ { } like ] map
] unit-test

[
    {
        {
            T{ element f 1 10 f }
            T{ element f 2 10 f }
            T{ element f 3 9 t }
            T{ element f 3 9 t }
            T{ element f 3 9 t }
        }
        {
            T{ element f 4 10 f }
            T{ element f 5 10 f }
        }
    }
] [
    {
        T{ element f 1 10 f }
        T{ element f 2 10 f }
        T{ element f 3 9 t }
        T{ element f 3 9 t }
        T{ element f 3 9 t }
        T{ element f 4 10 f }
        T{ element f 5 10 f }
    } 35 35 wrap-elements [ { } like ] map
] unit-test

[
    {
        {
            T{ element f 1 10 t }
            T{ element f 1 10 f }
            T{ element f 3 9 t }
        }
        {
            T{ element f 2 10 f }
            T{ element f 3 9 t }
        }
        {
            T{ element f 4 10 f }
            T{ element f 5 10 f }
        }
    }
] [
    {
        T{ element f 1 10 t }
        T{ element f 1 10 f }
        T{ element f 3 9 t }
        T{ element f 2 10 f }
        T{ element f 3 9 t }
        T{ element f 4 10 f }
        T{ element f 5 10 f }
    } 35 35 wrap-elements [ { } like ] map
] unit-test

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

[ "this text\nhas lots\nof spaces" ]
[ "this text        has lots of       spaces" 12 wrap-string ] unit-test

[ "hello\nhow\nare\nyou\ntoday?" ]
[ "hello how are you today?" 3 wrap-string ] unit-test

[ "aaa\nbb cc\nddddd" ] [ "aaa bb cc ddddd" 6 wrap-string ] unit-test
[ "aaa\nbb ccc\ndddddd" ] [ "aaa bb ccc dddddd" 6 wrap-string ] unit-test
[ "aaa bb\ncccc\nddddd" ] [ "aaa bb cccc ddddd" 6 wrap-string ] unit-test
[ "aaa bb\nccccccc\nddddddd" ] [ "aaa bb ccccccc ddddddd" 6 wrap-string ] unit-test
