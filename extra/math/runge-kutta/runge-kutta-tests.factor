USING: math math.runge-kutta sequences tools.test ;
IN: runge-kutta.tests

{
    V{
        { 0x1.0p0 0x1.0p1 0x1.8p1 }
        { 0x1.38e38e4p0 0x1.38e38e4p1 0x1.d555556p1 }
        { 0x1.638e38fp0 0x1.638e38fp1 0x1.0aaaaab4p2 }
        { 0x1.130000066p1 0x1.130000066p2 0x1.9c8000099p2 }
        {
            0x1.50000036c16cp1
            0x1.50000036c16cp2
            0x1.f800005222224p2
        }
        {
            0x1.2738e3b2d87e7p1
            0x1.2738e3b2d87e7p2
            0x1.bad5558c44bdbp2
        }
    }
}
[ 1 { [ first ] [ second ] [ third ] } { 1 2 3 0 } runge-kutta-stages ] unit-test

{
    ! multiplies each axis by the corresponding coefficents, then sums each axis
    { 10+619453/843648 21+197629/421824 32+57021/281216 }
}
[ V{ { 1 2 3 }
    { 1+1/4 2+1/2 3+3/4 }
    { 1+57/128 2+57/64 4+43/128 }
    { 2+1280/2197 5+363/2197 7+1643/2197 }
    { 2+271/312 5+115/156 8+63/104 }
    { 1+489/832 3+73/416 4+635/832 } } { 1 1 1 1 1 1 } (rk) ] unit-test
