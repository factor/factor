USING: math math.runge-kutta sequences tools.test ;
IN: runge-kutta.tests

{
V{
    { 1 2 3 } ! unchanged
    { 1+1/4 2+1/2 3+3/4 } ! addition of the previous with product of each change and the next butcher tableau row
    { 1+57/128 2+57/64 4+43/128 } ! above again for the next row and so on
    { 2+1280/2197 5+363/2197 7+1643/2197 }
    { 2+271/312 5+115/156 8+63/104 }
    { 1+489/832 3+73/416 4+635/832 }
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
