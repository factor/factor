USING: help.markup help.syntax sequences ;
IN: math.transforms.haar

HELP: haar
{ $values { "seq" sequence } { "seq'" sequence } }
{ $description "Haar wavelet transform function." }
{ $notes "The sequence length should be a power of two." }
{ $examples { $example "USING: math.transforms.haar prettyprint ;" "{ 7 1 6 6 3 -5 4 2 } haar ." "{ 3 2 -1 -2 3 0 4 1 }" } } ;

HELP: rev-haar
{ $values { "seq" sequence } { "seq'" sequence } }
{ $description "Reverse Haar wavelet transform function." }
{ $notes "The sequence length should be a power of two." }
{ $examples { $example "USING: math.transforms.haar prettyprint ;" "{ 3 2 -1 -2 3 0 4 1 } rev-haar ." "{ 7 1 6 6 3 -5 4 2 }" } } ;
