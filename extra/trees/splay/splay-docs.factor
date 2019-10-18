USING: assocs help.markup help.syntax trees ;
IN: trees.splay

HELP: SPLAY{
{ $syntax "SPLAY{ { key value }... }" }
{ $values { "key" "a key" } { "value" "a value" } }
{ $description "Literal syntax for an splay tree." } ;

HELP: <splay>
{ $values { "tree" splay } }
{ $description "Creates an empty splay tree" } ;

HELP: >splay
{ $values { "assoc" assoc } { "tree" splay } }
{ $description "Converts any " { $link assoc } " into an splay tree. If the input assoc is any kind of " { $link tree } ", the elements are added in reverse level order (reverse breadth-first search) to attempt to copy it's shape." } ;

HELP: splay
{ $class-description "This is the class for splay trees. Splay trees have amortized average-case logarithmic time storage and retrieval operations, and better complexity on more skewed lookup distributions, though in bad situations they can degrade to linear time, resembling a linked list. These conform to the assoc protocol." } ;

ARTICLE: "trees.splay" "Splay trees"
"This is a library for splay trees. Splay trees have amortized average-case logarithmic time storage and retrieval operations, and better complexity on more skewed lookup distributions, though in bad situations they can degrade to linear time, resembling a linked list. These trees conform to the assoc protocol."
{ $subsections
    splay
    <splay>
    >splay
    POSTPONE: SPLAY{
} ;

ABOUT: "trees.splay"
