IN: persistent.sequences
USING: help.markup help.syntax math sequences kernel ;

HELP: new-nth
{ $values { "val" object } { "i" integer } { "seq" sequence } { "seq'" sequence } }
{ $contract "Persistent analogue of " { $link set-nth } ". Outputs a new sequence with the " { $snippet "i" } "th element replaced by " { $snippet "val" } "." } ;

HELP: ppush
{ $values { "val" object } { "seq" sequence } { "seq'" sequence } }
{ $contract "Persistent analogue of " { $link push } ". Outputs a new sequence with all elements of " { $snippet "seq" } " together with " { $snippet "val" } " added at the end." } ;

HELP: ppop
{ $values { "seq" sequence } { "seq'" sequence } }
{ $contract "Persistent analogue of " { $link pop* } ". Outputs a new sequence with all elements of " { $snippet "seq" } " except for the final element." } ;

ARTICLE: "persistent.sequences" "Persistent sequence protocol"
"The persistent sequence protocol consists of the non-mutating sequence protocol words, such as " { $link length } " and " { $link nth } ", together with the following operations:"
{ $subsections
    new-nth
    ppush
    ppop
}
"The default implementations of the above run in " { $snippet "O(n)" } " time; the " { $vocab-link "persistent.vectors" } " vocabulary provides an implementation of these operations in " { $snippet "O(1)" } " time." ;

ABOUT: "persistent.sequences"
