USING: help.markup help.syntax http math strings ;
IN: http.server.responses

HELP: <content>
{ $values { "body" "a response body" } { "content-type" string } { "response" response } }
{ $description "Creates a successful HTTP response which sends a response body with the specified content type to the client." } ;

HELP: <text-content>
{ $values { "body" "a response body" } { "response" response } }
{ $description "Creates a response with content type " { $snippet "text/plain" } "." } ;

HELP: <html-content>
{ $values { "body" "a response body" } { "response" response } }
{ $description "Creates a response with content type " { $snippet "text/html" } "." } ;

{ <content> <text-content> <html-content> } related-words

HELP: <trivial-response>
{ $values { "code" integer } { "message" string } { "response" response } }
{ $description "Creates an HTTP error response." }
{ $examples
    { $code
        "USE: http.server.responses"
        "415 \"Unsupported Media Type\" <trivial-response>"
    }
} ;

ARTICLE: "http.server.responses" "Canned HTTP responses"
"The " { $vocab-link "http.server.responses" } " vocabulary provides constructors for a few useful " { $link response } " objects." $nl
"For successful responses:"
{ $subsections
    <content>
    <text-content>
    <html-content>
}
"For errors:"
{ $subsections
    <304>
    <403>
    <400>
    <404>
}
"New error responses like the above can be created for other error codes too:"
{ $subsections <trivial-response> } ;

ABOUT: "http.server.responses"
