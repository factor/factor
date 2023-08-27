USING: math.private kernel combinators accessors arrays
generalizations sequences.generalizations tools.test words ;
IN: compiler.tests.spilling

! These tests are stupid and don't trigger spilling anymore

: float-spill-bug ( a -- b b b b b b b b b b b b b b b b b b b b b b b b b b b b b b b b b b b b b b )
    {
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
    } cleave ;

{ 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 }
[ 1.0 float-spill-bug ] unit-test

{ t } [ \ float-spill-bug word-optimized? ] unit-test

: float-fixnum-spill-bug ( object -- object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object )
    {
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
    } cleave ;

{ 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 }
[ 1.0 float-fixnum-spill-bug ] unit-test

{ t } [ \ float-fixnum-spill-bug word-optimized? ] unit-test

: resolve-spill-bug ( a b -- c )
    [ 1 fixnum+fast ] bi@ dup 10 fixnum< [
        nip 2 fixnum+fast
    ] [
        drop {
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
        } cleave
        16 narray
    ] if ;

{ t } [ \ resolve-spill-bug word-optimized? ] unit-test

{ 4 } [ 1 1 resolve-spill-bug ] unit-test

: spill-test-1 ( a -- b )
    dup 1 fixnum+fast
    dup 1 fixnum+fast
    dup 1 fixnum+fast
    dup 1 fixnum+fast
    dup 1 fixnum+fast
    dup 1 fixnum+fast
    dup 1 fixnum+fast
    dup 1 fixnum+fast
    dup 1 fixnum+fast
    dup 1 fixnum+fast
    dup 1 fixnum+fast
    dup 1 fixnum+fast
    dup 1 fixnum+fast
    dup 1 fixnum+fast
    dup 1 fixnum+fast
    dup 1 fixnum+fast
    dup 1 fixnum+fast
    dup 1 fixnum+fast
    dup 1 fixnum+fast
    dup 1 fixnum+fast
    dup 1 fixnum+fast
    dup 1 fixnum+fast
    dup 1 fixnum+fast
    dup 1 fixnum+fast
    dup 1 fixnum+fast
    dup 1 fixnum+fast
    dup 1 fixnum+fast
    dup 1 fixnum+fast
    dup 1 fixnum+fast fixnum>float
    3array
    3array [ 8 narray ] dip 2array
    [ 8 narray [ 8 narray ] dip 2array ] dip 2array
    2array ;

{
    {
        1
        {
            { { 2 3 4 5 6 7 8 9 } { 10 11 12 13 14 15 16 17 } }
            {
                { 18 19 20 21 22 23 24 25 }
                { 26 27 { 28 29 30.0 } }
            }
        }
    }
} [ 1 spill-test-1 ] unit-test

: spill-test-2 ( a -- b )
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    dup 1.0 float+
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float*
    float* ;

{ t } [ 1.0 spill-test-2 1.0 \ spill-test-2 def>> call = ] unit-test
