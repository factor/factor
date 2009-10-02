USING: help.syntax help.markup assocs ;
IN: trees

HELP: TREE{
{ $syntax "TREE{ { key value }... }" }
{ $values { "key" "a key" } { "value" "a value" } }
{ $description "Literal syntax for an unbalanced tree." } ;

HELP: <tree>
{ $values { "tree" tree } }
{ $description "Creates an empty unbalanced binary tree" } ;

HELP: >tree
{ $values { "assoc" assoc } { "tree" tree } }
{ $description "Converts any " { $link assoc } " into an unbalanced binary tree." } ;

HELP: tree
{ $class-description "This is the class for unbalanced binary search trees. It is not usually intended to be used directly but rather as a basis for other trees." } ;

ARTICLE: "trees" "Binary search trees"
"This is a library for unbalanced binary search trees. It is not intended to be used directly in most situations but rather as a base class for new trees, because performance can degrade to linear time storage/retrieval by the number of keys. These binary search trees conform to the assoc protocol."
{ $subsections
    tree
    <tree>
    >tree
    POSTPONE: TREE{
} ;

ABOUT: "trees"
