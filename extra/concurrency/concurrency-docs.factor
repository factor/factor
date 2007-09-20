! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup concurrency concurrency.private match ;
IN: concurrency

HELP: make-mailbox
{ $values { "mailbox" "a mailbox object" } 
}
{ $description "A mailbox is an object that can be used for safe thread communication. Items can be put in the mailbox and retrieved in a FIFO order. If the mailbox is empty when a get operation is performed then the thread will block until another thread places something in the mailbox. If multiple threads are waiting on the same mailbox, only one of the waiting threads will be unblocked to process the get operation." } 
{ $see-also mailbox-empty? mailbox-put mailbox-get mailbox-get-all while-mailbox-empty mailbox-get? } ;

HELP: mailbox-empty?
{ $values { "mailbox" "a mailbox object" } 
          { "bool" "a boolean value" }
}
{ $description "Return true if the mailbox is empty." } 
{ $see-also make-mailbox mailbox-put mailbox-get mailbox-get-all while-mailbox-empty mailbox-get? } ;

HELP: mailbox-put
{ $values { "obj" "an object" } 
          { "mailbox" "a mailbox object" } 
}
{ $description "Put the object into the mailbox. Any threads that have a blocking get on the mailbox are resumed. Only one of those threads will successfully get the object, the rest will immediately block waiting for the next item in the mailbox." } 
{ $see-also make-mailbox mailbox-empty? mailbox-get mailbox-get-all while-mailbox-empty mailbox-get? } ;

HELP: (mailbox-block-unless-pred)
{ $values { "pred" "a quotation with stack effect " { $snippet "( X -- bool )" } } 
          { "mailbox" "a mailbox object" } 
	  { "pred2" "same object as 'pred'" }
	  { "mailbox2" "same object as 'mailbox'" }
}
{ $description "Block the thread if there are no items in the mailbox that return true when the predicate is called with the item on the stack. The predicate must have stack effect " { $snippet "( X -- bool )" } "." } 
{ $see-also make-mailbox mailbox-empty? mailbox-put mailbox-get mailbox-get-all while-mailbox-empty mailbox-get? } ;

HELP: (mailbox-block-if-empty)
{ $values { "mailbox" "a mailbox object" } 
	  { "mailbox2" "same object as 'mailbox'" }
}
{ $description "Block the thread if the mailbox is empty." } 
{ $see-also make-mailbox mailbox-empty? mailbox-put mailbox-get mailbox-get-all while-mailbox-empty mailbox-get? } ;

HELP: mailbox-get
{ $values { "mailbox" "a mailbox object" } 
	  { "obj" "an object" }
}
{ $description "Get the first item put into the mailbox. If it is empty the thread blocks until an item is put into it. The thread then resumes, leaving the item on the stack." } 
{ $see-also make-mailbox mailbox-empty? mailbox-put while-mailbox-empty mailbox-get-all mailbox-get? } ;

HELP: mailbox-get-all
{ $values { "mailbox" "a mailbox object" } 
	  { "array" "an array" }
}
{ $description "Blocks the thread if the mailbox is empty, otherwise removes all objects in the mailbox and returns an array containing the objects." } 
{ $see-also make-mailbox mailbox-empty? mailbox-put while-mailbox-empty mailbox-get-all mailbox-get? } ;

HELP: while-mailbox-empty
{ $values { "mailbox" "a mailbox object" } 
	  { "quot" "a quotation with stack effect " { $snippet "( -- )" } }
}
{ $description "Repeatedly call the quotation while there are no items in the mailbox. Quotation should have stack effect " { $snippet "( -- )" } "." } 
{ $see-also make-mailbox mailbox-empty? mailbox-put mailbox-get mailbox-get-all mailbox-get? } ;

HELP: mailbox-get?
{ $values { "pred" "a quotation with stack effect " { $snippet "( X -- bool )" } }
          { "mailbox" "a mailbox object" } 
	  { "obj" "an object" }
}
{ $description "Get the first item in the mailbox which satisfies the predicate. 'pred' will be called repeatedly for each item in the mailbox. When 'pred' returns true that item will be returned. If nothing in the mailbox satisfies the predicate then the thread will block until something does. 'pred' must have stack effect " { $snippet "( X -- bool }" } "." } 
{ $see-also make-mailbox mailbox-empty? mailbox-put mailbox-get mailbox-get-all while-mailbox-empty } ;

HELP: <process>
{ $values { "links" "an array of processes" } 
          { "pid" "the process id" } 
          { "mailbox" "a mailbox object" } 
}
{ $description "Constructs a process object. A process is a lightweight thread with a mailbox that can be used to communicate with other processes. Each process has a unique process id." } 
{ $see-also spawn send receive } ;

HELP: self
{ $values { "process" "a process object" } 
}
{ $description "Returns the currently running process object." } 
{ $see-also <process> send receive receive-if } ;

HELP: send
{ $values { "message" "an object" } 
          { "process" "a process object" } 
}
{ $description "Send the message to the process by placing it in the processes mailbox. This is an asynchronous operation and will return immediately. The receving process will act on the message the next time it retrieves that item from its mailbox (usually using the " { $link receive } " word. The message can be any Factor object. For destinations that are instances of remote-process the message must be a serializable Factor type." } 
{ $see-also <process> receive receive-if } ;

