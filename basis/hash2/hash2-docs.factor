USING: help.syntax help.markup ;
IN: hash2

ARTICLE: { "hash2" "intro" } "Hash2"
"The hash2 vocabulary specifies a simple minimal datastructure for hash tables with two integers as keys. These hash tables are fixed size and do not conform to the associative mapping protocol. Words used in creating and manipulating these hash tables include:"
{ $subsections
    <hash2>
    hash2
    set-hash2
    alist>hash2
} ;

HELP: <hash2>
{ $values { "size" "size of the underlying array" } { "hash2" hash2 } }
{ $description "Creates a " { $link hash2 } " object with the given size of the underlying array. Initially, the hash2 contains nothing." } ;

HELP: hash2
{ $values { "a" "first key" } { "b" "second key" } { "hash2" hash2 } { "value/f" "the associated value or f" } }
{ $description "Looks up the associated value in the hash2 table with the given keys. If a value is found, it is returned, otherwise f is returned. Note that it is significant which order the keys are in." }
{ $class-description "A hash2 table, with two integers as the key for each value. Hash2 tables are of fixed size and do not conform to the associative mapping protocol." } ;

HELP: set-hash2
{ $values { "a" "first key" } { "b" "second key" } { "value" "the new value" } { "hash2" hash2 } }
{ $description "Sets the hash2 at the given key combination to the given value. Note that the order of keys is significant and that this will never grow the hash2 table. Both keys must be integers." } ;

HELP: alist>hash2
{ $values { "alist" "a sequence of the form " { $snippet "{ { a b value } ... }" } } { "size" "the size of the new underlying array" } { "hash2" hash2 } }
{ $description "Converts an association list, where the first and second elements of each inner sequence is a key and the third is the value, into a " { $link hash2 } " of the given size. Both keys must be integers." } ;
