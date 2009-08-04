USING: help.syntax help.markup modules.rpc-server modules.using ;
IN: modules.rpc-server
HELP: service
{ $syntax "IN: my-vocab service" }
{ $description "Allows words defined in the vocabulary to be used as remote procedure calls by " { $link POSTPONE: USING*: } } ;