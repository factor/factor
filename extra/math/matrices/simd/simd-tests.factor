! Copyright (C) 2009, 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: classes.struct math.matrices.simd math.vectors.simd math
literals math.constants math.functions specialized-arrays tools.test ;
QUALIFIED-WITH: alien.c-types c
FROM: math.matrices => m~ ;
SPECIALIZED-ARRAY: float-4

{
    S{ matrix4 f
        float-4-array{
            float-4{ 3.0 0.0 0.0 0.0 }
            float-4{ 0.0 4.0 0.0 0.0 }
            float-4{ 0.0 0.0 2.0 0.0 }
            float-4{ 0.0 0.0 0.0 1.0 }
        }
    }
} [ float-4{ 3.0 4.0 2.0 0.0 } scale-matrix4 ] unit-test

{
    S{ matrix4 f
        float-4-array{
            float-4{ 1/8. 0.0  0.0  0.0 }
            float-4{ 0.0  1/4. 0.0  0.0 }
            float-4{ 0.0  0.0  1/2. 0.0 }
            float-4{ 0.0  0.0  0.0  1.0 }
        }
    }
} [ float-4{ 8.0 4.0 2.0 0.0 } ortho-matrix4 ] unit-test

{
    S{ matrix4 f
        float-4-array{
            float-4{ 0.0 0.0 -1.0 0.0 }
            float-4{ 1.0 0.0  0.0 0.0 }
            float-4{ 0.0 1.0  0.0 0.0 }
            float-4{ 3.0 4.0  2.0 1.0 }
        }
    }
} [
    S{ matrix4 f
        float-4-array{
            float-4{  0.0 1.0 0.0 3.0 }
            float-4{  0.0 0.0 1.0 4.0 }
            float-4{ -1.0 0.0 0.0 2.0 }
            float-4{  0.0 0.0 0.0 1.0 }
        }
    } transpose-matrix4
] unit-test

{
    S{ matrix4 f
        float-4-array{
            float-4{ 1.0 0.0 0.0 0.0 }
            float-4{ 0.0 1.0 0.0 0.0 }
            float-4{ 0.0 0.0 1.0 0.0 }
            float-4{ 3.0 4.0 2.0 1.0 }
        }
    }
} [ float-4{ 3.0 4.0 2.0 0.0 } translation-matrix4 ] unit-test

{ t } [
    float-4{ $[ 1/2. sqrt ] 0.0 $[ 1/2. sqrt ] 0.0 } pi rotation-matrix4
    S{ matrix4 f
        float-4-array{
            float-4{  0.0  0.0  1.0 0.0 }
            float-4{  0.0 -1.0  0.0 0.0 }
            float-4{  1.0  0.0  0.0 0.0 }
            float-4{  0.0  0.0  0.0 1.0 }
        }
    }
    1.0e-7 m~
] unit-test

{ t } [
    float-4{ 0.0 1.0 0.0 1.0 } pi 1/2. * rotation-matrix4
    S{ matrix4 f
        float-4-array{
            float-4{  0.0  0.0 -1.0 0.0 }
            float-4{  0.0  1.0  0.0 0.0 }
            float-4{  1.0  0.0  0.0 0.0 }
            float-4{  0.0  0.0  0.0 1.0 }
        }
    }
    1.0e-7 m~
] unit-test

{
    S{ matrix4 f
        float-4-array{
            float-4{  2.0  0.0  0.0  0.0 }
            float-4{  0.0  3.0  0.0  0.0 }
            float-4{  0.0  0.0  4.0  0.0 }
            float-4{ 10.0 18.0 28.0  1.0 }
        }
    }
} [
    S{ matrix4 f
        float-4-array{
            float-4{ 2.0 0.0 0.0 0.0 }
            float-4{ 0.0 3.0 0.0 0.0 }
            float-4{ 0.0 0.0 4.0 0.0 }
            float-4{ 0.0 0.0 0.0 1.0 }
        }
    }
    S{ matrix4 f
        float-4-array{
            float-4{ 1.0 0.0 0.0 0.0 }
            float-4{ 0.0 1.0 0.0 0.0 }
            float-4{ 0.0 0.0 1.0 0.0 }
            float-4{ 5.0 6.0 7.0 1.0 }
        }
    }
    m4.
] unit-test

{
    S{ matrix4 f
        float-4-array{
            float-4{ 3.0 0.0 0.0 0.0 }
            float-4{ 0.0 4.0 0.0 0.0 }
            float-4{ 0.0 0.0 5.0 0.0 }
            float-4{ 5.0 6.0 7.0 2.0 }
        }
    }
} [
    S{ matrix4 f
        float-4-array{
            float-4{ 2.0 0.0 0.0 0.0 }
            float-4{ 0.0 3.0 0.0 0.0 }
            float-4{ 0.0 0.0 4.0 0.0 }
            float-4{ 0.0 0.0 0.0 1.0 }
        }
    }
    S{ matrix4 f
        float-4-array{
            float-4{ 1.0 0.0 0.0 0.0 }
            float-4{ 0.0 1.0 0.0 0.0 }
            float-4{ 0.0 0.0 1.0 0.0 }
            float-4{ 5.0 6.0 7.0 1.0 }
        }
    }
    m4+
] unit-test

