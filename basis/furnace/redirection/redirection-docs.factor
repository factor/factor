USING: help.markup help.syntax http quotations urls ;
IN: furnace.redirection

HELP: <redirect-responder>
{ $values { "url" url } { "responder" "a responder" } }
{ $description "Creates a responder which unconditionally redirects the client to the given URL." } ;

HELP: <redirect>
{ $values { "url" url } { "response" response } }
{ $description "Creates a response which redirects the client to the given URL." } ;

HELP: <secure-only>
{ $values { "responder" "a responder" } { "secure-only" "a responder" } }
{ $description "Creates a new responder which ensures that the client is connecting via HTTPS before delegating to the underlying responder. If the client is connecting via HTTP, a redirect is sent instead." } ;

HELP: <secure-redirect>
{ $values
    { "url" url }
    { "response" response }
}
{ $description "Creates a responder which unconditionally redirects the client to the given URL after setting its protocol to HTTPS." }
{ $notes "This word is intended to be used with a relative URL. The client is redirected to the relative URL, but with HTTPS instead of HTTP." } ;

HELP: >secure-url
{ $values
    { "url" url }
    { "url'" url }
}
{ $description "Sets the protocol of a URL to HTTPS." } ;

HELP: if-secure
{ $values
    { "quot" quotation }
    { "response" response }
}
{ $description "Runs a quotation if the current request was made over HTTPS, otherwise returns a redirect to have the client request the current page again via HTTPS." } ;

ARTICLE: "furnace.redirection.secure" "Secure redirection"
"The words in this section help with implementing sites which require SSL/TLS for additional security."
$nl
"Converting a HTTP URL into an HTTPS URL:"
{ $subsections >secure-url }
"Redirecting the client to an HTTPS URL:"
{ $subsections <secure-redirect> }
"Tools for writing responders which require SSL/TLS connections:"
{ $subsections
    if-secure
    <secure-only>
} ;

ARTICLE: "furnace.redirection" "Furnace redirection support"
"The " { $vocab-link "furnace.redirection" } " vocabulary builds additional functionality on top of " { $vocab-link "http.server.redirection" } ", and integrates with various Furnace features such as " { $vocab-link "furnace.asides" } " and " { $vocab-link "furnace.conversations" } "."
$nl
"A redirection response which takes asides and conversations into account:"
{ $subsections <redirect> }
"A responder which unconditionally redirects the client to another URL:"
{ $subsections
    <redirect-responder>
    "furnace.redirection.secure"
} ;

ABOUT: "furnace.redirection"
