! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test wrap.words sequences ;

{ { } } [ f 35 wrap-words ] unit-test
{ { } } [ { } 35 wrap-words ] unit-test

{
    {
        {
            T{ wrapping-word f 1 10 f }
            T{ wrapping-word f 2 10 f }
            T{ wrapping-word f 3 2 t }
        }
        {
            T{ wrapping-word f 4 10 f }
            T{ wrapping-word f 5 10 f }
        }
    }
} [
    {
        T{ wrapping-word f 1 10 f }
        T{ wrapping-word f 2 10 f }
        T{ wrapping-word f 3 2 t }
        T{ wrapping-word f 4 10 f }
        T{ wrapping-word f 5 10 f }
    } 35 wrap-words [ { } like ] map
] unit-test

{
    {
        {
            T{ wrapping-word f 1 10 f }
            T{ wrapping-word f 2 10 f }
            T{ wrapping-word f 3 9 t }
            T{ wrapping-word f 3 9 t }
            T{ wrapping-word f 3 9 t }
        }
        {
            T{ wrapping-word f 4 10 f }
            T{ wrapping-word f 5 10 f }
        }
    }
} [
    {
        T{ wrapping-word f 1 10 f }
        T{ wrapping-word f 2 10 f }
        T{ wrapping-word f 3 9 t }
        T{ wrapping-word f 3 9 t }
        T{ wrapping-word f 3 9 t }
        T{ wrapping-word f 4 10 f }
        T{ wrapping-word f 5 10 f }
    } 35 wrap-words [ { } like ] map
] unit-test

{
    {
        {
            T{ wrapping-word f 1 10 t }
            T{ wrapping-word f 1 10 f }
            T{ wrapping-word f 3 9 t }
        }
        {
            T{ wrapping-word f 2 10 f }
            T{ wrapping-word f 3 9 t }
        }
        {
            T{ wrapping-word f 4 10 f }
            T{ wrapping-word f 5 10 f }
        }
    }
} [
    {
        T{ wrapping-word f 1 10 t }
        T{ wrapping-word f 1 10 f }
        T{ wrapping-word f 3 9 t }
        T{ wrapping-word f 2 10 f }
        T{ wrapping-word f 3 9 t }
        T{ wrapping-word f 4 10 f }
        T{ wrapping-word f 5 10 f }
    } 35 wrap-words [ { } like ] map
] unit-test