{
    S{ matrix4 f
        float-4-array{
            float-4{  1.0  0.0  0.0 0.0 }
            float-4{  0.0  2.0  0.0 0.0 }
            float-4{  0.0  0.0  3.0 0.0 }
            float-4{ -5.0 -6.0 -7.0 0.0 }
        }
    }
} [
    S{ matrix4 f
        float-4-array{
            float-4{ 2.0 0.0 0.0 0.0 }
            float-4{ 0.0 3.0 0.0 0.0 }
            float-4{ 0.0 0.0 4.0 0.0 }
            float-4{ 0.0 0.0 0.0 1.0 }
        }
    }
    S{ matrix4 f
        float-4-array{
            float-4{ 1.0 0.0 0.0 0.0 }
            float-4{ 0.0 1.0 0.0 0.0 }
            float-4{ 0.0 0.0 1.0 0.0 }
            float-4{ 5.0 6.0 7.0 1.0 }
        }
    }
    m4-
] unit-test

{
    S{ matrix4 f
        float-4-array{
            float-4{ 3.0 0.0 0.0 15.0 }
            float-4{ 0.0 3.0 0.0 18.0 }
            float-4{ 0.0 0.0 3.0 21.0 }
            float-4{ 0.0 0.0 0.0  3.0 }
        }
    }
} [
    S{ matrix4 f
        float-4-array{
            float-4{ 1.0 0.0 0.0 5.0 }
            float-4{ 0.0 1.0 0.0 6.0 }
            float-4{ 0.0 0.0 1.0 7.0 }
            float-4{ 0.0 0.0 0.0 1.0 }
        }
    }
    3.0 m4*n
] unit-test

{
    S{ matrix4 f
        float-4-array{
            float-4{ 3.0 0.0 0.0 15.0 }
            float-4{ 0.0 3.0 0.0 18.0 }
            float-4{ 0.0 0.0 3.0 21.0 }
            float-4{ 0.0 0.0 0.0  3.0 }
        }
    }
} [
    3.0
    S{ matrix4 f
        float-4-array{
            float-4{ 1.0 0.0 0.0 5.0 }
            float-4{ 0.0 1.0 0.0 6.0 }
            float-4{ 0.0 0.0 1.0 7.0 }
            float-4{ 0.0 0.0 0.0 1.0 }
        }
    }
    n*m4
] unit-test

{
    S{ matrix4 f
        float-4-array{
            float-4{ 1/2. 0.0   0.0   0.0 }
            float-4{ 0.0  1/2.  0.0   0.0 }
            float-4{ 0.0  0.0  -6/4. -1.0 }
            float-4{ 0.0  0.0 -10/4.  0.0 }
        }
    }
} [
    float-4{ 2.0 2.0 0.0 0.0 } 1.0 5.0
    frustum-matrix4
] unit-test

{ float-4{ 3.0 4.0 5.0 1.0 } }
[ float-4{ 1.0 1.0 1.0 1.0 } translation-matrix4 float-4{ 2.0 3.0 4.0 1.0 } m4.v ] unit-test

{ float-4{ 2.0 2.5 3.0 1.0 } }
[
    float-4{ 1.0 1.0 1.0 1.0 } translation-matrix4
    float-4{ 0.5 0.5 0.5 1.0 } scale-matrix4 m4.
    float-4{ 2.0 3.0 4.0 1.0 } m4.v
] unit-test

{
    S{ matrix4 f
        float-4-array{
            float-4{ 1.0  0.0  0.0  0.0 }
            float-4{ 0.0  1.0  0.0  0.0 }
            float-4{ 0.0  0.0  1.0  0.0 }
            float-4{ 0.0  0.0  0.0  1.0 }
        }
    }
} [
    float-4{ 1.0 0.0 0.0 0.0 } q>matrix4
] unit-test

{ t } [
    pi 0.5 * 0.0 0.0 euler4 q>matrix4
    S{ matrix4 f
        float-4-array{
            float-4{ 1.0  0.0  0.0  0.0 }
            float-4{ 0.0  0.0  1.0  0.0 }
            float-4{ 0.0 -1.0  0.0  0.0 }
            float-4{ 0.0  0.0  0.0  1.0 }
        }
    }
    1.0e-7 m~
] unit-test

{ t } [
    0.0 pi 0.25 * 0.0 euler4 q>matrix4
    S{ matrix4 f
        float-4-array{
            float-4{ $[ 1/2. sqrt ] 0.0 $[ 1/2. sqrt neg ] 0.0 }
            float-4{ 0.0            1.0 0.0                0.0 }
            float-4{ $[ 1/2. sqrt ] 0.0 $[ 1/2. sqrt     ] 0.0 }
            float-4{ 0.0            0.0 0.0                1.0 }
        }
    }
    1.0e-7 m~
] unit-test
