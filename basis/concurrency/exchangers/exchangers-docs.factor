USING: help.markup help.syntax kernel ;
IN: concurrency.exchangers

HELP: exchanger
{ $class-description "The class of object exchange points." } ;

HELP: <exchanger>
{ $values { "exchanger" exchanger } }
{ $description "Creates a new object exchange point." } ;

HELP: exchange
{ $values { "obj" object } { "exchanger" exchanger } { "newobj" object } }
{ $description "Waits for another thread to call " { $link exchange } " on the same exchanger. The thread's call to " { $link exchange } " returns with " { $snippet "obj" } " on the stack, and the object passed to " { $link exchange } " by the other thread is left on the current's thread stack as " { $snippet "newobj" } "." } ;

ARTICLE: "concurrency.exchangers" "Object exchange points"
"The " { $vocab-link "concurrency.exchangers" } " vocabulary implements " { $emphasis "object exchange points" } ", which are rendezvous points where two threads can exchange objects."
{ $subsections
    exchanger
    <exchanger>
    exchange
}
"One use-case is two threads, where one thread reads data into a buffer and another thread processes the data. The reader thread can begin by reading the data, then passing the buffer through an exchanger, then recursing. The processing thread can begin by creating an empty buffer, and exchanging it through the exchanger. It then processes the result and recurses."
$nl
"The vocabulary was modelled after a similar feature in Java's " { $snippet "java.util.concurrent" } " library." ;

ABOUT: "concurrency.exchangers"
