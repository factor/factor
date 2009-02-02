IN: wrap.tests
USING: tools.test wrap multiline sequences ;
    
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