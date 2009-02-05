! Copyright (C) 2008, 2009 Daniel Ehrenberg, Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test wrap multiline sequences ;
IN: wrap.tests
    
[
    {
        {
            T{ word f 1 10 f }
            T{ word f 2 10 f }
            T{ word f 3 2 t }
        }
        {
            T{ word f 4 10 f }
            T{ word f 5 10 f }
        }
    }
] [
    {
        T{ word f 1 10 f }
        T{ word f 2 10 f }
        T{ word f 3 2 t }
        T{ word f 4 10 f }
        T{ word f 5 10 f }
    } 35 wrap [ { } like ] map
] unit-test

[
    {
        {
            T{ word f 1 10 f }
            T{ word f 2 10 f }
            T{ word f 3 9 t }
            T{ word f 3 9 t }
            T{ word f 3 9 t }
        }
        {
            T{ word f 4 10 f }
            T{ word f 5 10 f }
        }
    }
] [
    {
        T{ word f 1 10 f }
        T{ word f 2 10 f }
        T{ word f 3 9 t }
        T{ word f 3 9 t }
        T{ word f 3 9 t }
        T{ word f 4 10 f }
        T{ word f 5 10 f }
    } 35 wrap [ { } like ] map
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

[ "this text\nhas lots of\nspaces" ]
[ "this text        has lots of       spaces" 12 wrap-string ] unit-test

[ "hello\nhow\nare\nyou\ntoday?" ]
[ "hello how are you today?" 3 wrap-string ] unit-test
