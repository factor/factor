! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax math ;
IN: math.splines

HELP: <bezier-curve>
{ $values
    { "control-points" "sequence of control points same dimension" }
    { "polynomials" "sequence of polynomials for each dimension" }
}
{ $description "Creates bezier curve polynomials for the given control points." } ;

HELP: <catmull-rom-spline>
{ $values
    { "points" "points on the spline" } { "m0" "initial tangent vector" } { "mn" "final tangent vector" }
    { "polynomials-sequence" "sequence of sequences of polynomials" }
}
{ $description "Creates a sequence of cubic hermite curves (each a sequence of polynomials) passing through the given points and generating tangents for C1 continuity." } ;

HELP: <cubic-hermite-curve>
{ $values
    { "p0" "start point" } { "m0" "start tangent" } { "p1" "end point" } { "m1" "end tangent" }
    { "polynomials" "sequence of polynomials" }
}
{ $description "Creates a sequence of polynomials (one per dimension) for the curve passing through " { $emphasis "p0" } " and " { $emphasis "p1" } "." } ;

HELP: <cubic-hermite-spline>
{ $values
    { "point-tangent-pairs" "sequence of point and tangent pairs" }
    { "polynomials-sequence" "sequence of sequences of polynomials" }
}
{ $description "Creates a sequence of cubic hermite curves (each a sequence of polynomials) passing through the given points with the given tangents." } ;

HELP: <kochanek-bartels-curve>
{ $values
    { "points" "points on the spline" } { "m0" "start tangent" } { "mn" "end tangent" } { "tension" number } { "bias" number } { "continuity" number }
    { "polynomials-sequence" "sequence of sequence of polynomials" }
}
{ $description "Creates a sequence of cubic hermite curves (each a sequence of polynomials) passing through the given points, generating tangents with the given tuning parameters." } ;

ARTICLE: "math.splines" "Common parametric curves."
"The curve creating functions create sequences of polynomials, one for each degree of the input points. The spline creating functions create sequences of these curve polynomial sequences. The " { $vocab-link "math.splines.viewer" } " vocabulary provides a gadget to evaluate the generated polynomials and view the results." ;

ABOUT: "math.splines"
