USING: gml.viewer math.vectors.simd.cords tools.test ;

{ {
    double-4{ 0 0 0 0 }
    double-4{ 1 1 1 1 }
} } [ { double-4{ 0 0 0 0 } { double-4{ 1 1 1 1 } 2 } 3 } selected-vectors ] unit-test
