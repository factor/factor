USING: help.markup help.syntax concurrency.messaging io.servers threads ;
IN: concurrency.distributed

HELP: local-node
{ $var-description "A variable containing the " { $link threaded-server } " the current node is running on." } ;

HELP: start-node
{ $values { "addrspec" "an addrspec to listen on" } }
{ $description "Starts a " { $link threaded-server } " for receiving messages from remote Factor instances." } ;

ARTICLE: "concurrency.distributed.example" "Distributed Concurrency Example"
"In this example the Factor instance associated with port 9000 will run "
"a thread that receives and prints messages in the listener. "
"The code to run the server is:"
{ $code
  "USING: io.servers ;"
  "9000 local-server start-node"
}
"The code to start the thread is:"
{ $code
    "USING: concurrency.messaging threads ;"
    ": log-message ( -- ) receive . flush log-message ;"
    "[ log-message ] \"logger\" [ spawn ] keep register-remote-thread"
}
"This spawns a thread that waits for the messages and prints them. It registers "
"the thread as remotely accessible with " { $link register-remote-thread } "."
$nl
"The second Factor instance can send "
"messages to the 'logger' thread by name:"
{ $code
    "USING: io.servers concurrency.distributed ; FROM: concurrency.messaging => send ;"
    "\"hello\" 9000 local-server \"logger\" <remote-thread> send"
}
"The " { $link send } " word is used to send messages to threads. If an "
"instance of " { $link remote-thread } " is provided, then "
"the message is marshalled to the named thread on the given machine using the "
{ $vocab-link "serialize" } " vocabulary."
$nl
"Running this code should show the message \"hello\" in the first Factor "
"instance."
$nl
"It is also possible to use " { $link send-synchronous } " to receive a "
"response to a distributed message. When an instance of " { $link thread } " "
"is marshalled, it is converted into an instance of " { $link remote-thread }
". The receiver of this can use it as the target of a " { $link send }
", " { $link send-synchronous } " or " { $link reply-synchronous } " call."
$nl
"Note: " { $link send-synchronous } " can only work if " { $link local-node } " is assigned (use " { $link start-node } "), because there must be a server for the remote instance to send its reply to." ;

ARTICLE: "concurrency.distributed" "Distributed message passing"
"The " { $vocab-link "concurrency.distributed" } " implements transparent distributed message passing, inspired by Erlang and Termite." $nl
{ $subsections local-node start-node }
"Instances of " { $link thread } " can be sent to remote nodes, at which point they are converted to objects holding the thread ID and the current node's addrspec:"
{ $subsections remote-thread }
"The " { $vocab-link "serialize" } " vocabulary is used to convert Factor objects to byte arrays for transfer over a socket."
{ $subsections "concurrency.distributed.example" } ;

ABOUT: "concurrency.distributed"
