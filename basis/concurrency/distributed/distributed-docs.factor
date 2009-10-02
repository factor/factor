USING: help.markup help.syntax concurrency.messaging threads ;
IN: concurrency.distributed

HELP: local-node
{ $var-description "A variable containing the node the current thread is running on." } ;

HELP: start-node
{ $values { "port" "a port number between 0 and 65535" } }
{ $description "Starts a node server for receiving messages from remote Factor instances." } ;

ARTICLE: "concurrency.distributed" "Distributed message passing"
"The " { $vocab-link "concurrency.distributed" } " implements transparent distributed message passing, inspired by Erlang and Termite."
{ $subsections start-node }
"Instances of " { $link thread } " can be sent to remote processes, at which point they are converted to objects holding the thread ID and the current node's host name:"
{ $subsections remote-process }
"The " { $vocab-link "serialize" } " vocabulary is used to convert Factor objects to byte arrays for transfer over a socket." ;

ABOUT: "concurrency.distributed"
