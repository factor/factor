USING: images accessors kernel tools.test literals math.ranges
byte-arrays ;
IN: images.tesselation

! Check an invariant we depend on
[ t ] [
    <image> B{ 1 2 3 } >>bitmap dup clone [ bitmap>> ] bi@ eq?
] unit-test

[
    {
        {
            T{ image f { 2 2 } L f B{ 1 2 5 6 } }
            T{ image f { 2 2 } L f B{ 3 4 7 8 } }
        }
        {
            T{ image f { 2 2 } L f B{ 9 10 13 14 } }
            T{ image f { 2 2 } L f B{ 11 12 15 16 } }
        }
    }
] [
    <image>
        1 16 [a,b] >byte-array >>bitmap
        { 4 4 } >>dim
        L >>component-order
    { 2 2 } tesselate
] unit-test

[
    {
        {
            T{ image f { 2 2 } L f B{ 1 2 4 5 } }
            T{ image f { 1 2 } L f B{ 3 6 } }
        }
        {
            T{ image f { 2 1 } L f B{ 7 8 } }
            T{ image f { 1 1 } L f B{ 9 } }
        }
    }
] [
    <image>
        1 9 [a,b] >byte-array >>bitmap
        { 3 3 } >>dim
        L >>component-order
    { 2 2 } tesselate
] unit-test