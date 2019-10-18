USING: help.syntax help.markup strings modules.using ;
IN: modules.using
ARTICLE: { "modules.using" "use" } "Using the modules.using vocab"
"This vocabulary defines " { $link POSTPONE: USING*: } " as an alternative to " { $link POSTPONE: USING: } " which makes qualified imports easier. "
"Secondly, it allows loading vocabularies from remote servers, as long as the remote vocabulary can be accessed at compile time. "
"Finally, the word can treat words in remote vocabularies as remote procedure calls. Any inputs are passed to the imported words as normal, and the result will appear on the stack- the only difference is that the word isn't called locally." ;
ABOUT: { "modules.using" "use" }

HELP: USING*:
{ $syntax "USING: rpc-server::module fetch-sever:module { module qualified-name } { module => word ... } { qualified-module } { module EXCEPT word ... } { module word => importname } ;" }
{ $description "Adds vocabularies to the search path. Vocabularies can be loaded off a server or called as an rpc if preceded by a valid hostname. Bracketed pairs facilitate all types of qualified imports on both remote and local modules." } ;