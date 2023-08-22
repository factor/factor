! Copyright (C) 2018 Björn Lindqvist
! See https://factorcode.org/license.txt for BSD license
USING: help.markup help.syntax ;
IN: math.affine-transforms

ARTICLE: "math.affine-transforms" "Affine Transformations of 2d Vectors"
"This vocab provides words for affine transformations of 2d vectors. It can sometimes be more suitable to use the words in this vocab, than setting up the affine transformation matrices manually."
{ $examples
  "Creates a 45 degree counter clock-wise rotation matrix and applies it to a vector:"
  { $example
    "USING: math.affine-transforms math.trig prettyprint ;\n45 deg>rad <rotation> { 0 4 } a.v ."
    "{ -2.82842712474619 2.82842712474619 }"
  }
  "Applies a combined scaling and translation transform to a vector:"
  { $example
    "USING: math.affine-transforms math.trig prettyprint ;\n{ 0 -5 } <translation> 1 2  <scale>  a. { 4 3 } a.v ."
    "{ 4.0 1.0 }"
  }
} ;

ABOUT: "math.affine-transforms"
