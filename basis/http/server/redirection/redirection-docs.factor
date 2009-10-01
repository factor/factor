USING: help.markup help.syntax urls strings http ;
IN: http.server.redirection

HELP: relative-to-request
{ $values { "url" "a " { $link url } " or " { $link string } } { "url'" "a " { $link url } " or " { $link string } } }
{ $description "If the input is a relative " { $link url } ", makes it an absolute URL by resolving it to the current request's URL. If the input is a string, does nothing." } ;

HELP: <permanent-redirect>
{ $values { "url" "a " { $link url } " or " { $link string } } { "response" response } }
{ $description "Redirects to the user to the URL after applying " { $link relative-to-request } "." }
{ $notes "This redirect type should always be used with POST requests, and with GET requests in cases where the new URL always supercedes the old one. This is due to browsers caching the new URL with permanent redirects." } ;

HELP: <temporary-redirect>
{ $values { "url" "a " { $link url } " or " { $link string } } { "response" response } }
{ $description "Redirects to the user to the URL after applying " { $link relative-to-request } "." }
{ $notes "This redirect type should be used with GET requests where the new URL does not always supercede the old one. Use from POST requests with care, since this will cause the browser to resubmit the form to the new URL." } ;

ARTICLE: "http.server.redirection" "HTTP responder redirection"
"The " { $vocab-link "http.server.redirection" } " defines some " { $link response } " types which redirect the user's client to a new page."
{ $subsections
    <permanent-redirect>
    <temporary-redirect>
}
"A utility used by the above:"
{ $subsections relative-to-request }
"The " { $vocab-link "furnace.redirection" } " vocabulary provides a higher-level implementation of this. The " { $vocab-link "furnace.conversations" } " vocabulary allows state to be maintained between redirects." ;

ABOUT: "http.server.redirection"
