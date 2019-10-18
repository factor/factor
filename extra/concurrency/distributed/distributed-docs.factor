USING: help.markup help.syntax concurrency ;
IN: concurrency.distributed

HELP: <remote-process>
{ $values { "node" "a node object" } 
          { "pid" "a process id" } 
          { "remote-process" "the constructed remote-process object" } 
}
{ $description "Constructs a proxy to a process running on another node. It can be used to send messages to the process it is acting as a proxy for." } 
{ $see-also <node> <process> spawn send } ;


HELP: <node> 
{ $values { "hostname" "the hostname of the node as a string" } 
          { "port" "the integer port number of the node" } 
          { "node" "the constructed node object" } 
}
{ $description "Processes run on nodes. Each node has a hostname and a port." } 
{ $see-also localnode } ;

HELP: localnode
{ $values { "node" "a node object" } 
}
{ $description "Return the node the process is currently running on." } 
{ $see-also <node> } ;
