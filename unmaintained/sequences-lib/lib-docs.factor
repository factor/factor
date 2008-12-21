USING: help.syntax help.markup kernel prettyprint sequences
quotations math ;
IN: sequences.lib

HELP: map-withn
{ $values { "seq" sequence } { "quot" quotation } { "n" number } { "newseq" sequence } }
{ $description "A generalisation of " { $link map } ". The first " { $snippet "n" } " items after the quotation will be "
"passed to the quotation given to map-withn for each element in the sequence."
} 
{ $examples
  { $example "USING: math sequences.lib prettyprint ;" "1 2 3 4 { 6 7 8 9 10 } [ + + + + ] 4 map-withn .s" "{ 16 17 18 19 20 }" }
}
{ $see-also each-withn } ;

HELP: each-withn
{ $values { "seq" sequence } { "quot" quotation } { "n" number } }
{ $description "A generalisation of " { $link each } ". The first " { $snippet "n" } " items after the quotation will be "
"passed to the quotation given to each-withn for each element in the sequence."
} 
{ $see-also map-withn } ;

HELP: randomize
{ $values { "seq" sequence } { "seq'" sequence } }
{ $description "Shuffle the elements in the sequence randomly, returning the new sequence." } ;

HELP: enumerate
{ $values { "seq" sequence } { "seq'" sequence } }
{ $description "Returns a new sequence where each element is an array of { index, value }" } ;

