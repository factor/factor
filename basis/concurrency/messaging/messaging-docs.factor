! Copyright (C) 2006 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup
threads kernel arrays quotations strings ;
IN: concurrency.messaging

HELP: send
{ $values { "message" object }
          { "thread" thread }
}
{ $description "Send the message to the thread by placing it in the thread's mailbox. This is an asynchronous operation and will return immediately. The receiving thread will act on the message the next time it retrieves that item from its mailbox (usually using the " { $link receive } " word). The message can be any Factor object. For destinations that are instances of remote-thread the message must be a serializable Factor type." }
{ $see-also receive receive-if } ;

HELP: receive
{ $values { "message" object }
}
{ $description "Return a message from the current thread's mailbox. If the box is empty, suspend the thread until another thread places an item in the mailbox (usually via the " { $link send } " word)." }
{ $see-also send receive-if } ;

HELP: receive-if
{ $values { "pred" "a predicate with stack effect " { $snippet "( obj -- ? )" } }
          { "message" object }
}
{ $description "Return the first message from the current thread's mailbox that satisfies the predicate. To satisfy the predicate, " { $snippet "pred" } " is called with the item on the stack and the predicate should leave a boolean indicating whether it was satisfied or not. If nothing in the mailbox satisfies the predicate then the thread will block until something does." }
{ $see-also send receive } ;

HELP: handle-synchronous
{ $values { "quot" "a " { $link quotation } " with stack effect " { $snippet "( ... message -- ... reply )" } }
}
{ $description "Receive a message that was sent with " { $link send-synchronous } ", call " { $snippet "quot" } " to transform it into a response and use " { $link reply-synchronous } " to reply."
} ;

HELP: spawn-linked
{ $values { "quot" quotation }
          { "name" string }
          { "thread" thread }
}
{ $description "Start a thread which runs the given quotation. If that quotation throws an error which is not caught then the error will get propagated to the thread that spawned it. This can be used to set up 'supervisor' threads that restart child threads that crash due to uncaught errors.\n" }
{ $see-also spawn } ;

ARTICLE: "concurrency-messaging" "Sending and receiving messages"
"Each thread has an associated mailbox. Other threads can place items on this queue by sending the thread a message. A thread can check its mailbox for messages, blocking if none are pending, and thread them as they are queued."
$nl
"The messages that are sent from thread to thread are any Factor value. Factor tuples are ideal for this sort of thing as you can send a tuple to a thread and the generic word dispatch mechanism can be used to perform actions depending on what the type of the tuple is."
$nl
"The " { $link spawn } " word pushes the newly-created thread on the calling thread's stack; this thread object can then be sent messages:"
{ $subsections send }
"A thread can get a message from its queue:"
{ $subsections
    receive
    receive-timeout
    receive-if
    receive-if-timeout
}
{ $see-also "concurrency.mailboxes" } ;

ARTICLE: "concurrency-synchronous-sends" "Synchronous sends"
"The " { $link send } " word sends a message asynchronously, and the sending thread continues immediately. It is also possible to send a message to a thread and block until a response is received:"
{ $subsections send-synchronous }
"To reply to a synchronous message:"
{ $subsections reply-synchronous handle-synchronous }
"An example:"
{ $example
    "USING: concurrency.messaging kernel threads ;"
    "IN: scratchpad"
    ": pong-server ( -- )"
    "    [ drop \"pong\" ] handle-synchronous ;"
    "[ pong-server t ] \"pong-server\" spawn-server"
    "\"ping\" swap send-synchronous ."
    "\"pong\""
} ;

ARTICLE: "concurrency-exceptions" "Linked exceptions"
"A thread can handle exceptions using the standard Factor exception handling mechanism. If an exception is uncaught the thread will terminate. For example:"
{ $code "[ 1 0 / \"This will not print\" print ] \"division-by-zero\" spawn" }
"Processes can be linked so that a parent thread can receive the exception that caused the child thread to terminate. In this way 'supervisor' threads can be created that are notified when child threads terminate and possibly restart them."
{ $subsections spawn-linked }
"This will create a unidirectional link, such that if an uncaught exception causes the child to terminate, the parent thread can catch it:"
{ $code "["
"  [ 1 0 / \"This will not print\" print ] \"linked-division\" spawn-linked drop"
"  receive"
"] [ \"Exception caught.\" print ] recover" }
"Exceptions are only raised in the parent when the parent does a " { $link receive } " or " { $link receive-if } ". This is because the exception is sent from the child to the parent as a message." ;

ARTICLE: "concurrency.messaging" "Message-passing concurrency"
"The " { $vocab-link "concurrency.messaging" } " vocabulary is based upon the style of concurrency used in systems like Erlang and Termite. It is built on top of " { $link "threads" } "."
$nl
"A concurrency-oriented program is one in which multiple threads run simultaneously in a single Factor image or across multiple running Factor instances. The threads can communicate with each other by asynchronous message sends."
$nl
"Although threads can share data via Factor's mutable data structures it is not recommended to mix shared state with message passing as it can lead to confusing code."
{ $subsections
    "concurrency-messaging"
    "concurrency-synchronous-sends"
    "concurrency-exceptions"
} ;

ABOUT: "concurrency.messaging"
