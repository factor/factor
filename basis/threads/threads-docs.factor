USING: help.markup help.syntax kernel kernel.private io
threads.private continuations init quotations strings
assocs heaps boxes namespaces deques dlists ;
IN: threads

ARTICLE: "threads-start/stop" "Starting and stopping threads"
"Spawning new threads:"
{ $subsection spawn }
{ $subsection spawn-server }
"Creating and spawning a thread can be factored out into two separate steps:"
{ $subsection <thread> }
{ $subsection (spawn) }
"Threads stop either when the quotation given to " { $link spawn } " returns, or when the following word is called:"
{ $subsection stop }
"If the image is saved and started again, all runnable threads are stopped. Vocabularies wishing to have a background thread always running should use " { $link add-init-hook } "." ;

ARTICLE: "threads-yield" "Yielding and suspending threads"
"Yielding to other threads:"
{ $subsection yield }
"Sleeping for a period of time:"
{ $subsection sleep }
"Interrupting sleep:"
{ $subsection interrupt }
"Threads can be suspended and woken up at some point in the future when a condition is satisfied:"
{ $subsection suspend }
{ $subsection resume }
{ $subsection resume-with } ;

ARTICLE: "thread-state" "Thread-local state and variables"
"Threads form a class of objects:"
{ $subsection thread }
"The current thread:"
{ $subsection self }
"Thread-local variables:"
{ $subsection tnamespace }
{ $subsection tget }
{ $subsection tset }
{ $subsection tchange }
"Each thread has its own independent set of thread-local variables and newly-spawned threads begin with an empty set."
$nl
"Global hashtable of all threads, keyed by " { $snippet "id" } ":"
{ $subsection threads }
"Threads have an identity independent of continuations. If a continuation is refied in one thread and then resumed in another thread, the code running in that continuation will observe a change in the value output by " { $link self } "." ;

ARTICLE: "thread-impl" "Thread implementation"
"Thread implementation:"
{ $subsection run-queue }
{ $subsection sleep-queue } ;

ARTICLE: "threads" "Lightweight co-operative threads"
"Factor supports lightweight co-operative threads implemented on top of " { $link "continuations" } ". A thread will yield while waiting for input/output operations to complete, or when a yield has been explicitly requested."
$nl
"Factor threads are very lightweight. Each thread can take as little as 900 bytes of memory. This library has been tested running hundreds of thousands of simple threads."
$nl
"Words for working with threads are in the " { $vocab-link "threads" } " vocabulary."
{ $subsection "threads-start/stop" }
{ $subsection "threads-yield" }
{ $subsection "thread-state" }
{ $subsection "thread-impl" } ;

ABOUT: "threads"

HELP: thread
{ $class-description "A thread. The slots are as follows:"
    { $list
        { { $snippet "id" } " - a unique identifier assigned to each thread." }
        { { $snippet "name" } " - the name passed to " { $link spawn } "." }
        { { $snippet "quot" } " - the initial quotation passed to " { $link spawn } "." }
        { { $snippet "continuation" } " - a " { $link box } "; if the thread is ready to run, the box holds the continuation, otherwise it is empty." }
    }
} ;

HELP: self
{ $values { "thread" thread } }
{ $description "Pushes the currently-running thread." } ;

HELP: <thread>
{ $values { "quot" quotation } { "name" string } { "thread" thread } }
{ $description "Low-level thread constructor. The thread runs the quotation when spawned."
$nl
"The name is used to identify the thread for debugging purposes; see " { $link "tools.threads" } "." }
{ $notes "In most cases, user code should call " { $link spawn } " instead, however for control over the error handler quotation, threads can be created with " { $link <thread> } " then passed to " { $link (spawn) } "." } ;

HELP: run-queue
{ $values { "dlist" dlist } }
{ $var-description "Global variable holding the queue of runnable threads. Calls to " { $link yield } " switch to the thread which has been in the queue for the longest period of time."
$nl
"By convention, threads are queued with " { $link push-front } 
" and dequed with " { $link pop-back } "." } ;

