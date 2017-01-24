USING: arrays assocs help.markup help.syntax kernel math ;
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

HELP: ceiling-entry
{ $values
    { "key" "a key" } { "tree" tree }
    { "pair/f" { $maybe pair } }
}
{ $description "Returns a key-value mapping associated with the least key greater than or equal to the given key, or " { $link f } " if there is no such key." } ;

HELP: ceiling-key
{ $values
    { "key" "a key" } { "tree" tree }
    { "key/f" { $maybe "a key" } }
}
{ $description "Returns the least key greater than or equal to the given key, or " { $link f } " if there is no such key." } ;

HELP: floor-entry
{ $values
    { "key" "a key" } { "tree" tree }
    { "pair/f" { $maybe pair } }
}
{ $description "Returns a key-value mapping associated with the greatest key less than or equal to the given key, or " { $link f } " if there is no such key." } ;

HELP: floor-key
{ $values
    { "key" "a key" } { "tree" tree }
    { "key/f" { $maybe "a key" } }
}
{ $description "Returns the greatest key less than or equal to the given key, or " { $link f } " if there is no such key." } ;

HELP: higher-entry
{ $values
    { "key" "a key" } { "tree" tree }
    { "pair/f" { $maybe pair } }
}
{ $description "Returns a key-value mapping associated with the least key strictly greater than the given key, or " { $link f } " if there is no such key." } ;

HELP: higher-key
{ $values
    { "key" "a key" } { "tree" tree }
    { "key/f" { $maybe "a key" } }
}
{ $description "Returns the least key strictly greater than the given key, or " { $link f } " if there is no such key." } ;

HELP: lower-entry
{ $values
    { "key" "a key" } { "tree" tree }
    { "pair/f" { $maybe pair } }
}
{ $description "Returns a key-value mapping associated with the greatest key strictly less than the given key, or " { $link f } " if there is no such key." } ;

HELP: lower-key
{ $values
    { "key" "a key" } { "tree" tree }
    { "key/f" { $maybe "a key" } }
}
{ $description "Returns the greatest key strictly less than the given key, or " { $link f } " if there is no such key." } ;

{ lower-key lower-entry higher-key higher-entry
  floor-key floor-entry ceiling-key ceiling-entry } related-words

HELP: last-entry
{ $values
    { "tree" tree }
    { "pair/f" { $maybe pair } }
}
{ $description "Returns a key-value mapping associated with the last (highest) key in this tree, or " { $link f } " if the tree is empty." } ;

HELP: last-key
{ $values
    { "tree" tree }
    { "key/f" { $maybe "a key" } }
}
{ $description "Returns the last (highest) key in this tree, or " { $link f } " if the tree is empty." } ;

HELP: first-entry
{ $values
    { "tree" tree }
    { "pair/f" { $maybe pair } }
}
{ $description "Returns a key-value mapping associated with the first (lowest) key in this tree, or " { $link f } " if the tree is empty." } ;

HELP: first-key
{ $values
    { "tree" tree }
    { "key/f" { $maybe pair } }
}
{ $description "Returns the first (lowest) key in this tree, or " { $link f } " if the tree is empty." } ;

{ first-key first-entry last-key last-entry } related-words

ARTICLE: "trees" "Binary search trees"
"This is a library for unbalanced binary search " { $link tree } "s. It is not intended to be used directly in most situations but rather as a base class for new trees, because performance can degrade to linear time storage/retrieval by the number of keys. These binary search trees conform to the assoc protocol."
"Constructing trees:"
{ $subsections
    <tree>
    >tree
    POSTPONE: TREE{
}
"Operations on trees: "
{ $subsections
    height
    first-entry first-key
    last-entry last-key
}
"Range operations on trees:"
{ $subsections
    headtree>alist[) headtree>alist[] tailtree>alist(] tailtree>alist[]
    subtree>alist() subtree>alist(] subtree>alist[) subtree>alist[]
}
"Navigation operations on trees:"
{ $subsections
    lower-key lower-entry higher-key higher-entry
    floor-key floor-entry ceiling-key ceiling-entry
}
;

ABOUT: "trees"