HELP: receive
{ $values { "message" "an object" } 
}
{ $description "Return a message from the current processes mailbox. If the box is empty, suspend the process until another process places an item in the mailbox (usually via the " { $link send } " word." } 
{ $see-also send receive-if } ;

HELP: receive-if
{ $values { "pred" "a predicate with stack effect " { $snippet "( X -- bool )" } }  
          { "message" "an object" } 
}
{ $description "Return the first message from the current processes mailbox that satisfies the predicate. To satisfy the predicate, 'pred' is called  with the item on the stack and the predicate should leave a boolean indicating whether it was satisfied or not. The predicate must have stack effect " { $snippet "( X -- bool )" } ". If nothing in the mailbox satisfies the predicate then the process will block until something does." } 
{ $see-also send receive } ;

HELP: spawn
{ $values { "quot" "a predicate with stack effect " { $snippet "( -- )" } }  
          { "process" "a process object" } 
}
{ $description "Start a process which runs the given quotation." } 
{ $see-also send receive receive-if self spawn-link } ;

HELP: spawn-link
{ $values { "quot" "a predicate with stack effect " { $snippet "( -- )" } }  
          { "process" "a process object" } 
}
{ $description "Start a process which runs the given quotation. If that quotation throws an error which is not caught then the error will get propagated to the process that spawned it. This can be used to set up 'supervisor' processes that restart child processes that crash due to uncaught errors.\n" } 
{ $see-also spawn } ;

ARTICLE: { "concurrency" "loading" } "Loading"
"The Factor module system can be used to load the Concurrency library:" 
{ $code "USING: concurrency ;" } ;

ARTICLE: { "concurrency" "processes" } "Processes"
"A process is basically a thread with a message queue. Other processes can place items on this queue by sending the process a message. A process can check its queue for messages, blocking if none are pending, and process them as they are queued.\n\nFactor processes are very lightweight. Each process can take as little as 900 bytes of memory. This library has been tested running hundreds of thousands of simple processes.\n\nThe messages that are sent from process to process are any Factor value. Factor tuples are ideal for this sort of thing as you can send a tuple to a process and the predicate dispatch mechanism can be used to perform actions depending on what the type of the tuple is.\n\nProcesses are usually created using " { $link spawn } ". This word takes a quotation on the stack and starts a process that will execute that quotation asynchronously. When the quotation completes the process will die. 'spawn'  leaves on the stack the process object that was started. This object can be used to send messages to the process using " { $link send }  ".\n\n'send' will return immediately after placing the message in the target processes message queue.\n\nA process can get a message from its queue using " { $link receive } ". This will get the most recent message and leave it on the stack. If there are no messages in the queue the process will 'block' until a message is available. When a process is blocked it takes no CPU time at all." 
{ $code "[ receive print ] spawn\n\"Hello Process!\" swap send" } 
"This example spawns a process that first blocks, waiting to receive a message. When a message is received, the 'receive' call returns leaving it on the stack. It then prints the message and exits. 'spawn' left the process on the stack so it's available to send the 'Hello Process!' message to it. Immediately after the 'send' you should see 'Hello Process!' printed on the console.\n\nIt is also possible to selectively retrieve messages from the message queue. " { $link receive-if } " takes a predicate quotation on the stack and returns the first message in the queue that satisfies the predicate. If no items satisfy the predicate then the process is blocked until a message is received that does." 
{ $code ": odd? ( n -- ? ) 2 mod 1 = ;\n1 self send 2 self send 3 self send\n\nreceive .\n => 1\n\n[ odd? ] receive-if .\n => 3\n\nreceive .\n => 2" } ;

ARTICLE: { "concurrency" "self" } "Self"
"A process can get access to its own process object using " { $link self } " so it can pass it to other processes. This allows the other processes to send messages back. A simple example of using this gets the current processes 'self' and spawns a process which sends a message to it. We then receive the message from the original process:" 
{ $code "self [ \"Hello!\" swap send ] spawn 2drop receive .\n => \"Hello!\"" } ;

ARTICLE: { "concurrency" "servers" } "Servers"
"A common idiom is to create 'server' processes that act on messages that are sent to it. These follow a basic pattern of blocking until a message is received, processing that message then looping back to blocking for a message.\n\nThe following example shows a very simple server that expects an array as its message. The first item of the array should be the senders process object. If the second item is 'ping' then the server sends 'pong' back to the caller. If the second item is anything else then the server exits:" 
{ $code ": pong-server ( -- )\n  receive {\n    { { ?from \"ping\" } [ \"pong\" ?from send pong-server ] }\n    { { ?from _ } [ \"server shutdown\" ?from send ] }\n  } match-cond ;\n\n[ pong-server ] spawn" } 
"Handling the deconstructing of messages and dispatching based on the message can be a bit of a chore. Especially in servers that take a number of different messages. The approach taken above is to use the 'match' library which allows easy deconstructing of messages using " { $link match-cond } "." ;

