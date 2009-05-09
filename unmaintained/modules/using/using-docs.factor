USING: modules.using modules.rpc-server help.syntax help.markup strings ;
IN: modules

HELP: service
{ $syntax "IN: module service" }
{ $description "Starts a server for requests for remote procedure calls." } ;

ARTICLE: { "modules" "remote-loading" } "Using the remote-loading vocabulary"
"If loaded, starts serving vocabularies, accessable through a " { $link POSTPONE: USING: } " form" ;

HELP: USING:
{ $syntax "USING: rpc-server::module fetch-sever::module { module qualified-name } { module => word ... } ... ;" }
{ $description "Adds vocabularies to the front of the search path.  Vocabularies can be fetched remotely, if preceded by a valid hostname.  Name pairs facilitate imports like in the "
{ $link POSTPONE: QUALIFIED: } " or " { $link POSTPONE: FROM: } " forms." } ;