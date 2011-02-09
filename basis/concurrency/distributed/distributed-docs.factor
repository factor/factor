USING: help.markup help.syntax concurrency.messaging threads ;
IN: concurrency.distributed

ARTICLE: "concurrency.distributed.example" "Distributed Concurrency Example"
"In this example the Factor instance associated with port 9000 will run "
"a thread that receives and prints messages "
"in the listener. The code to start the thread is:"
{ $examples
    { $unchecked-example
        ": log-message ( -- ) receive . flush log-message ;"
        "[ log-message ] \"logger\" spawn dup name>> register-remote-thread"
    }
}
"This spawns a thread waits for the messages. It registers that thread as a "
"able to be accessed remotely using " { $link register-remote-thread } "."
$nl
"The second Factor instance, the one associated with port 9001, can send "
"messages to the 'logger' thread by name:"
{ $examples
    { $unchecked-example
        "USING: io.sockets concurrency.messaging concurrency.distributed ;"
        "\"hello\" \"127.0.0.1\" 9000 <inet4> \"logger\" <remote-thread> send"
    }
}
"The " { $link send } " word is used to send messages to other threads. If an "
"instance of " { $link remote-thread } " is provided instead of a thread then "
"the message is marshalled to the named thread on the given machine using the "
{ $vocab-link "serialize" } " vocabulary."
$nl
"Running this code should show the message \"hello\" in the first Factor "
"instance."
$nl
"It is also possible to use " { $link send-synchronous } " to receive a "
"response to a distributed message. When an instance of " { $link thread } " "
"is marshalled it is converted into an instance of " { $link remote-thread }
". The receiver of this can use it as the target of a " { $link send }
" or " { $link reply } " call." ;

ARTICLE: "concurrency.distributed" "Distributed message passing"
"The " { $vocab-link "concurrency.distributed" } " implements transparent distributed message passing, inspired by Erlang and Termite." $nl
"Instances of " { $link thread } " can be sent to remote threads, at which point they are converted to objects holding the thread ID and the current node's host name:"
{ $subsections remote-thread }
"The " { $vocab-link "serialize" } " vocabulary is used to convert Factor objects to byte arrays for transfer over a socket."
{ $subsections "concurrency.distributed.example" } ;

ABOUT: "concurrency.distributed"
