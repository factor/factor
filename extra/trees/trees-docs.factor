USING: assocs help.markup help.syntax math ;
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

HELP: height
{ $values
    { "tree" tree }
    { "n" integer }
}
{ $description "Returns the height of " { $snippet "tree" } "." } ;

HELP: headtree>alist[)
{ $values
    { "to-key" "a key" } { "tree" tree }
    { "alist" "an array of key/value pairs" }
}
{ $description "Returns an alist of the portion of this tree whose keys are strictly less than to-key." } ;

HELP: headtree>alist[]
{ $values
    { "to-key" "a key" } { "tree" tree }
    { "alist" "an array of key/value pairs" }
}
{ $description "Returns an alist of the portion of this tree whose keys are less than or equal to to-key." } ;

HELP: subtree>alist()
{ $values
    { "from-key" "a key" } { "to-key" "a key" } { "tree" tree }
    { "alist" "an array of key/value pairs" }
}
{ $description "Returns an alist of the portion of this map whose keys range from fromKey (exclusive) to toKey (exclusive)." } ;

HELP: subtree>alist(]
{ $values
    { "from-key" "a key" } { "to-key" "a key" } { "tree" tree }
    { "alist" "an array of key/value pairs" }
}
{ $description "Returns an alist of the portion of this map whose keys range from fromKey (exclusive) to toKey (inclusive)." } ;

HELP: subtree>alist[)
{ $values
    { "from-key" "a key" } { "to-key" "a key" } { "tree" tree }
    { "alist" "an array of key/value pairs" }
}
{ $description "Returns an alist of the portion of this map whose keys range from fromKey (inclusive) to toKey (exclusive)." } ;

HELP: subtree>alist[]
{ $values
    { "from-key" "a key" } { "to-key" "a key" } { "tree" tree }
    { "alist" "an array of key/value pairs" }
}
{ $description "Returns an alist of the portion of this map whose keys range from fromKey (inclusive) to toKey (inclusive)." } ;

HELP: tailtree>alist(]
{ $values
    { "from-key" "a key" } { "tree" tree }
    { "alist" "an array of key/value pairs" }
}
{ $description "Returns an alist of the portion of this tree whose keys are strictly greater than to-key." } ;

HELP: tailtree>alist[]
{ $values
    { "from-key" "a key" } { "tree" tree }
    { "alist" "an array of key/value pairs" }
}
{ $description "Returns an alist of the portion of this tree whose keys are greater than or equal to to-key." } ;

{
    headtree>alist[) headtree>alist[] tailtree>alist(] tailtree>alist[]
    subtree>alist() subtree>alist(] subtree>alist[) subtree>alist[]
} related-words

ARTICLE: "trees" "Binary search trees"
"This is a library for unbalanced binary search trees. It is not intended to be used directly in most situations but rather as a base class for new trees, because performance can degrade to linear time storage/retrieval by the number of keys. These binary search trees conform to the assoc protocol."
{ $subsections
    tree
    <tree>
    >tree
    POSTPONE: TREE{
    height
}
"Trees support range operations:"
{ $subsections
    headtree>alist[) headtree>alist[] tailtree>alist(] tailtree>alist[]
    subtree>alist() subtree>alist(] subtree>alist[) subtree>alist[]
}
;

ABOUT: "trees"
