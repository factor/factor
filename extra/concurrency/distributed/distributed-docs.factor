USING: help.markup help.syntax concurrency.messaging ;
IN: concurrency.distributed

HELP: <remote-process>
{ $values { "node" "a node object" } 
          { "pid" "a process id" } 
          { "remote-process" "the constructed remote-process object" } 
}
{ $description "Constructs a proxy to a process running on another node. It can be used to send messages to the process it is acting as a proxy for." } 
{ $see-also spawn send } ;

HELP: localnode
{ $values { "node" "a node object" } 
}
{ $description "Return the node the process is currently running on." } ;
