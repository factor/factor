USING: help.markup help.syntax kernel kernel.private io
threads.private continuations queues ;
IN: threads

ARTICLE: "threads" "Threads"
"A limited form of multiprocessing is supported in the form of cooperative threads, which are implemented on top of continuations. A thread will yield while waiting for I/O operations to complete, or when a yield has been explicitly requested."
$nl
"Words for working with threads are in the " { $vocab-link "threads" } " vocabulary."
{ $subsection in-thread }
{ $subsection yield }
{ $subsection sleep }
{ $subsection stop }
"Continuations can be added to the run queue directly:"
{ $subsection schedule-thread }
{ $subsection schedule-thread-with }
"Thread implementation:"
{ $subsection run-queue }
{ $subsection sleep-queue } ;

ABOUT: "threads"

HELP: run-queue
{ $values { "queue" queue } }
{ $description "Outputs the runnable thread queue." } ;

HELP: schedule-thread
{ $values { "continuation" "a continuation reified by " { $link callcc0 } } }
{ $description "Adds a runnable thread to the end of the run queue." } ;

HELP: schedule-thread-with
{ $values { "obj" "an object" } { "continuation" "a continuation reified by " { $link callcc1 } } }
{ $description "Adds a runnable thread to the end of the run queue. When the thread runs the object is passed to the continuation using " { $link continue-with } "." } ;

HELP: sleep-queue
{ $var-description "Sleeping thread queue. This is not actually a queue, but an array of pairs of the shape " { $snippet "{ time continuation }" } "." } ;

HELP: sleep-time
{ $values { "ms" "a non-negative integer" } }
{ $description "Outputs the time until the next sleeping thread is scheduled to wake up, or a default sleep time if there are no sleeping threads." } ;

HELP: stop
{ $description "Stops the current thread." } ;

HELP: yield
{ $description "Adds the current thread to the end of the run queue, and switches to the next runnable thread." } ;

HELP: sleep
{ $values { "ms" "a non-negative integer" } }
{ $description "Suspends the current thread for " { $snippet "ms" } " milliseconds. It will not get woken up before this time period elapses, but since the multitasker is co-operative, the precise wakeup time is dependent on when other threads yield." } ;

HELP: in-thread
{ $values { "quot" "a quotation" } }
{ $description "Spawns a new thread. The new thread begins running immediately."
$nl
"The new thread inherits the current data stack and name stack. The call stack initially contains the new quotation only, so when the quotation returns the thread stops. The catch stack contains a default handler which logs errors to the " { $link stdio } " stream." }
{ $examples
    { $code "1 2 [ + . ] in-thread" }
} ;

HELP: idle-thread
{ $description "Runs the idle thread, which services I/O requests and relinquishes control to the operating system until the next Factor thread has to wake up again."
$nl
"If the run queue is empty, the idle thread will sleep until the next sleeping thread is scheduled to wake up, otherwise it yields immediately after checking for any completed I/O requests." }
{ $notes "This word should never be called directly. The idle thread is always running." } ;

HELP: init-threads
{ $description "Called during startup to initialize the threading system. This word should never be called directly." } ;
