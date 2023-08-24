USING: calendar help.markup help.syntax quotations ;
IN: concurrency.locks

HELP: lock
{ $class-description "The class of mutual exclusion locks." } ;

HELP: <lock>
{ $values { "lock" lock } }
{ $description "Creates a non-reentrant lock." } ;

HELP: <reentrant-lock>
{ $values { "lock" lock } }
{ $description "Creates a reentrant lock." } ;

HELP: with-lock-timeout
{ $values { "lock" lock } { "timeout" { $maybe duration } } { "quot" quotation } }
{ $description "Calls the quotation, ensuring that only one thread executes with the lock held at a time. If another thread is holding the lock, blocks until the thread releases the lock." }
{ $errors "Throws an error if the lock could not be acquired before the timeout expires. A timeout value of " { $link f } " means the thread is willing to wait indefinitely." } ;

HELP: with-lock
{ $values { "lock" lock } { "quot" quotation } }
{ $description "Calls the quotation, ensuring that only one thread executes with the lock held at a time. If another thread is holding the lock, blocks until the thread releases the lock." } ;

ARTICLE: "concurrency.locks.mutex" "Mutual-exclusion locks"
"A mutual-exclusion lock ensures that only one thread executes with the lock held at a time. They are used to protect critical sections so that certain operations appear to be atomic to other threads."
$nl
"There are two varieties of locks: non-reentrant and reentrant. The latter may be acquired recursively by the same thread. Attempting to do so with the former will deadlock."
{ $subsections
    lock
    <lock>
    <reentrant-lock>
    with-lock
    with-lock-timeout
} ;

HELP: rw-lock
{ $class-description "The class of reader/writer locks." } ;

HELP: with-read-lock-timeout
{ $values { "lock" lock } { "timeout" { $maybe duration } } { "quot" quotation } }
{ $description "Calls the quotation, ensuring that no other thread is holding a write lock at the same time. If another thread is holding a write lock, blocks until the thread releases the lock." }
{ $errors "Throws an error if the lock could not be acquired before the timeout expires. A timeout value of " { $link f } " means the thread is willing to wait indefinitely." } ;

HELP: with-read-lock
{ $values { "lock" lock } { "quot" quotation } }
{ $description "Calls the quotation, ensuring that no other thread is holding a write lock at the same time. If another thread is holding a write lock, blocks until the thread releases the lock." } ;

HELP: with-write-lock-timeout
{ $values { "lock" lock } { "timeout" { $maybe duration } } { "quot" quotation } }
{ $description "Calls the quotation, ensuring that no other thread is holding a read or write lock at the same time. If another thread is holding a read or write lock, blocks until the thread releases the lock." }
{ $errors "Throws an error if the lock could not be acquired before the timeout expires. A timeout value of " { $link f } " means the thread is willing to wait indefinitely." } ;

HELP: with-write-lock
{ $values { "lock" lock } { "quot" quotation } }
{ $description "Calls the quotation, ensuring that no other thread is holding a read or write lock at the same time. If another thread is holding a read or write lock, blocks until the thread releases the lock." } ;

ARTICLE: "concurrency.locks.rw" "Read-write locks"
"A read-write lock encapsulates a common pattern in the implementation of concurrent data structures, where one wishes to ensure that a thread is able to see a consistent view of the structure for a period of time, during which no other thread modifies the structure."
$nl
"While this can be achieved with a simple " { $link "concurrency.locks.mutex" } ", performance will suffer, since in fact multiple threads can view the structure at the same time; serialization must only be enforced for writes."
$nl
"Read/write locks allow any number of threads to hold the read lock simultaneously, however attempting to acquire a write lock blocks until all other threads release read locks and write locks."
$nl
"Read/write locks are reentrant. A thread holding a write lock may acquire a read lock or a write lock without blocking. However a thread holding a read lock may not acquire a write lock recursively since that could break invariants assumed by the code executing with the read lock held."
{ $subsections
    rw-lock
    <rw-lock>
    with-read-lock
    with-write-lock
}
"Versions of the above that take a timeout duration:"
{ $subsections
    with-read-lock-timeout
    with-write-lock-timeout
} ;

ARTICLE: "concurrency.locks" "Locks"
"A " { $emphasis "lock" } " is an object protecting a critical region of code, enforcing a particular mutual-exclusion policy. The " { $vocab-link "concurrency.locks" } " vocabulary implements two types of locks:"
{ $subsections
    "concurrency.locks.mutex"
    "concurrency.locks.rw"
} ;

ABOUT: "concurrency.locks"
