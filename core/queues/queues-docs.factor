USING: help.markup help.syntax kernel ;
IN: queues

ARTICLE: "queues" "Queues"
"Last-in-first-out queues are defined in the " { $vocab-link "queues" } " vocabulary."
$nl
"Queues are a class."
{ $subsection queue }
{ $subsection queue? }
{ $subsection <queue> }
"Testing queues:"
{ $subsection queue-empty? }
"Adding elements:"
{ $subsection deque }
"Removing elements:"
{ $subsection enque }
{ $subsection clear-queue }
{ $subsection queue-each }
"An example:"
{ $code
    "<queue> \"q\" set"
    "5 \"q\" get enque"
    "3 \"q\" get enque"
    "7 \"q\" get enque"
    "\"q\" get deque ."
    "  5"
    "\"q\" get deque ."
    "  3"
    "\"q\" get deque ."
    "  7"
} ;

ABOUT: "queues"

HELP: queue
{ $class-description "A simple first-in-first-out queue. See " { $link "queues" } "." } ;

HELP: entry
{ $class-description "The class of entries in a " { $link queue } ". Each entry holds an object and a reference to the next entry." } ;

HELP: <entry>
{ $values { "obj" object } { "entry" entry } }
{ $description "Creates a new queue entry." }
{ $notes "This word is a factor of " { $link enque } "." } ;

HELP: <queue>
{ $values { "queue" queue } }
{ $description "Makes a new queue with no elements." } ;

HELP: queue-empty?
{ $values { "queue" queue } { "?" "a boolean" } }
{ $description "Tests if a queue contains no elements." } ;

HELP: deque
{ $values { "queue" queue } { "elt" object } }
{ $description "Removes an element from the front of the queue." }
{ $errors "Throws an " { $link empty-queue-error } " if the queue has no entries." }
{ $side-effects "queue" } ;

HELP: enque
{ $values { "elt" object } { "queue" queue } }
{ $description "Adds an element to the back of the queue." }
{ $side-effects "queue" } ;

HELP: empty-queue-error
{ $description "Throws an " { $link empty-queue-error } "." }
{ $error-description "Thrown by " { $link deque } " if the queue has no entries." } ;

HELP: clear-queue
{ $values { "queue" queue } }
{ $description "Removes all entries from the queue." }
{ $side-effects "queue" } ;

HELP: queue-each
{ $values { "queue" queue } { "quot" "a quotation with stack effect " { $snippet "( obj -- )" } } }
{ $description "Applies the quotation to each entry in the queue, starting from the least recently added entry, clearing the queue in the process." }
{ $side-effects "queue" } ;
