USING: help.markup help.syntax math
sequences sequences.complex-components ;
IN: sequences.complex-components

ARTICLE: "sequences.complex-components" "Complex component virtual sequences"
"The " { $link complex-components } " class wraps a sequence of " { $link complex } " number values, presenting a sequence of " { $link real } " values made by interleaving the real and imaginary parts of the complex values in the original sequence."
{ $subsections
    complex-components
    <complex-components>
} ;

ABOUT: "sequences.complex-components"

HELP: complex-components
{ $class-description "Sequence wrapper class that transforms a sequence of " { $link complex } " number values into a sequence of " { $link real } " values, interleaving the real and imaginary parts of the complex values in the original sequence." }
{ $examples { $example "USING: prettyprint sequences arrays sequences.complex-components ;
{ C{ 1.0 -1.0 } -2.0 C{ 3.0 1.0 } } <complex-components> >array ."
"{ 1.0 -1.0 -2.0 0 3.0 1.0 }" } } ;

HELP: <complex-components>
{ $values { "sequence" sequence } { "complex-components" complex-components } }
{ $description "Wraps " { $snippet "sequence" } " in a " { $link complex-components } " wrapper." }
{ $examples
{ $example "USING: prettyprint sequences arrays
sequences.complex-components ;
{ C{ 1.0 -1.0 } -2.0 C{ 3.0 1.0 } } <complex-components> third ."
"-2.0" }
{ $example "USING: prettyprint sequences arrays
sequences.complex-components ;
{ C{ 1.0 -1.0 } -2.0 C{ 3.0 1.0 } } <complex-components> fourth ."
"0" }
} ;

{ complex-components <complex-components> } related-words
