USING: help.markup help.syntax concurrency.messaging ;
IN: concurrency.distributed

HELP: local-node
{ $values { "addrspec" "an address specifier" } 
}
{ $description "Return the node the current thread is running on." } ;