HELP: resume
{ $values { "thread" thread } }
{ $description "Adds a thread to the end of the run queue. The thread must have previously been suspended by a call to " { $link suspend } "." } ;

HELP: resume-with
{ $values { "obj" object } { "thread" thread } }
{ $description "Adds a thread to the end of the run queue together with an object to pass to the thread. The thread must have previously been suspended by a call to " { $link suspend } "; the object is returned from the " { $link suspend } " call." } ;

HELP: sleep-queue
{ $values { "heap" min-heap } }
{ $var-description "A " { $link min-heap } " storing the queue of sleeping threads." } ;

HELP: sleep-time
{ $values { "us/f" "a non-negative integer or " { $link f } } }
{ $description "Outputs the time until the next sleeping thread is scheduled to wake up, which could be zero if there are threads in the run queue, or threads which need to wake up right now. If there are no runnable or sleeping threads, outputs " { $link f } "." } ;

HELP: stop
{ $description "Stops the current thread. The thread may be started again from another thread using " { $link (spawn) } "." } ;

HELP: yield
{ $description "Adds the current thread to the end of the run queue, and switches to the next runnable thread." } ;

HELP: sleep-until
{ $values { "time/f" "a non-negative integer or " { $link f } } }
{ $description "Suspends the current thread until the given time, or indefinitely if a value of " { $link f } " is passed in."
$nl
"Other threads may interrupt the sleep by calling " { $link interrupt } "." } ;

HELP: sleep
{ $values { "dt" "a duration" } }
{ $description "Suspends the current thread for the given duration."
$nl
"Other threads may interrupt the sleep by calling " { $link interrupt } "." }
{ $examples
    { $code "USING: threads calendar ;" "10 seconds sleep" }
} ;

HELP: interrupt
{ $values { "thread" thread } }
{ $description "Interrupts a sleeping thread." } ;

HELP: suspend
{ $values { "quot" { $quotation "( thread -- )" } } { "state" string } { "obj" object } }
{ $description "Suspends the current thread and passes it to the quotation."
$nl
"After the quotation returns, control yields to the next runnable thread and the current thread does not execute again until it is resumed, and so the quotation must arrange for another thread to later resume the suspended thread with a call to " { $link resume } " or " { $link resume-with } "."
$nl
"The status string is for debugging purposes; see " { $link "tools.threads" } "." } ;

HELP: spawn
{ $values { "quot" quotation } { "name" string } { "thread" thread } }
{ $description "Spawns a new thread. The thread begins executing the given quotation; the name is for debugging purposes. The new thread begins running immediately and the current thread is added to the end of the run queue."
$nl
"The new thread begins with an empty data stack, an empty retain stack, and an empty catch stack. The name stack is inherited from the parent thread but may be cleared with " { $link init-namespaces } "." }
{ $notes
     "The recommended way to pass data to the new thread is to explicitly construct a quotation containing the data, for example using " { $link curry } " or " { $link compose } "."
}
{ $examples
    { $code "1 2 [ + . ] 2curry \"Addition thread\" spawn" }
} ;

HELP: spawn-server
{ $values { "quot" { $quotation "( -- ? )" } } { "name" string } { "thread" thread } }
{ $description "Convenience wrapper around " { $link spawn } " which repeatedly calls the quotation in a new thread until it outputs " { $link f } "." }
{ $examples
    "A thread that runs forever:"
    { $code "[ do-foo-bar t ] \"Foo bar server\" spawn-server" }
} ;

HELP: init-threads
{ $description "Called during startup to initialize the threading system. This word should never be called directly." } ;

HELP: tnamespace
{ $values { "assoc" assoc } }
{ $description "Outputs the current thread's set of thread-local variables." } ;

HELP: tget
{ $values { "key" object } { "value" object } }
{ $description "Outputs the value of a thread-local variable." } ;

HELP: tset
{ $values { "value" object } { "key" object } }
{ $description "Sets the value of a thread-local variable." } ;

HELP: tchange
{ $values { "key" object } { "quot" { $quotation "( value -- newvalue )" } } }
{ $description "Applies the quotation to the current value of a thread-local variable, storing the result back to the same variable." } ;
