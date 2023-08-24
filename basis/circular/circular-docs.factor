! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax sequences math kernel quotations ;
IN: circular

HELP: <circular-string>
{ $values
    { "n" integer }
    { "circular" circular } }
{ $description "Creates a new circular string object. A circular string is a string object that can be accessed out of bounds and the index will wrap around to the start of the string." } ;

HELP: <circular>
{ $values
    { "seq" sequence }
    { "circular" circular } }
{ $description "Creates a new " { $link circular } " object that wraps an existing sequence. By default, the index is set to zero." } ;

HELP: <growing-circular>
{ $values
    { "capacity" integer }
    { "growing-circular" growing-circular } }
{ $description "Creates a new growing-circular object." } ;

HELP: change-circular-start
{ $values
    { "n" integer } { "circular" circular } }
{ $description "Changes the start index of a circular object." } ;

HELP: circular
{ $description "A tuple class that stores a sequence and its start index." } ;

HELP: growing-circular
{ $description "A circular sequence that is growable." } ;

HELP: circular-push
{ $values
    { "elt" object } { "circular" circular } }
{ $description "Pushes an element to a " { $link circular } " object." } ;

HELP: growing-circular-push
{ $values
    { "elt" object } { "circular" circular } }
{ $description "Pushes an element onto a " { $link growing-circular } " object." } ;

HELP: rotate-circular
{ $values
    { "circular" circular } }
{ $description "Advances the start index of a circular object by one." } ;

HELP: circular-while
{ $values
    { "circular" circular }
    { "quot" quotation }
}
{ $description "Calls " { $snippet "quot" } " on each element of the sequence until each call yields " { $link f } " in succession." } ;

HELP: circular-loop
{ $values
    { "circular" circular }
    { "quot" quotation }
}
{ $description "Calls " { $snippet "quot" } " on each element of the sequence until one call yields " { $link f } "." }
{ $notes "This rotates the " { $link circular } " object after each call, so the next element to be applied will always be the first element." } ;

ARTICLE: "circular" "Circular sequences"
"The " { $vocab-link "circular" } " vocabulary implements the " { $link "sequence-protocol" } " to allow an arbitrary start index and wrap-around indexing." $nl
"Creating a new circular object:"
{ $subsections
    <circular>
    <circular-string>
    <growing-circular>
}
"Changing the start index:"
{ $subsections
    change-circular-start
    rotate-circular
}
"Pushing new elements:"
{ $subsections
    circular-push
    growing-circular-push
}
"Iterating over a circular until a stop condition:"
{ $subsections circular-while circular-loop } ;

ABOUT: "circular"
