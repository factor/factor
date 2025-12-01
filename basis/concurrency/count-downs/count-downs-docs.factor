USING: calendar help.markup help.syntax sequences ;
IN: concurrency.count-downs

HELP: <count-down>
{ $values { "n" "a non-negative integer" } { "count-down" count-down } }
{ $description "Creates a new count-down latch." }
{ $errors "Throws an error if the count is lower than zero." } ;

HELP: count-down
{ $values { "count-down" count-down } }
{ $description "Decrements a count-down latch. If it reaches zero, all threads blocking on " { $link await } " are notified." }
{ $errors "Throws an error if an attempt is made to decrement the count lower than zero." } ;

HELP: await
{ $values { "count-down" count-down } }
{ $description "Waits until the count-down value reaches zero." } ;

HELP: await-timeout
{ $values { "count-down" count-down } { "timeout" { $maybe duration } } }
{ $description "Waits until the count-down value reaches zero or the " { $snippet "timeout" } " has expired." } ;

ARTICLE: "concurrency.count-downs" "Count-down latches"
"The " { $vocab-link "concurrency.count-downs" } " vocabulary implements the " { $emphasis "count-down latch" } " data type, which is a wrapper for a non-negative integer value which tends towards zero. A thread can either decrement the value, or wait for it to become zero."
{ $subsections
    <count-down>
    count-down
    await
    await-timeout
}
"The vocabulary was modeled after a similar feature in Java's " { $snippet "java.util.concurrent" } " library." ;

ABOUT: "concurrency.count-downs"
