USING: help.markup help.syntax concurrency.messaging threads ;
IN: concurrency.distributed

HELP: local-node
{ $var-description "A variable containing the node the current thread is running on." } ;

HELP: start-node
{ $values { "port" "a port number between 0 and 65535" } }
{ $description "Starts a node server for receiving messages from remote Factor instances." } ;

ARTICLE: "concurrency.distributed.example" "Distributed Concurrency Example"
"For a Factor instance to be able to send and receive distributed "
"concurrency messages it must first have " { $link start-node } " called."
$nl
"In one factor instance call " { $link start-node } " with the port 9000, "
"and in another with the port 9001."
$nl
"In this example the Factor instance associated with port 9000 will run "
"a thread that sits receiving messages and printing the received message "
"in the listener. The code to start the thread is: "
{ $examples
    { $unchecked-example
        ": log-message ( -- ) receive . flush log-message ;"
        "[ log-message ] \"logger\" spawn [ name>> ] keep register-process"
    }
}
"This spawns a thread waits for the messages. It registers that thread as a "
"able to be accessed remotely using " { $link register-process } "."
$nl
"The second Factor instance, the one associated with port 9001, can send "
"messages to the 'logger' process by name:"
{ $examples
    { $unchecked-example
        "USING: io.sockets concurrency.messaging concurrency.distributed ;"
        "\"hello\" \"logger\" \"127.0.0.1\" 9000 <inet4> <remote-process> send"
    }
}
"The " { $link send } " word is used to send messages to other threads. If an "
"instance of " { $link remote-process } " is provided instead of a thread then "
"the message is marshalled to the named process on the given machine using the "
{ $vocab-link "serialize" } " vocabulary."
$nl
"Running this code should show the message \"hello\" in the first Factor "
"instance."
$nl
"It is also possible to use " { $link send-synchronous } " to receive a "
"response to a distributed message. When an instance of " { $link thread } " "
"is marshalled it is converted into an instance of " { $link remote-process }
". The receiver of this can use it as the target of a " { $link send }
" or " { $link reply } " call." ;

ARTICLE: "concurrency.distributed" "Distributed message passing"
"The " { $vocab-link "concurrency.distributed" } " implements transparent distributed message passing, inspired by Erlang and Termite."
{ $subsections start-node }
"Instances of " { $link thread } " can be sent to remote processes, at which point they are converted to objects holding the thread ID and the current node's host name:"
{ $subsections remote-process }
"The " { $vocab-link "serialize" } " vocabulary is used to convert Factor objects to byte arrays for transfer over a socket." 
{ $subsections "concurrency.distributed.example" } ;


ABOUT: "concurrency.distributed"
