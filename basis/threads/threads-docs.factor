USING: assocs boxes deques dlists heaps help.markup help.syntax
init kernel kernel.private namespaces quotations strings system
threads.private ;
IN: threads

ARTICLE: "threads-start/stop" "Starting and stopping threads"
"Spawning new threads:"
{ $subsections
    spawn
    spawn-server
}
"Creating and spawning a thread can be factored out into two separate steps:"
{ $subsections
    <thread>
    (spawn)
}
"Threads stop either when the quotation given to " { $link spawn } " returns, or when the following word is called:"
{ $subsections stop }
"If the image is saved and started again, all runnable threads are stopped. Vocabularies wishing to have a background thread always running should use " { $link add-startup-hook } "." ;

ARTICLE: "threads-yield" "Yielding and suspending threads"
"Yielding to other threads:"
{ $subsections yield }
"Sleeping for a period of time:"
{ $subsections sleep }
"Interrupting sleep:"
{ $subsections interrupt }
"Threads can be suspended and woken up at some point in the future when a condition is satisfied:"
{ $subsections
    suspend
    resume
    resume-with
} ;

ARTICLE: "thread-state" "Thread-local state and variables"
"Threads form a class of objects:"
{ $subsections thread }
"The current thread:"
{ $subsections self }
"Thread-local variables:"
{ $subsections
    tnamespace
    tget
    tset
    tchange
}
"Each thread has its own independent set of thread-local variables and newly-spawned threads begin with an empty set."
$nl
"Global hashtable of all threads, keyed by " { $snippet "id" } ":"
{ $subsections threads }
"Threads have an identity independent of continuations. If a continuation is reified in one thread and then reflected in another thread, the code running in that continuation will observe a change in the value output by " { $link self } "." ;

ARTICLE: "thread-impl" "Thread implementation"
"Thread implementation:"
{ $subsections
    run-queue
    sleep-queue
} ;

ARTICLE: "threads" "Co-operative threads"
"Factor supports co-operative threads. A thread will yield while waiting for input/output operations to complete, or when a yield has been explicitly requested."
$nl
"Words for working with threads are in the " { $vocab-link "threads" } " vocabulary."
{ $subsections
    "threads-start/stop"
    "threads-yield"
    "thread-state"
    "thread-impl"
} ;

ABOUT: "threads"

HELP: thread
{ $class-description "A thread. The slots are as follows:"
    { $slots
      {
          "id"
          "a unique identifier assigned to each thread."
      }
      {
          "exit-handler"
          { "a " { $link quotation } " run when the thread is being stopped." }
      }
      {
          "name"
          { "the name passed to " { $link spawn } "." }
      }
      {
          "quot"
          { "the initial quotation passed to " { $link spawn } "." }
      }
      {
          "runnable"
          { "whether the thread is runnable. Initially it is, " { $link f } "." }
      }
      {
          "state"
          { "a " { $link string } " indicating what the thread is waiting for, or " { $link f } ". This slot is intended to be used for debugging purposes." }
      }
      {
          "context"
          { "a " { $link box } " holding an alien pointer to the threads " { $link context } " object." }
      }
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
{ $values { "nanos/f" { $maybe "a non-negative integer" } } }
{ $description "Returns the time until the next sleeping thread is scheduled to wake up, which could be zero if there are threads in the run queue, or threads which need to wake up right now. If there are no runnable or sleeping threads, returns " { $link f } "." } ;

HELP: stop
{ $description "Stops the current thread. The thread may be started again from another thread using " { $link (spawn) } "." } ;

HELP: yield
{ $description "Adds the current thread to the end of the run queue, and switches to the next runnable thread." } ;

HELP: sleep-until
{ $values { "n/f" { $maybe "a non-negative integer" } } }
{ $description "Suspends the current thread until the given nanosecond count, returned by " { $link nano-count } ", is reached, or indefinitely if a value of " { $link f } " is passed in."
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
{ $values { "state" string } { "obj" object } }
{ $description "Suspends the current thread. Control yields to the next runnable thread and the current thread does not execute again until it is resumed, and so the caller of this word must arrange for another thread to later resume the suspended thread with a call to " { $link resume } " or " { $link resume-with } "."
$nl
"The state string is for debugging purposes; see " { $link "tools.threads" } "." } ;

HELP: spawn
{ $values { "quot" quotation } { "name" string } { "thread" thread } }
{ $description "Spawns a new thread that will execute the quotation given; the name is for debugging purposes. The new thread is added to the end of the run queue."
$nl
"The new thread begins with an empty data stack, an empty retain stack, and an empty catch stack. The name stack is inherited from the parent thread but may be cleared with " { $link init-namestack } "." }
{ $notes
    "The recommended way to pass data to the new thread is to explicitly construct a quotation containing the data, for example using " { $link curry } " or " { $link compose } "."
}
{ $examples
    "A simple thread that adds two numbers:"
    { $code "1 2 [ + . ] 2curry \"Addition thread\" spawn drop yield" }
    "A thread that counts to 10:"
    ! Don't use $example below: it won't pass help-lint.
    { $code
      "USING: math.parser threads ;"
      "[ 10 <iota> [ number>string print yield ] each ] \"test\" spawn drop"
      "10 [ yield ] times"
      "0"
      "1"
      "2"
      "3"
      "4"
      "5"
      "6"
      "7"
      "8"
      "9"
    }
} ;

HELP: spawn-server
{ $values { "quot" { $quotation ( -- ? ) } } { "name" string } { "thread" thread } }
{ $description "Convenience wrapper around " { $link spawn } " which repeatedly calls the quotation in a new thread until it outputs " { $link f } "." }
{ $examples
    "A thread that runs forever:"
    { $code "[ do-foo-bar t ] \"Foo bar server\" spawn-server drop yield" }
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
{ $values { "key" object } { "quot" { $quotation ( ..a value -- ..b newvalue ) } } }
{ $description "Applies the quotation to the current value of a thread-local variable, storing the result back to the same variable." } ;
