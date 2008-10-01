USING: http help.markup help.syntax io.files io.streams.string
io.encodings.8-bit io.encodings.binary kernel strings urls
urls.encoding byte-arrays strings assocs sequences ;
IN: http.client

HELP: download-failed
{ $error-description "Thrown by " { $link http-request } " if the server returns a status code other than 200. The " { $slot "response" } " and " { $slot "body" } " slots can be inspected for the underlying cause of the problem." } ;

HELP: too-many-redirects
{ $error-description "Thrown by " { $link http-request } " if the server returns a chain of than " { $link max-redirects } " redirections." } ;

HELP: <get-request>
{ $values { "url" "a " { $link url } " or " { $link string } } { "request" request } }
{ $description "Constructs an HTTP GET request for retrieving the URL." }
{ $notes "The request can be passed on to " { $link http-request } ", possibly after cookies and headers are set." } ;

HELP: <post-request>
{ $values { "post-data" object } { "url" "a " { $link url } " or " { $link string } } { "request" request } }
{ $description "Constructs an HTTP POST request for submitting post data to the URL." }
{ $notes "The request can be passed on to " { $link http-request } ", possibly after cookies and headers are set." } ;

HELP: download
{ $values { "url" "a " { $link url } " or " { $link string } } }
{ $description "Downloads the contents of the URL to a file in the " { $link current-directory } " having the same file name." }
{ $errors "Throws an error if the HTTP request fails." } ;

HELP: download-to
{ $values { "url" "a " { $link url } " or " { $link string } } { "file" "a pathname string" } }
{ $description "Downloads the contents of the URL to a file with the given pathname." }
{ $errors "Throws an error if the HTTP request fails." } ;

HELP: http-get
{ $values { "url" "a " { $link url } " or " { $link string } } { "response" response } { "data" sequence } }
{ $description "Downloads the contents of a URL." }
{ $errors "Throws an error if the HTTP request fails." } ;

HELP: http-post
{ $values { "post-data" object } { "url" "a " { $link url } " or " { $link string } } { "response" response } { "data" sequence } }
{ $description "Submits a form at a URL." }
{ $errors "Throws an error if the HTTP request fails." } ;

HELP: with-http-get
{ $values { "url" "a " { $link url } " or " { $link string } } { "quot" "a quotation with stack effect " { $snippet "( chunk -- )" } } { "response" response } }
{ $description "Downloads the contents of a URL. Chunks of data are passed to the quotation as they are read." }
{ $errors "Throws an error if the HTTP request fails." } ;

HELP: http-request
{ $values { "request" request } { "response" response } { "data" sequence } }
{ $description "Sends an HTTP request to an HTTP server, and reads the response." }
{ $errors "Throws an error if the HTTP request fails." } ;

HELP: with-http-request
{ $values { "request" request } { "quot" "a quotation with stack effect " { $snippet "( chunk -- )" } } { "response" response } }
{ $description "Sends an HTTP request to an HTTP server, and reads the response incrementally. Chunks of data are passed to the quotation as they are read." }
{ $errors "Throws an error if the HTTP request fails." } ;

ARTICLE: "http.client.get" "GET requests with the HTTP client"
"Basic usage involves passing a " { $link url } " and getting a " { $link response } " and data back:"
{ $subsection http-get }
"Utilities to retrieve a " { $link url } " and save the contents to a file:"
{ $subsection download }
{ $subsection download-to }
"Advanced usage involves constructing a " { $link request } ", which allows " { $link "http.cookies" } " and " { $link "http.headers" } " to be set:"
{ $subsection <get-request> }
{ $subsection http-request }
"The " { $link http-get } " and " { $link http-request } " words output sequences. This is undesirable if the response data may be large. Another pair of words take a quotation instead, and pass the quotation chunks of data incrementally:"
{ $subsection with-http-get }
{ $subsection with-http-request } ;

ARTICLE: "http.client.post" "POST requests with the HTTP client"
"As with GET requests, there is a high-level word which takes a " { $link url } " and a lower-level word which constructs an HTTP request object which can be passed to " { $link http-request } ":"
{ $subsection http-post }
{ $subsection <post-request> }
"Both words take a post data parameter, which can be one of the following:"
{ $list
    { "a " { $link byte-array } " or " { $link string } " is sent the server without further encoding" }
    { "an " { $link assoc } " is interpreted as a series of form parameters, which are encoded with " { $link assoc>query } }
    { { $link f } " denotes that there is no post data" }
} ;

ARTICLE: "http.client.encoding" "Character encodings and the HTTP client"
"The " { $link http-request } ", " { $link http-get } " and " { $link http-post } " words output a sequence containing data that was sent by the server."
$nl
"If the server specifies a " { $snippet "content-type" } " header with a character encoding, the HTTP client decodes the data using this character encoding, and the sequence will be a string."
$nl
"If no encoding was specified but the MIME type is a text type, the " { $link latin1 } " encoding is assumed, and the sequence will be a string."
$nl
"For any other MIME type, the " { $link binary } " encoding is assumed, and thus the data is returned literally in a byte array." ;

ARTICLE: "http.client.errors" "HTTP client errors"
"HTTP operations may fail for one of two reasons. The first is an I/O error resulting from a network problem; a name server lookup failure, or a refused connection. The second is a protocol-level error returned by the server. There are two such errors:"
{ $subsection download-failed }
{ $subsection too-many-redirects } ;

ARTICLE: "http.client" "HTTP client"
"The " { $vocab-link "http.client" } " vocabulary implements an HTTP and HTTPS client on top of " { $link "http" } "."
$nl
"There are two primary usage patterns, data retrieval with GET requests and form submission with POST requests:"
{ $subsection "http.client.get" }
{ $subsection "http.client.post" }
"More esoteric use-cases, for example HTTP methods other than the above, are accomodated by constructing an empty request object with " { $link <request> } " and filling everything in by hand."
{ $subsection "http.client.encoding" }
{ $subsection "http.client.errors" }
{ $see-also "urls" } ;

ABOUT: "http.client"
