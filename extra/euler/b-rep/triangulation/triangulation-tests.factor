USING: accessors arrays euler.b-rep.examples
euler.b-rep.triangulation math.vectors.simd.cords sequences
tools.test gml kernel ;
IN: euler.b-rep.triangulation.tests

: triangle-vx-positions ( triangles -- positions )
    [ [ position>> ] { } map-as ] { } map-as ;

{
    {
        {
            double-4{ 1.0 1.0 -1.0 0.0 }
            double-4{ -1.0 -1.0 -1.0 0.0 }
            double-4{ -1.0 1.0 -1.0 0.0 }
        }
        {
            double-4{ -1.0 -1.0 -1.0 0.0 }
            double-4{ 1.0 1.0 -1.0 0.0 }
            double-4{ 1.0 -1.0 -1.0 0.0 }
        }
    }
} [ valid-cube-b-rep faces>> first triangulate-face triangle-vx-positions ] unit-test

{ { } } [ degenerate-incomplete-face faces>> first triangulate-face triangle-vx-positions ] unit-test
{ {
    {
        double-4{ 1.0 1.0 0.0 0.0 }
        double-4{ -1.0 -1.0 0.0 0.0 }
        double-4{ -1.0 1.0 0.0 0.0 }
    }
    {
        double-4{ -1.0 -1.0 0.0 0.0 }
        double-4{ 1.0 1.0 0.0 0.0 }
        double-4{ 1.0 -1.0 0.0 0.0 }
    }
} } [ partially-degenerate-second-face faces>> second triangulate-face triangle-vx-positions ] unit-test

{
    {
        {
            double-4{ -1.0 1.0 0.0 0.0 }
            double-4{ -0.5 0.5 0.0 0.0 }
            double-4{ -1.0 -1.0 0.0 0.0 }
        }
        {
            double-4{ -0.5 0.5 0.0 0.0 }
            double-4{ -1.0 1.0 0.0 0.0 }
            double-4{ 1.0 1.0 0.0 0.0 }
        }
        {
            double-4{ -0.5 0.5 0.0 0.0 }
            double-4{ 1.0 1.0 0.0 0.0 }
            double-4{ 0.5 0.5 0.0 0.0 }
        }
        {
            double-4{ 0.5 0.5 0.0 0.0 }
            double-4{ 1.0 1.0 0.0 0.0 }
            double-4{ 0.5 -0.5 0.0 0.0 }
        }
        {
            double-4{ -1.0 -1.0 0.0 0.0 }
            double-4{ -0.5 -0.5 0.0 0.0 }
            double-4{ 1.0 -1.0 0.0 0.0 }
        }
        {
            double-4{ -0.5 -0.5 0.0 0.0 }
            double-4{ -1.0 -1.0 0.0 0.0 }
            double-4{ -0.5 0.5 0.0 0.0 }
        }
        {
            double-4{ 1.0 -1.0 0.0 0.0 }
            double-4{ -0.5 -0.5 0.0 0.0 }
            double-4{ 0.5 -0.5 0.0 0.0 }
        }
        {
            double-4{ 1.0 -1.0 0.0 0.0 }
            double-4{ 0.5 -0.5 0.0 0.0 }
            double-4{ 1.0 1.0 0.0 0.0 }
        }
    }
} [
    [ "vocab:gml/examples/torus.gml" run-gml-file ] make-gml nip
    faces>> first triangulate-face triangle-vx-positions
] unit-test
