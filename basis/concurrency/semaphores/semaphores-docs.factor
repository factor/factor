IN: concurrency.semaphores
USING: help.markup help.syntax quotations calendar ;

HELP: semaphore
{ $class-description "The class of counting semaphores. New instances can be created by calling " { $link <semaphore> } "." } ;

HELP: <semaphore>
{ $values { "n" "a non-negative integer" } { "semaphore" semaphore } }
{ $description "Creates a counting semaphore with the specified initial count." } ;

HELP: acquire-timeout
{ $values { "semaphore" semaphore } { "timeout" { $maybe duration } } }
{ $description "If the semaphore has a non-zero count, decrements it and returns immediately. Otherwise, if the timeout is " { $link f } ", waits indefinitely for the semaphore to be released. If the timeout is not " { $link f } ", waits a certain period of time, and if the semaphore still has not been released, throws an error." }
{ $errors "Throws an error if the timeout expires before the semaphore is released." } ;

HELP: acquire
{ $values { "semaphore" semaphore } }
{ $description "If the semaphore has a non-zero count, decrements it and returns immediately. Otherwise, waits for it to be released." } ;

HELP: release
{ $values { "semaphore" semaphore } }
{ $description "Increments a semaphore's count. If the count was previously zero, any threads waiting on the semaphore are woken up." } ;

HELP: with-semaphore-timeout
{ $values { "semaphore" semaphore } { "timeout" { $maybe duration } } { "quot" quotation } }
{ $description "Calls the quotation with the semaphore held." } ;

HELP: with-semaphore
{ $values { "semaphore" semaphore } { "quot" quotation } }
{ $description "Calls the quotation with the semaphore held." } ;

ARTICLE: "concurrency.semaphores.examples" "Semaphore examples"
"A use-case would be a batch processing server which runs a large number of jobs which perform calculations but then need to fire off expensive external processes or perform heavy network I/O. While for most of the time, the threads can all run in parallel, it might be desired that the expensive operation is not run by more than 10 threads at once, to avoid thrashing swap space or saturating the network. This can be accomplished with a counting semaphore:"
{ $code
    "SYMBOL: expensive-section"
    "requests"
    "10 <semaphore> '["
    "    ..."
    "    _ [ do-expensive-stuff ] with-semaphore"
    "    ..."
    "] parallel-map"
}
"Here is a concrete example which fetches content from 5 different web sites, making no more than 2 requests at a time:"
{ $code
    "USING: concurrency.combinators concurrency.semaphores
fry http.client kernel urls ;

{
    URL\" http://www.apple.com\"
    URL\" http://www.google.com\"
    URL\" http://www.ibm.com\"
    URL\" http://www.hp.com\"
    URL\" http://www.oracle.com\"
}
2 <semaphore> '[
    _ [ http-get nip ] with-semaphore
] parallel-map"
} ;

ARTICLE: "concurrency.semaphores" "Counting semaphores"
"Counting semaphores are used to ensure that no more than a fixed number of threads are executing in a critical section at a time; as such, they generalize " { $vocab-link "concurrency.locks" } ", since locks can be thought of as semaphores with an initial count of 1."
{ $subsections "concurrency.semaphores.examples" }
"Creating semaphores:"
{ $subsections
    semaphore
    <semaphore>
}
"Unlike locks, where acquisition and release are always paired by a combinator, semaphores expose these operations directly and there is no requirement that they be performed in the same thread:"
{ $subsections
    acquire
    acquire-timeout
    release
}
"Combinators which pair acquisition and release:"
{ $subsections
    with-semaphore
    with-semaphore-timeout
} ;

ABOUT: "concurrency.semaphores"
