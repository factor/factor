USING: help.markup help.syntax sequences ;
IN: hash-sets

ARTICLE: "hash-sets" "Hash sets"
"The " { $vocab-link "hash-sets" } " vocabulary implements hashtable-backed sets. Hash sets form a class:"
{ $subsection hash-set }
"Constructing new hash sets:"
{ $subsection <hash-set> }
"The syntax for hash sets is described in " { $link "syntax-hash-sets" } "." ;

ABOUT: "hash-sets"

HELP: hash-set
{ $class-description "The class of hashtable-based sets. These implement the " { $link "sets" } "." } ;

HELP: <hash-set>
{ $values { "members" sequence } { "hash-set" hash-set } }
{ $description "Creates a new hash set with the given members." } ;
