USING: help.markup help.syntax io.streams.string quotations strings urls http vocabs.refresh math io.servers.connection ;
IN: http.server

HELP: trivial-responder
{ $description "The class of trivial responders, which output the same response for every request. New instances are created by calling " { $link <trivial-responder> } "." } ;

HELP: <trivial-responder>
{ $values { "response" response } { "trivial-responder" trivial-responder } }
{ $description "Creates a new trivial responder which outputs the same response for every request." } ;

HELP: benchmark?
{ $var-description "If set to a true value, the HTTP server will log the time taken to process each request." } ;

HELP: call-responder
{ $values
     { "path" "a sequence of strings" } { "responder" "a responder" }
     { "response" response } }
{ $description "Calls a responder." } ;

HELP: call-responder*
{ $values
     { "path" "a sequence of strings" } { "responder" "a responder" }
     { "response" response } }
{ $contract "Processes an HTTP request and returns a response." }
{ $notes "When this word is called, various dynamic variables are set; see " { $link "http.server.requests" } "." } ;

HELP: development?
{ $var-description "If set to a true value, the HTTP server will call " { $link refresh-all } " on each request, and error pages will contain stack traces." } ;

HELP: main-responder
{ $var-description "The responder which will handle HTTP requests." } ;

HELP: post-request?
{ $values { "?" "a boolean" } }
{ $description "Outputs if the current request is a POST request.s" } ;

HELP: responder-nesting
{ $description "A sequence of " { $snippet "{ path responder }" } " pairs." } ;

HELP: http-server
{ $class-description "The class of HTTP servers. New instances are created by calling " { $link <http-server> } "." } ;

HELP: <http-server>
{ $values { "server" http-server } }
{ $description "Creates a new HTTP server with default parameters." } ;

HELP: httpd
{ $values { "port" integer } }
{ $description "Starts an HTTP server on the specified port number." }
{ $notes "For more flexibility, use " { $link <http-server> } " and fill in the tuple slots before calling " { $link start-server } "." } ;

HELP: http-insomniac
{ $description "Starts a thread which rotates the logs and e-mails a summary of HTTP requests every 24 hours. See " { $link "logging.insomniac" } "." } ;

ARTICLE: "http.server.requests" "HTTP request variables"
"The following variables are set by the HTTP server at the beginning of a request."
{ $subsection request }
{ $subsection url }
{ $subsection post-request? }
{ $subsection responder-nesting }
"Additional vocabularies may be set by vocabularies such as " { $vocab-link "html.forms" } " and " { $vocab-link "furnace.sessions" } "." ;

ARTICLE: "http.server.responders" "HTTP server responders"
"The HTTP server dispatches requests to a main responder:"
{ $subsection main-responder }
"The main responder may in turn dispatch it a subordinate dispatcher, and so on."
$nl
"Responders process requests and output " { $link "http.responses" } "; concretely are instances of classes which implement a generic word:"
{ $subsection call-responder* }
"To actually call a subordinate responder, use the following word instead:"
{ $subsection call-responder }
"A simple implementation of a responder which always outputs the same response:"
{ $subsection trivial-responder }
{ $subsection <trivial-responder> }
{ $vocab-subsection "Furnace actions" "furnace.actions" }
"In particular, writing new responders by hand is rarely necessary, because in most cases it is easier to use " { $vocab-link "furnace.actions" } " instead." ;

ARTICLE: "http.server.variables" "HTTP server variables"
"The following global variables control the behavior of the HTTP server. Both are off by default."
{ $subsection development? }
{ $subsection benchmark? } ;

ARTICLE: "http.server" "HTTP server"
"The " { $vocab-link "http.server" } " vocabulary implements an HTTP and HTTPS server on top of " { $vocab-link "io.servers.connection" } "."
{ $subsection "http.server.responders" }
{ $subsection "http.server.requests" }
"Various types of responders are defined in other vocabularies:"
{ $subsection "http.server.dispatchers" }
{ $subsection "http.server.filters" }
"Useful canned responses:"
{ $subsection "http.server.responses" }
{ $subsection "http.server.redirection" }
"Configuration:"
{ $subsection "http.server.variables" }
{ $subsection "http.server.remapping" }
"Features:"
{ $subsection "http.server.static" }
{ $subsection "http.server.cgi" }
"The " { $vocab-link "furnace" } " framework implements high-level abstractions which make developing web applications much easier than writing responders by hand." ;

ABOUT: "http.server"
