USING: math.vectors.simd math.vectors.simd.cords tools.test ;
IN: math.vectors.simd.cords.tests

{ float-4{ 1.0 2.0 3.0 4.0 } } [ double-4{ 1.0 2.0 3.0 4.0 } >float-4 ] unit-test
