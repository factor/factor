USING: help.markup help.syntax kernel kernel.private io
concurrency.threads.private continuations dlists init
quotations strings assocs heaps ;
IN: concurrency.threads

ARTICLE: "threads-start/stop" "Starting and stopping threads"
"Spawning new threads:"
{ $subsection spawn }
"Creating and spawning a thread can be factored out into two separate steps:"
{ $subsection <thread> }
{ $subsection (spawn) }
"Threads stop either when the quotation given to " { $link spawn } " returns, or when the following word is called:"
{ $subsection stop }
"If the image is saved and started again, all runnable threads are stopped. Vocabularies wishing to have a background thread always running should use " { $link add-init-hook } "." ;

ARTICLE: "threads-yield" "Yielding and suspending threads"
"Yielding to other threads:"
{ $subsection yield }
{ $subsection sleep }
"Threads can be suspended and woken up at some point in the future when a condition is satisfied:"
{ $subsection suspend }
{ $subsection resume }
{ $subsection resume-with } ;

ARTICLE: "thread-state" "Thread-local state"
"Threads form a class of objects:"
{ $subsection thread }
"The current thread:"
{ $subsection self }
"Thread-local variables:"
{ $subsection tnamespace }
{ $subsection tget }
{ $subsection tset }
{ $subsection tchange }
"Global hashtable of all threads, keyed by " { $link thread-id } ":"
{ $subsection threads }
"Threads have an identity independent of continuations. If a continuation is refied in one thread and then resumed in another thread, the code running in that continuation will observe a change in the value output by " { $link self } "." ;

ARTICLE: "thread-impl" "Thread implementation"
"Thread implementation:"
{ $subsection run-queue }
{ $subsection sleep-queue } ;

ARTICLE: "threads" "Lightweight co-operative threads"
"Factor supports lightweight co-operative threads implemented on top of continuations. A thread will yield while waiting for I/O operations to complete, or when a yield has been explicitly requested."
$nl
"Words for working with threads are in the " { $vocab-link "concurrency.threads" } " vocabulary."
{ $subsection "threads-start/stop" }
{ $subsection "threads-yield" }
{ $subsection "thread-state" }
{ $subsection "thread-impl" } ;

ABOUT: "threads"

HELP: thread
{ $class-description "A thread. The slots are as follows:"
    { $list
        { { $link thread-id } " - a unique identifier assigned to each thread." }
        { { $link thread-name } " - the name passed to " { $link spawn } "." }
        { { $link thread-quot } " - the initial quotation passed to " { $link spawn } "." }
        { { $link thread-continuation } " - if the thread is waiting to run, the saved thread context. If the thread is currently running, will be " { $link f } "." }
        { { $link thread-registered? } " - a boolean indicating whether the thread is eligible to run or not. Spawning a thread with " { $link (spawn) } " sets this flag and " { $link stop } " clears it." }
    }
} ;

HELP: self
{ $values { "thread" thread } }
{ $description "Pushes the currently-running thread." } ;

HELP: <thread>
{ $values { "quot" quotation } { "name" string } { "error-handler" quotation } }
{ $description "Low-level thread constructor. The thread runs the quotation when spawned; the name is simply used to identify the thread for debugging purposes. The error handler is called if the thread's quotation throws an unhandled error; it should either print the error or notify another thread." }
{ $notes "In most cases, user code should call " { $link spawn } " instead, however for control over the error handler quotation, threads can be created with " { $link <thread> } " then passed to " { $link (spawn) } "." } ;

HELP: run-queue
{ $values { "queue" dlist } }
{ $var-description "Global variable holding the queue of runnable threads. Calls to " { $link yield } " switch to the thread which has been in the queue for the longest period of time."
$nl
"By convention, threads are queued with " { $link push-front } 
" and dequeued with " { $link pop-back } "." } ;

HELP: resume
{ $values { "thread" thread } }
{ $description "Adds a thread to the end of the run queue. The thread must have previously been suspended by a call to " { $link suspend } "." } ;

HELP: resume-with
{ $values { "obj" object } { "thread" thread } }
{ $description "Adds a thread to the end of the run queue together with an object to pass to the thread. The thread must have previously been suspended by a call to " { $link suspend } "; the object is returned from the " { $link suspend } " call." } ;

HELP: sleep-queue
{ $var-description "A " { $link min-heap } " storing the queue of sleeping threads." } ;

HELP: sleep-time
{ $values { "ms" "a non-negative integer or " { $link f } } }
{ $description "Outputs the time until the next sleeping thread is scheduled to wake up, which could be zero if there are threads in the run queue, or threads which need to wake up right now. If there are no runnable or sleeping threads, outputs " { $link f } "." } ;

HELP: stop
{ $description "Stops the current thread. The thread may be started again from another thread using " { $link (spawn) } "." } ;

HELP: yield
{ $description "Adds the current thread to the end of the run queue, and switches to the next runnable thread." } ;

HELP: sleep
{ $values { "ms" "a non-negative integer" } }
{ $description "Suspends the current thread for " { $snippet "ms" } " milliseconds. It will not get woken up before this time period elapses, but since the multitasker is co-operative, the precise wakeup time is dependent on when other threads yield." } ;

HELP: suspend
{ $values { "quot" "a quotation with stack effect " { $snippet "( thread -- )" } } { "obj" object } }
{ $description "Suspends the current thread and passes it to the quotation. After the quotation returns, control yields to the next runnable thread and the current thread does not execute again until it is resumed, and so the quotation must arrange for another thread to later resume the suspended thread with a call to " { $link resume } " or " { $link resume-with } "." } ;

HELP: spawn
{ $values { "quot" quotation } { "name" string } }
{ $description "Spawns a new thread. The thread begins executing the given quotation; the name is for debugging purposes. The new thread begins running immediately and the current thread is added to the end of the run queue."
$nl
"The new thread begins with an empty data stack, an empty catch stack and a name stack containing the global namespace only. This means that the only way to pass data to the new thread is to explicitly construct a quotation containing the data, for example using " { $link curry } " or " { $link compose } "." }
{ $examples
    { $code "1 2 [ + . ] 2curry \"Addition thread\" spawn" }
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
{ $values { "key" object } { "quot" "a quotation with stack effect " { $snippet "( value -- newvalue )" } } }
{ $description "Applies the quotation to the current value of a thread-local variable, storing the result back to the same variable." } ;
