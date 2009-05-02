USING: http help.markup help.syntax io.pathnames io.streams.string
io.encodings.8-bit io.encodings.binary kernel strings urls
urls.encoding byte-arrays strings assocs sequences destructors
http.client.post-data.private ;
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
{ $description "Submits an HTTP POST request." }
{ $errors "Throws an error if the HTTP request fails." } ;

HELP: http-put
{ $values { "post-data" object } { "url" "a " { $link url } " or " { $link string } } { "response" response } { "data" sequence } }
{ $description "Submits an HTTP PUT request." }
{ $errors "Throws an error if the HTTP request fails." } ;

HELP: with-http-get
{ $values { "url" "a " { $link url } " or " { $link string } } { "quot" { $quotation "( chunk -- )" } } { "response" response } }
{ $description "Downloads the contents of a URL. Chunks of data are passed to the quotation as they are read." }
{ $errors "Throws an error if the HTTP request fails." } ;

HELP: http-request
{ $values { "request" request } { "response" response } { "data" sequence } }
{ $description "Sends an HTTP request to an HTTP server, and reads the response." }
{ $errors "Throws an error if the HTTP request fails." } ;

HELP: with-http-request
{ $values { "request" request } { "quot" { $quotation "( chunk -- )" } } { "response" response } }
{ $description "Sends an HTTP request to an HTTP server, and reads the response incrementally. Chunks of data are passed to the quotation as they are read. Does not throw an error if the HTTP request fails; to do so, call " { $link check-response } " on the " { $snippet "response" } "." } ;

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

ARTICLE: "http.client.post-data" "HTTP client post data"
"HTTP POST and PUT request words take a post data parameter, which can be one of the following:"
{ $list
    { "a " { $link byte-array } ": the data is sent the server without further encoding" }
    { "a " { $link string } ": the data is encoded and then sent as a series of bytes" }
    { "an " { $link assoc } ": the assoc is interpreted as a series of form parameters, which are encoded with " { $link assoc>query } }
    { "an input stream: the contents of the input stream are transmitted to the server without being read entirely into memory - this is useful for large requests" }
    { { $link f } " denotes that there is no post data" }
    { "a " { $link post-data } " tuple, for additional control" }
}
"When passing a stream, you must ensure the stream is closed afterwards. The best way is to use " { $link with-disposal } " or " { $link "destructors" } ". For example,"
{ $code
  "\"my-large-post-request.txt\" ascii <file-reader>"
  "[ URL\" http://www.my-company.com/web-service\" http-post ] with-disposal"
}
"An internal word used to convert objects to " { $link post-data } " instances:"
{ $subsection >post-data } ;

ARTICLE: "http.client.post" "POST requests with the HTTP client"
"Basic usage involves passing post data and a " { $link url } ", and getting a " { $link response } " and data back:"
{ $subsection http-post }
"Advanced usage involves constructing a " { $link request } ", which allows " { $link "http.cookies" } " and " { $link "http.headers" } " to be set:"
{ $subsection <post-request> }
"Both words take a post data parameter; see " { $link "http.client.post-data" } "." ;

ARTICLE: "http.client.put" "PUT requests with the HTTP client"
"Basic usage involves passing post data and a " { $link url } ", and getting a " { $link response } " and data back:"
{ $subsection http-post }
"Advanced usage involves constructing a " { $link request } ", which allows " { $link "http.cookies" } " and " { $link "http.headers" } " to be set:"
{ $subsection <post-request> }
"Both words take a post data parameter; see " { $link "http.client.post-data" } "." ;

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
"For HTTPS support, you must load the " { $vocab-link "urls.secure" } " vocab first. If you don't need HTTPS support, don't load " { $vocab-link "urls.secure" } "; this will reduce the size of images generated by " { $vocab-link "tools.deploy" } "."
$nl
"There are two primary usage patterns, data retrieval with GET requests and form submission with POST requests:"
{ $subsection "http.client.get" }
{ $subsection "http.client.post" }
{ $subsection "http.client.put" }
"Submission data for POST and PUT requests:"
{ $subsection "http.client.post-data" }
"More esoteric use-cases, for example HTTP methods other than the above, are accomodated by constructing an empty request object with " { $link <request> } " and filling everything in by hand."
{ $subsection "http.client.encoding" }
{ $subsection "http.client.errors" }
{ $see-also "urls" } ;

ABOUT: "http.client"
