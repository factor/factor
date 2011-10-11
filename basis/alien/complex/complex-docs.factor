USING: help.markup help.syntax math ;
IN: alien.complex

HELP: complex-float
{ $description "This C type represents a single-precision IEEE 754 floating-point complex type. Input values will be converted from Factor " { $link complex } " objects into a single-precision complex float type; output values will be returned as Factor " { $link complex } " objects." } ;
HELP: complex-double
{ $description "This C type represents a double-precision IEEE 754 floating-point complex type. Input values will be converted from Factor " { $link complex } " objects into a double-precision complex float type; output values will be returned as Factor " { $link complex } " objects." } ;

ARTICLE: "alien.complex" "C99 complex number types"
"The following C99 complex number types are defined in the " { $vocab-link "alien.complex" } " vocabulary:"
{ $table
    { { $link complex-float } { "C99 or Fortran " { $snippet "complex float" } " type, converted to and from Factor " { $link complex } " values" } }
    { { $link complex-double } { "C99 or Fortran " { $snippet "complex double" } " type, converted to and from Factor " { $link complex } " values" } }
} ;
