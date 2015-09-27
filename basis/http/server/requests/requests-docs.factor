USING: help.markup help.syntax http io ;
IN: http.server.requests

HELP: read-request
{ $values { "request" request } }
{ $description "Reads a HTTP requests from the input stream. If the request is not valid or can not be parsed, then a " { $link request-error } " is thrown." } ;

HELP: request-error
{ $class-description "Thrown by " { $link read-request } " if the HTTP request was invalid." } ;

HELP: bad-request-line
{ $class-description "Thrown by " { $link read-request } " if the HTTP requests request line could not be parsed." } ;

ARTICLE: "http.server.requests" "Deserializing HTTP requests"
"The " { $vocab-link "http.server.requests" } " reads requests from the " { $link input-stream } " and creates " { $link request } " tuples." ;

ABOUT: "http.server.requests"
