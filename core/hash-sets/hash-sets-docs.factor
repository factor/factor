USING: help.markup help.syntax math sequences sets ;
IN: hash-sets

ARTICLE: "hash-sets" "Hash sets"
"The " { $vocab-link "hash-sets" } " vocabulary implements hashtable-like sets. Hash sets form a class:"
{ $subsections hash-set }
"Constructing new hash sets:"
{ $subsections <hash-set> >hash-set }
"The syntax for hash sets is described in " { $link "syntax-hash-sets" } "." ;

ABOUT: "hash-sets"

HELP: hash-set
{ $class-description "The class of hashtable-like sets. These implement the " { $link set } " mixin." } ;

HELP: <hash-set>
{ $values { "capacity" number } { "hash-set" hash-set } }
{ $description "Creates a new hash set capable of storing " { $snippet "capacity" } " elements before growing." } ;

HELP: >hash-set
{ $values { "members" sequence } { "hash-set" hash-set } }
{ $description "Creates a new hash set with the given members." } ;
