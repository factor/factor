USING: help.syntax help.markup assocs ;
IN: trees.avl 

HELP: AVL{
{ $syntax "AVL{ { key value }... }" }
{ $values { "key" "a key" } { "value" "a value" } }
{ $description "Literal syntax for an AVL tree." } ;

HELP: <avl>
{ $values { "tree" avl } }
{ $description "Creates an empty AVL tree" } ;

HELP: >avl
{ $values { "assoc" assoc } { "avl" avl } }
{ $description "Converts any " { $link assoc } " into an AVL tree." } ;

HELP: avl
{ $class-description "This is the class for AVL trees. These conform to the assoc protocol and have efficient (logarithmic time) storage and retrieval operations." } ;

ARTICLE: "trees.avl" "AVL trees"
"This is a library for AVL trees, with logarithmic time storage and retrieval operations. These trees conform to the assoc protocol."
{ $subsections
    avl
    <avl>
    >avl
    POSTPONE: AVL{
} ;

ABOUT: "trees.avl"
