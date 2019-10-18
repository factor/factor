USING: help.markup help.syntax math sequences
sequences.complex ;
IN: sequences.complex

ARTICLE: "sequences.complex" "Complex virtual sequences"
"The " { $link complex-sequence } " class wraps a sequence of " { $link real } " number values, presenting a sequence of " { $link complex } " values made by treating the underlying sequence as pairs of alternating real and imaginary values."
{ $subsections
    complex-sequence
    <complex-sequence>
} ;

ABOUT: "sequences.complex"

HELP: complex-sequence
{ $class-description "Sequence wrapper class that transforms a sequence of " { $link real } " number values into a sequence of " { $link complex } " values, treating the underlying sequence as pairs of alternating real and imaginary values." }
{ $examples { $example "USING: prettyprint specialized-arrays
sequences.complex sequences alien.c-types arrays ;
SPECIALIZED-ARRAY: double
double-array{ 1.0 -1.0 -2.0 2.0 3.0 0.0 } <complex-sequence> >array ."
"{ C{ 1.0 -1.0 } C{ -2.0 2.0 } C{ 3.0 0.0 } }" } } ;

HELP: <complex-sequence>
{ $values { "sequence" sequence } { "complex-sequence" complex-sequence } }
{ $description "Wraps " { $snippet "sequence" } " in a " { $link complex-sequence } "." }
{ $examples { $example "USING: prettyprint specialized-arrays
sequences.complex sequences alien.c-types arrays ;
SPECIALIZED-ARRAY: double
double-array{ 1.0 -1.0 -2.0 2.0 3.0 0.0 } <complex-sequence> second ."
"C{ -2.0 2.0 }" } } ;

{ complex-sequence <complex-sequence> } related-words
