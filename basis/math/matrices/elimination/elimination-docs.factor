USING: help.markup help.syntax math sequences ;

IN: math.matrices.elimination

HELP: inverse
{ $values { "matrix" sequence } { "matrix" sequence } }
{ $description "Computes the multiplicative inverse of a matrix. Assuming the matrix is invertible." }
{ $examples
  "A matrix multiplied by its inverse is the identity matrix."
  { $example
    "USING: math.matrices math.matrices.elimination prettyprint ;"
    "{ { 3 4 } { 7 9 } } dup inverse m. 2 identity-matrix = ."
    "t"
  }
} ;

HELP: echelon
{ $values { "matrix" sequence } { "matrix'" sequence } }
{ $description "Computes the reduced row-echelon form of the matrix." } ;

HELP: nonzero-rows
{ $values { "matrix" sequence } { "matrix'" sequence } }
{ $description "Removes all all-zero rows from the matrix" }
{ $examples
  { $example
    "USING: math.matrices.elimination prettyprint ;"
    "{ { 0 0 } { 5 6 } { 0 0 } { 4 0 } } nonzero-rows ."
    "{ { 5 6 } { 4 0 } }"
  }
} ;

HELP: leading
{ $values
  { "seq" sequence }
  { "n" "the index of the first match, or " { $snippet f } "." }
  { "elt" "the first non-zero element, or " { $snippet f } "." }
}
{ $description "Find the first non-zero element of a sequence." } ;
