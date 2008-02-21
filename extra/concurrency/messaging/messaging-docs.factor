! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup concurrency.messaging.private
threads kernel arrays quotations ;
IN: concurrency.messaging

HELP: <mailbox>
{ $values { "mailbox" mailbox } 
}
{ $description "A mailbox is an object that can be used for safe thread communication. Items can be put in the mailbox and retrieved in a FIFO order. If the mailbox is empty when a get operation is performed then the thread will block until another thread places something in the mailbox. If multiple threads are waiting on the same mailbox, only one of the waiting threads will be unblocked to thread the get operation." } 
{ $see-also mailbox-empty? mailbox-put mailbox-get mailbox-get-all while-mailbox-empty mailbox-get? } ;

HELP: mailbox-empty?
{ $values { "mailbox" mailbox } 
          { "bool" "a boolean" }
}
{ $description "Return true if the mailbox is empty." } 
{ $see-also <mailbox> mailbox-put mailbox-get mailbox-get-all while-mailbox-empty mailbox-get? } ;

HELP: mailbox-put
{ $values { "obj" object } 
          { "mailbox" mailbox } 
}
{ $description "Put the object into the mailbox. Any threads that have a blocking get on the mailbox are resumed. Only one of those threads will successfully get the object, the rest will immediately block waiting for the next item in the mailbox." } 
{ $see-also <mailbox> mailbox-empty? mailbox-get mailbox-get-all while-mailbox-empty mailbox-get? } ;

HELP: block-unless-pred
{ $values { "pred" "a quotation with stack effect " { $snippet "( X -- bool )" } } 
          { "mailbox" mailbox }
          { "timeout" "a timeout in milliseconds, or " { $link f } }
}
{ $description "Block the thread if there are no items in the mailbox that return true when the predicate is called with the item on the stack." } 
{ $see-also <mailbox> mailbox-empty? mailbox-put mailbox-get mailbox-get-all while-mailbox-empty mailbox-get? } ;

HELP: block-if-empty
{ $values { "mailbox" mailbox } 
      { "timeout" "a timeout in milliseconds, or " { $link f } }
}
{ $description "Block the thread if the mailbox is empty." } 
{ $see-also <mailbox> mailbox-empty? mailbox-put mailbox-get mailbox-get-all while-mailbox-empty mailbox-get? } ;

HELP: mailbox-get
{ $values { "mailbox" mailbox } 
          { "obj" object }
}
{ $description "Get the first item put into the mailbox. If it is empty the thread blocks until an item is put into it. The thread then resumes, leaving the item on the stack." } 
{ $see-also <mailbox> mailbox-empty? mailbox-put while-mailbox-empty mailbox-get-all mailbox-get? } ;

HELP: mailbox-get-all
{ $values { "mailbox" mailbox } 
          { "array" array }
}
{ $description "Blocks the thread if the mailbox is empty, otherwise removes all objects in the mailbox and returns an array containing the objects." } 
{ $see-also <mailbox> mailbox-empty? mailbox-put while-mailbox-empty mailbox-get-all mailbox-get? } ;

HELP: while-mailbox-empty
{ $values { "mailbox" mailbox } 
          { "quot" "a quotation with stack effect " { $snippet "( -- )" } }
}
{ $description "Repeatedly call the quotation while there are no items in the mailbox." } 
{ $see-also <mailbox> mailbox-empty? mailbox-put mailbox-get mailbox-get-all mailbox-get? } ;

HELP: mailbox-get?
{ $values { "pred" "a quotation with stack effect " { $snippet "( X -- bool )" } }
          { "mailbox" mailbox } 
          { "obj" object }
}
{ $description "Get the first item in the mailbox which satisfies the predicate. 'pred' will be called repeatedly for each item in the mailbox. When 'pred' returns true that item will be returned. If nothing in the mailbox satisfies the predicate then the thread will block until something does." } 
{ $see-also <mailbox> mailbox-empty? mailbox-put mailbox-get mailbox-get-all while-mailbox-empty } ;

HELP: send
{ $values { "message" object } 
          { "thread" "a thread object" } 
}
{ $description "Send the message to the thread by placing it in the threades mailbox. This is an asynchronous operation and will return immediately. The receving thread will act on the message the next time it retrieves that item from its mailbox (usually using the " { $link receive } " word. The message can be any Factor object. For destinations that are instances of remote-thread the message must be a serializable Factor type." } 
{ $see-also receive receive-if } ;

