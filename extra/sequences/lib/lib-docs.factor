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

HELP: sigma
{ $values { "seq" sequence } { "quot" quotation } { "n" number } }
{ $description "Like map sum, but without creating an intermediate sequence." }
{ $example
    "! Find the sum of the squares [0,99]"
    "USING: math math.ranges sequences.lib prettyprint ;"
    "100 [1,b] [ sq ] sigma ."
    "338350"
} ;

HELP: count
{ $values { "seq" sequence } { "quot" quotation } { "n" integer } }
{ $description "Efficiently returns the number of elements that the predicate quotation matches." }
{ $example
    "USING: math math.ranges sequences.lib prettyprint ;"
    "100 [1,b] [ even? ] count ."
    "50"
} ;

HELP: if-seq
{ $values { "seq" sequence } { "quot1" quotation } { "quot2" quotation } }
{ $description "Makes an implicit check if the sequence is empty.  If the sequence has any elements, " { $snippet "quot1" } " is called on it.  Otherwise, the empty sequence is dropped and " { $snippet "quot2" } " is called." }
{ $example
    "USING: kernel prettyprint sequences sequences.lib ;"
    "{ 1 2 3 } [ sum ] [ \"empty sequence\" throw ] if-seq ."
    "6"
} ;

HELP: if-empty
{ $values { "seq" sequence } { "quot1" quotation } { "quot2" quotation } }
{ $description "Makes an implicit check if the sequence is empty. An empty sequence is dropped and " { $snippet "quot1" } " is called. Otherwise, if the sequence has any elements, " { $snippet "quot2" } " is called on it." }
{ $example
    "USING: kernel prettyprint sequences sequences.lib ;"
    "{ 1 2 3 } [ \"empty sequence\" ] [ sum ] if-empty ."
    "6"
} ;

{ if-seq if-empty } related-words
