USING: bootstrap.image.primitives kernel.private sequences tools.test
vocabs words ;
IN: bootstrap.image.primitives.tests

{
    [
        B{
            112 114 105 109 105 116 105 118 101 95 104 101 108 108 111 0
        }
        do-primitive
    ]
} [
    gensym "hello" primitive-quot
] unit-test

{ t } [
    all-words [ primitive? ] filter [ foldable? ] filter [ flushable? ] all?
] unit-test
