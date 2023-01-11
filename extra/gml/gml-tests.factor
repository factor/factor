USING: accessors combinators gml tools.test kernel sequences
euler.b-rep ;

[ [ "vocab:gml/test-core.gml" run-gml-file ] make-gml ] must-not-fail

[ [ "vocab:gml/test-coremath.gml" run-gml-file ] make-gml ] must-not-fail

[ [ "vocab:gml/test-geometry.gml" run-gml-file ] make-gml ] must-not-fail

{ } [
    [ "vocab:gml/examples/cube.gml" run-gml-file ] make-gml nip
    {
        [ check-b-rep ]
        [ faces>> length 9 assert= ]
        [ vertices>> length 9 assert= ]
        [ edges>> length 32 assert= ]
        [ genus 0 assert= ]
    } cleave
] unit-test

{ } [
    [ "vocab:gml/examples/torus.gml" run-gml-file ] make-gml nip
    {
        [ check-b-rep ]
        [ faces>> [ base-face? ] partition [ length 10 assert= ] [ length 2 assert= ] bi* ]
        [ vertices>> length 16 assert= ]
        [ edges>> length 48 assert= ]
        ! faces are not convex in this example
        ! [ genus 1 assert= ]
    } cleave
] unit-test

{ } [
    [ "vocab:gml/examples/mobius.gml" run-gml-file ] make-gml nip
    {
        [ check-b-rep ]
        [ genus 1 assert= ]
    } cleave
] unit-test