ARTICLE: { "concurrency" "synchronous-sends" } "Synchronous Sends"
{ $link send } " sends a message asynchronously, and the sending process continues immediately. The 'pong server' example shown previously all sent messages to the server and waited for a reply back from the server. This pattern of synchronous sending is made easier with " { $link send-synchronous } ".\n\nThis word will send a message to the given process and immediately block until a reply is received for this particular message send. It leaves the reply on the stack. Note that it doesn't wait for just any reply, it waits for a reply specifically to this send.\n\nTo do this it wraps the requested message inside a tagged message format using " { $link tag-message } ":"
{ $code "\"My Message\" tag-message .\n => { ...from... ...tag... \"My Message\" }" }
"The message is wrapped in array where the first item is the sending process object, the second is a unique tag, and the third is the original message. Server processes can use the 'from' to reply to the process that originally sent the message. The tag can is used in the receiving server to include the value in the reply. After the send-synchronous call the current process will block waiting for a reply that has the exact same tag. In this way you can be sure that the reply you got was for the specific message sent. Here is the pong-server recoded to use 'send-synchronous':"
{ $code ": pong-server ( -- )\n  receive {\n    { { ?from ?tag \"ping\" } [ ?tag \"pong\" 2array ?from send pong-server ] }\n    { { ?from _ } [ ?tag \"server shutdown\" 2array ?from send ] }\n  } match-cond ;\n\n[ pong-server ] spawn \"ping\" swap send-synchronous .\n => \"pong\"" } 
"Notice that the code to send the reply back to the original caller wraps the reply in an array where the first item is the tag originally sent. 'send-synchronous' only returns if it receives a reply containing that specific tag." ;

ARTICLE: { "concurrency" "exceptions" } "Exceptions"
"A process can handle exceptions using the standard Factor exception handling mechanism. If an exception is uncaught the process will terminate. For example:" 
{ $code "[ 1 0 / \"This will not print\" print ] spawn" } 
"Processes can be linked so that a parent process can receive the exception that caused the child process to terminate. In this way 'supervisor' processes can be created that are notified when child processes terminate and possibly restart them.\n\nThe easiest way to form this link is using " { $link spawn-link } ". This will create a unidirectional link, such that if an uncaught exception causes the child to terminate, the parent process can catch it:"
{ $code "[\n  [ 1 0 / \"This will not print\" print ] spawn-link drop\n  receive\n] catch [ \"Exception caught.\" print ] when" } 
"Exceptions are only raised in the parent when the parent does a " { $link receive } " or " { $link receive-if } ". This is because the exception is sent from the child to the parent as a message." ;

ARTICLE: { "concurrency" "futures" } "Futures"
"A future is a placeholder for the result of a computation that is being calculated in a process. When the process has completed the computation the future can be queried to find out the result. If the computation has not completed when the future is queried them the process will block until the result is completed. <p>A future is created using " { $link future } ".\n\nThe quotation will be run in a spawned process, and a future object is immediately returned. This future object can be resolved using " { $link ?future } ".\n\nFutures are useful for starting calculations that take a long time to run but aren't needed until later in the process. When the process needs the value it can use '?future' to get the result or block until the result is available. For example:"
{ $code "[ 30 fib ] future\n...do stuff...\n?future" } ;

ARTICLE: { "concurrency" "promises" } "Promises"
"A promise is similar to a future but it is not produced by calculating something in the background. It represents a promise to provide a value sometime later. A process can request the value of a promise and will block if the promise is not fulfilled. Later, another process can fulfill the promise, providing a value. All threads waiting on the promise will then resume with that value on the stack. Use " { $link <promise> } " to create a promise, " { $link fulfill } " to set it to a value, and " { $link ?promise } " to retrieve the value, or block until the promise is fulfilled:"
{ $code "<promise>\n[ ?promise \"Promise fulfilled: \" write print ] spawn drop\n[ ?promise \"Promise fulfilled: \" write print ] spawn drop\n[ ?promise \"Promise fulfilled: \" write print ] spawn drop\n\"hello\" swap fulfill\n => Promise fulfilled: hello\n    Promise fulfilled: hello\n    Promise fulfilled: hello" } ;

ARTICLE: { "concurrency" "concurrency" } "Concurrency"
"The concurrency library is based upon the style of concurrency used in systems like Erlang and Termite. It is built on top of the standard Factor lightweight thread system.\nA concurrency oriented program is one in which multiple processes run simultaneously in a single Factor image or across multiple running Factor instances. The processes can communicate with each other by asynchronous message sends. Although processes can share data via Factor's mutable data structures it is not recommended as the use of shared state concurrency is often a cause of problems."
{ $subsection { "concurrency" "loading" } } 
{ $subsection { "concurrency" "processes" } } 
{ $subsection { "concurrency" "self" } } 
{ $subsection { "concurrency" "servers" } } 
{ $subsection { "concurrency" "synchronous-sends" } } 
{ $subsection { "concurrency" "exceptions" } } 
{ $subsection { "concurrency" "futures" } } 
{ $subsection { "concurrency" "promises" } } ;

ABOUT: { "concurrency" "concurrency" }