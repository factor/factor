USING: help.markup help.syntax memory tools.memory sequences vm ;
IN: tools.memory

ARTICLE: "tools.memory" "Object memory tools"
"You can print object heap status information:"
{ $subsections
    room.
    heap-stats.
    heap-stats
}
"You can query memory status:"
{ $subsections
    data-room
    code-room
}
"A combinator to get objects from the heap:"
{ $subsections instances }
"You can check an object's the heap memory usage:"
{ $subsections size }
"The garbage collector can be invoked manually:"
{ $subsections gc }
{ $see-also "images" } ;

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

HELP: gc-events.
{ $description "Prints all garbage collection events that took place during the last call to " { $link collect-gc-events } "." } ;

HELP: gc-stats.
{ $description "Prints a breakdown of different garbage collection events that took place during the last call to " { $link collect-gc-events } "." } ;

HELP: gc-summary.
{ $description "Prints aggregate garbage collection statistics from the last call to " { $link collect-gc-events } "." } ;

HELP: gc-events
{ $var-description "A sequence of " { $link gc-event } " instances, set by " { $link collect-gc-events } ". Can be inspected directly, or with the " { $link gc-events. } ", " { $link gc-stats. } " and " { $link gc-summary. } " words." } ;

HELP: data-room
{ $values { "data-heap-room" data-heap-room } }
{ $description "Queries the VM for memory usage in the data heap." } ;

HELP: code-room
{ $values { "mark-sweep-sizes" mark-sweep-sizes } }
{ $description "Queries the VM for memory usage in the code heap." } ;

HELP: callback-room
{ $values { "mark-sweep-sizes" mark-sweep-sizes } }
{ $description "Queries the VM for memory usage in the callback heap." } ;
