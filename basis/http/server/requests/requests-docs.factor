USING: help.markup help.syntax http io ;
IN: http.server.requests

HELP: read-request
{ $values { "request" request } }
{ $description "Reads a HTTP requests from the input stream." } ;

ARTICLE: "http.server.requests" "Deserializing HTTP requests"
"The " { $vocab-link "http.server.requests" } " reads requests from the " { $link input-stream } " and creates " { $link request } " tuples." ;

ABOUT: "http.server.requests"
