USING: arrays byte-arrays help.markup help.syntax kernel combinators ;
IN: byte-vectors

ARTICLE: "byte-vectors" "Byte vectors"
"The " { $vocab-link "byte-vectors" } " vocabulary implements resizable mutable sequence of unsigned bytes. Byte vectors implement the " { $link "sequence-protocol" } " and thus all " { $link "sequences" } " can be used with them."
$nl
"Byte vectors form a class:"
{ $subsection byte-vector }
{ $subsection byte-vector? }
"Creating byte vectors:"
{ $subsection >byte-vector }
{ $subsection <byte-vector> }
"Literal syntax:"
{ $subsection POSTPONE: BV{ }
"If you don't care about initial capacity, a more elegant way to create a new byte vector is to write:"
{ $code "BV{ } clone" } ;

ABOUT: "byte-vectors"

HELP: byte-vector
{ $description "The class of resizable byte vectors. See " { $link "byte-vectors" } " for information." } ;

HELP: <byte-vector>
{ $values { "n" "a positive integer specifying initial capacity" } { "byte-vector" byte-vector } }
{ $description "Creates a new byte vector that can hold " { $snippet "n" } " bytes before resizing." } ;

HELP: >byte-vector
{ $values { "seq" "a sequence" } { "byte-vector" byte-vector } }
{ $description "Outputs a freshly-allocated byte vector with the same elements as a given sequence." }
{ $errors "Throws an error if the sequence contains elements other than integers." } ;

HELP: BV{
{ $syntax "BV{ elements... }" }
{ $values { "elements" "a list of bytes" } }
{ $description "Marks the beginning of a literal byte vector. Literal byte vectors are terminated by " { $link POSTPONE: } } "." } 
{ $examples { $code "BV{ 1 2 3 12 }" } } ;
