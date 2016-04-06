USING: gml.viewer math.vectors.simd.cords tools.test ;
IN: gml.viewer.tests

{ {
    double-4{ 0 0 0 0 }
    double-4{ 1 1 1 1 }
} } [ { double-4{ 0 0 0 0 } { double-4{ 1 1 1 1 } 2 } 3 } selected-vectors ] unit-test