HELP: receive
{ $values { "message" object } 
}
{ $description "Return a message from the current threades mailbox. If the box is empty, suspend the thread until another thread places an item in the mailbox (usually via the " { $link send } " word." } 
{ $see-also send receive-if } ;

HELP: receive-if
{ $values { "pred" "a predicate with stack effect " { $snippet "( obj -- ? )" } }  
          { "message" object } 
}
{ $description "Return the first message from the current threades mailbox that satisfies the predicate. To satisfy the predicate, " { $snippet "pred" } " is called with the item on the stack and the predicate should leave a boolean indicating whether it was satisfied or not. If nothing in the mailbox satisfies the predicate then the thread will block until something does." } 
{ $see-also send receive } ;

HELP: spawn-linked
{ $values { "quot" quotation }
          { "thread" "a thread object" } 
}
{ $description "Start a thread which runs the given quotation. If that quotation throws an error which is not caught then the error will get propagated to the thread that spawned it. This can be used to set up 'supervisor' threades that restart child threades that crash due to uncaught errors.\n" } 
{ $see-also spawn } ;

ARTICLE: { "concurrency" "mailboxes" } "Mailboxes"
"Each thread has an associated message queue. Other threads can place items on this queue by sending the thread a message. A thread can check its queue for messages, blocking if none are pending, and thread them as they are queued."
$nl
"The messages that are sent from thread to thread are any Factor value. Factor tuples are ideal for this sort of thing as you can send a tuple to a thread and the generic word dispatch mechanism can be used to perform actions depending on what the type of the tuple is."
$nl
"The " { $link spawn } " word pushes the newly-created thread on the calling thread's stack; this thread object can then be sent messages:"
{ $subsection send }
"A thread can get a message from its queue:"
{ $subsection receive }
{ $subsection receive }
{ $subsection receive-if }
"Mailboxes can be created and used directly:"
{ $subsection mailbox }
{ $subsection <mailbox> }
{ $subsection mailbox-get }
{ $subsection mailbox-put }
{ $subsection mailbox-empty? } ;

ARTICLE: { "concurrency" "synchronous-sends" } "Synchronous sends"
"The " { $link send } " word sends a message asynchronously, and the sending thread continues immediately. It is also possible to send a message to a thread and block until a response is received:"
{ $subsection send-synchronous }
"To reply to a synchronous message:"
{ $subsection reply-synchronous }
"An example:"
{ $example
    "USING: concurrency.messaging kernel threads ;"
    ": pong-server ( -- )"
    "    receive >r \"pong\" r> reply-synchronous ;"
    "[ pong-server t ] spawn-server"
    "\"ping\" swap send-synchronous ."
    "\"pong\""
} ;

ARTICLE: { "concurrency" "exceptions" } "Linked exceptions"
"A thread can handle exceptions using the standard Factor exception handling mechanism. If an exception is uncaught the thread will terminate. For example:" 
{ $code "[ 1 0 / \"This will not print\" print ] spawn" } 
"Processes can be linked so that a parent thread can receive the exception that caused the child thread to terminate. In this way 'supervisor' threades can be created that are notified when child threades terminate and possibly restart them."
{ $subsection spawn-linked }
"A more flexible version of the above deposits the error in an arbitary mailbox:"
{ $subsection spawn-linked-to }
"This will create a unidirectional link, such that if an uncaught exception causes the child to terminate, the parent thread can catch it:"
{ $code "["
"  [ 1 0 / \"This will not print\" print ] spawn-linked drop"
"  receive"
"] [ \"Exception caught.\" print ] recover" } 
"Exceptions are only raised in the parent when the parent does a " { $link receive } " or " { $link receive-if } ". This is because the exception is sent from the child to the parent as a message." ;

ARTICLE: "concurrency.messaging" "Message-passing concurrency"
"The " { $vocab-link "concurrency.messaging" } " vocabulary is based upon the style of concurrency used in systems like Erlang and Termite. It is built on top of the standard Factor lightweight thread system."
$nl
"A concurrency oriented program is one in which multiple threades run simultaneously in a single Factor image or across multiple running Factor instances. The threades can communicate with each other by asynchronous message sends."
$nl
"Although threades can share data via Factor's mutable data structures it is not recommended to mix shared state with message passing as it can lead to confusing code."
{ $subsection { "concurrency" "mailboxes" } }
{ $subsection { "concurrency" "synchronous-sends" } } 
{ $subsection { "concurrency" "exceptions" } } ;

ABOUT: "concurrency.messaging"
