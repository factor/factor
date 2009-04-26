! (c)2009 Joe Groff bsd license
USING: help.markup help.syntax multiline quotations sequences sequences.product ;
IN: sequences

HELP: product-sequence
{ $class-description "A class of virtual sequences that present the cartesian product of their underlying set of sequences. Product sequences are constructed with the " { $link <product-sequence> } " word." }
{ $examples
{ $example <" USING: arrays prettyprint sequences.product ;
{ { 1 2 3 } { "a" "b" "c" } } <product-sequence> >array .
"> <" {
    { 1 "a" }
    { 2 "a" }
    { 3 "a" }
    { 1 "b" }
    { 2 "b" }
    { 3 "b" }
    { 1 "c" }
    { 2 "c" }
    { 3 "c" }
}"> } } ;

HELP: <product-sequence>
{ $values { "sequences" sequence } { "product-sequence" product-sequence } }
{ $description "Constructs a " { $link product-sequence } " over " { $snippet "sequences" } "." }
{ $examples
{ $example <" USING: arrays prettyprint sequences.product ;
{ { 1 2 3 } { "a" "b" "c" } } <product-sequence> >array .
"> <" {
    { 1 "a" }
    { 2 "a" }
    { 3 "a" }
    { 1 "b" }
    { 2 "b" }
    { 3 "b" }
    { 1 "c" }
    { 2 "c" }
    { 3 "c" }
}"> } } ;

{ product-sequence <product-sequence> } related-words

HELP: product-map
{ $values { "sequences" sequence } { "quot" { $quotation "( sequence -- value )" } } { "sequence" sequence } }
{ $description "Calls " { $snippet "quot" } " for every element of the cartesian product of " { $snippet "sequences" } " and collects the results from " { $snippet "quot" } " into an output sequence." }
{ $notes { $snippet "[ ... ] product-map" } " is equivalent to, but more efficient than, " { $snippet "<product-sequence> [ ... ] map" } "." } ;

HELP: product-each
{ $values { "sequences" sequence } { "quot" { $quotation "( sequence -- )" } } }
{ $description "Calls " { $snippet "quot" } " for every element of the cartesian product of " { $snippet "sequences" } "." }
{ $notes { $snippet "[ ... ] product-each" } " is equivalent to, but more efficient than, " { $snippet "<product-sequence> [ ... ] each" } "." } ;

{ product-map product-each } related-words

ARTICLE: "sequences.product" "Product sequences"
"The " { $vocab-link "sequences.product" } " vocabulary provides a virtual sequence and combinators for manipulating the cartesian product of a set of sequences."
{ $subsection product-sequence }
{ $subsection <product-sequence> }
{ $subsection product-map }
{ $subsection product-each } ;

ABOUT: "sequences.product"
