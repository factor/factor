! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test wrap.words sequences ;
IN: wrap.words.tests    

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
    } 35 35 wrap-words [ { } like ] map
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
    } 35 35 wrap-words [ { } like ] map
] unit-test

[
    {
        {
            T{ word f 1 10 t }
            T{ word f 1 10 f }
            T{ word f 3 9 t }
        }
        {
            T{ word f 2 10 f }
            T{ word f 3 9 t }
        }
        {
            T{ word f 4 10 f }
            T{ word f 5 10 f }
        }
    }
] [
    {
        T{ word f 1 10 t }
        T{ word f 1 10 f }
        T{ word f 3 9 t }
        T{ word f 2 10 f }
        T{ word f 3 9 t }
        T{ word f 4 10 f }
        T{ word f 5 10 f }
    } 35 35 wrap-words [ { } like ] map
] unit-test

