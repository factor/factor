USING: help.markup help.syntax memory sequences ;
IN: tools.memory

ARTICLE: "tools.memory" "Object memory tools"
"You can print object heap status information:"
{ $subsection room. }
{ $subsection heap-stats. }
{ $subsection heap-stats }
"You can query memory status:"
{ $subsection data-room }
{ $subsection code-room }
"There are a pair of combinators, analogous to " { $link each } " and " { $link subset } ", which operate on the entire collection of objects in the object heap:"
{ $subsection each-object }
{ $subsection instances }
"You can check an object's the heap memory usage:"
{ $subsection size }
"The garbage collector can be invoked manually:"
{ $subsection data-gc }
{ $subsection code-gc }
{ $see-also "image" } ;

ABOUT: "tools.memory"

HELP: room.
{ $description "Prints an overview of memory usage broken down by generation and zone." } ;

{ data-room code-room room. } related-words

HELP: heap-stats
{ $values { "counts" "an assoc mapping class words to integers" } { "sizes" "an assoc mapping class words to integers" } }
{ $description "Outputs a pair of assocs holding class instance counts and instance memory usage, respectively." } ;

HELP: heap-stats.
{ $description "For each class, prints the number of instances and total memory consumed by those instances." } ;

{ heap-stats heap-stats. } related-words
