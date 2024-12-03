USING: assocs byte-arrays destructors help.markup help.syntax http
http.client.post-data http.client.private
io.encodings.binary io.encodings.latin1 io.pathnames kernel
sequences strings urls urls.encoding ;
IN: http.client

HELP: download-failed
{ $error-description "Thrown by " { $link http-request } " if the server returns a status code other than 200. The " { $slot "response" } " slot can be inspected for the underlying cause of the problem." } ;

HELP: too-many-redirects
{ $error-description "Thrown by " { $link http-request } " if the server returns a chain of than " { $link max-redirects } " redirections." } ;

HELP: invalid-proxy
{ $error-description "Thrown by " { $link http-request } " if the proxy url is not valid." } ;

HELP: <get-request>
{ $values { "url" { $or url string } } { "request" request } }
{ $description "Constructs an HTTP GET request for retrieving the URL." }
{ $notes "The request can be passed on to " { $link http-request } ", possibly after cookies and headers are set." } ;

HELP: <post-request>
{ $values { "data" object } { "url" { $or url string } } { "request" request } }
{ $description "Constructs an HTTP POST request for submitting post data to the URL." }
{ $notes "The request can be passed on to " { $link http-request } ", possibly after cookies and headers are set." } ;

HELP: <head-request>
{ $values { "url" { $or url string } } { "request" request } }
{ $description "Constructs an HTTP HEAD request for retrieving the URL." }
{ $notes "The request can be passed on to " { $link http-request } ", possibly after cookies and headers are set." } ;

HELP: <delete-request>
{ $values { "url" { $or url string } } { "request" request } }
{ $description "Constructs an HTTP DELETE request for the requested URL." }
{ $notes "The request can be passed on to " { $link http-request } ", possibly after cookies and headers are set." } ;

HELP: <options-request>
{ $values { "url" { $or url string } } { "request" request } }
{ $description "Constructs an HTTP OPTIONS request for the requested URL." }
{ $notes "The request can be passed on to " { $link http-request } ", possibly after cookies and headers are set." } ;

HELP: <trace-request>
{ $values { "url" { $or url string } } { "request" request } }
{ $description "Constructs an HTTP TRACE request for the requested URL." }
{ $notes "The request can be passed on to " { $link http-request } ", possibly after cookies and headers are set." } ;

HELP: http-get
{ $values { "url" { $or url string } } { "response" response } { "data" sequence } }
{ $description "Downloads the contents of a URL." }
{ $errors "Throws an error if the HTTP request fails." } ;

HELP: http-get*
{ $values { "url" { $or url string } } { "response" response } { "data" sequence } }
{ $description "Downloads the contents of a URL, but does not check the HTTP response code for success." } ;

{ http-get http-get* } related-words

HELP: http-post
{ $values { "data" object } { "url" { $or url string } } { "response" response } { "data" sequence } }
{ $description "Submits an HTTP POST request." }
{ $errors "Throws an error if the HTTP request fails." } ;

HELP: http-post*
{ $values { "data" object } { "url" { $or url string } } { "response" response } { "data" sequence } }
{ $description "Submits an HTTP POST request, but does not check the HTTP response code for success." } ;

{ http-post http-post* } related-words

HELP: http-put
{ $values { "data" object } { "url" { $or url string } } { "response" response } { "data" sequence } }
{ $description "Submits an HTTP PUT request." }
{ $errors "Throws an error if the HTTP request fails." } ;

HELP: http-put*
{ $values { "data" object } { "url" { $or url string } } { "response" response } { "data" sequence } }
{ $description "Submits an HTTP PUT request, but does not check the HTTP response code for success." } ;

{ http-put http-put* } related-words

HELP: http-head
{ $values { "url" { $or url string } } { "response" response } { "data" sequence } }
{ $description "Same as " { $link http-get } " except that the server is not supposed to return a message-body in the response, as per RFC2616. However in practise, most web servers respond to GET and HEAD method calls with identical responses." }
{ $errors "Throws an error if the HTTP request fails." } ;

HELP: http-head*
{ $values { "url" { $or url string } } { "response" response } { "data" sequence } }
{ $description "Same as " { $link http-get* } " except that the server is not supposed to return a message-body in the response, as per RFC2616. However in practise, most web servers respond to GET and HEAD method calls with identical responses." } ;

{ http-head http-head* } related-words

HELP: http-delete
{ $values { "url" { $or url string } } { "response" response } { "data" sequence } }
{ $description "Requests that the origin server delete the resource identified by the URL." }
{ $errors "Throws an error if the HTTP request fails." } ;

HELP: http-delete*
{ $values { "url" { $or url string } } { "response" response } { "data" sequence } }
{ $description "Requests that the origin server delete the resource identified by the URL, but does not check the HTTP response code for success." } ;

{ http-delete http-delete* } related-words

HELP: http-options
{ $values { "url" { $or url string } } { "response" response } { "data" sequence } }
{ $description "Submits an HTTP OPTIONS request." }
{ $errors "Throws an error if the HTTP request fails." } ;

HELP: http-options*
{ $values { "url" { $or url string } } { "response" response } { "data" sequence } }
{ $description "Submits an HTTP OPTIONS request, but does not check the HTTP response code for success." } ;

{ http-options http-options* } related-words

HELP: http-patch
{ $values { "data" object } { "url" { $or url string } } { "response" response } { "data" sequence } }
{ $description "Submits an HTTP PATCH request." }
{ $errors "Throws an error if the HTTP request fails." } ;

HELP: http-patch*
{ $values { "data" object } { "url" { $or url string } } { "response" response } { "data" sequence } }
{ $description "Submits an HTTP PATCH request, but does not check the HTTP response code for success." } ;

{ http-patch http-patch* } related-words

HELP: http-trace
{ $values { "url" "a " { $link url } " or " { $link string } } { "response" response } { "data" sequence } }
{ $description "Submits an HTTP TRACE request." }
{ $errors "Throws an error if the HTTP request fails." } ;

HELP: http-trace*
{ $values { "url" { $or url string } } { "response" response } { "data" sequence } }
{ $description "Submits an HTTP TRACE request, but does not check the HTTP response code for success." } ;

{ http-trace http-trace* } related-words

HELP: http-request
{ $values { "request" request } { "response" response } { "data" sequence } }
{ $description "A variant of " { $link http-request* } " that checks that the response was successful." }
{ $errors "Throws an error if the HTTP request fails." } ;

HELP: http-request*
{ $values { "request" request } { "response" response } { "data" sequence } }
{ $description "Sends an HTTP request to an HTTP server, and reads the response." } ;

HELP: read-response-header
{ $values { "response" response } }
{ $description "Initializes the 'header', 'cookies', 'content-type', 'content-charset' and 'content-encoding' field of the response." } ;

HELP: with-http-request
{ $values { "request" request } { "quot" { $quotation ( chunk -- ) } } { "response/stream" "a response or a stream" } }
{ $description "A variant of " { $link do-http-request } " that checks that the response was successful." } ;

{ http-request http-request* with-http-request } related-words

ARTICLE: "http.client.get" "GET requests with the HTTP client"
"Basic usage involves passing a " { $link url } " and getting a " { $link response } " and data back:"
{ $subsections
    http-get
    http-get*
}
"To download to a file, see the " { $link "http.download" } " vocabulary."

"Advanced usage involves constructing a " { $link request } ", which allows " { $link "http.cookies" } " and " { $link "http.headers" } " to be set:"
{ $subsections
    <get-request>
    http-request
    http-request*
}
"The " { $link http-request } " and " { $link http-request* } " words output sequences. This is undesirable if the response data may be large. Another pair of words take a quotation instead, and pass the quotation chunks of data incrementally:"
{ $subsections
    with-http-request
} ;

ARTICLE: "http.client.post-data" "HTTP client post data"
"HTTP POST, PUT, and PATCH request words take a " { $snippet "data" } " parameter, which can be one of the following:"
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
{ $subsections >post-data } ;

ARTICLE: "http.client.post" "POST requests with the HTTP client"
"Basic usage involves passing post data and a " { $link url } ", and getting a " { $link response } " and data back:"
{ $subsections http-post http-post* }
"Advanced usage involves constructing a " { $link request } ", which allows " { $link "http.cookies" } " and " { $link "http.headers" } " to be set:"
{ $subsections <post-request> }
"Both words take a post data parameter; see " { $link "http.client.post-data" } "." ;

ARTICLE: "http.client.put" "PUT requests with the HTTP client"
"Basic usage involves passing post data and a " { $link url } ", and getting a " { $link response } " and data back:"
{ $subsections http-put http-put* }
"Advanced usage involves constructing a " { $link request } ", which allows " { $link "http.cookies" } " and " { $link "http.headers" } " to be set:"
{ $subsections <put-request> }
"Both words take a post data parameter; see " { $link "http.client.post-data" } "." ;

ARTICLE: "http.client.head" "HEAD requests with the HTTP client"
"Basic usage involves passing a " { $link url } " and getting a " { $link response } " and data back:"
{ $subsections http-head http-head* }
"Advanced usage involves constructing a " { $link request } ", which allows " { $link "http.cookies" } " and " { $link "http.headers" } " to be set:"
{ $subsections
    <head-request>
} ;

ARTICLE: "http.client.delete" "DELETE requests with the HTTP client"
"Basic usage involves passing a " { $link url } " and getting a " { $link response } " and data back:"
{ $subsections http-delete http-delete* }
"Advanced usage involves constructing a " { $link request } ", which allows " { $link "http.cookies" } " and " { $link "http.headers" } " to be set:"
{ $subsections
    <delete-request>
} ;

ARTICLE: "http.client.options" "OPTIONS requests with the HTTP client"
"Basic usage involves passing a " { $link url } " and getting a " { $link response } " and data back:"
{ $subsections http-options http-options* }
"Advanced usage involves constructing a " { $link request } ", which allows " { $link "http.cookies" } " and " { $link "http.headers" } " to be set:"
{ $subsections
    <options-request>
}
"RFC2616 does not define any use for an entity body, yet allows for the inclusion of one as part of the OPTIONS method. This is not supported with this version of the " { $vocab-link "http.client" } ". The current implementation of " { $link http-options } " only supports a " { $link url } " request with no corresponding post-data, as per the stack effect." ;

ARTICLE: "http.client.trace" "TRACE requests with the HTTP client"
"Basic usage involves passing a " { $link url } " and getting a " { $link response } " and data back:"
{ $subsections http-trace http-trace* }
"Advanced usage involves constructing a " { $link request } ", which allows " { $link "http.cookies" } " and " { $link "http.headers" } " to be set:"
{ $subsections
    <trace-request>
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
{ $subsections
    download-failed
    too-many-redirects
} ;

ARTICLE: "http.client" "HTTP client"
"The " { $vocab-link "http.client" } " vocabulary implements an HTTP and HTTPS client on top of " { $link "http" } "."
$nl
"For HTTPS support, you must load the " { $vocab-link "io.sockets.secure" } " vocab first. If you don't need HTTPS support, don't load " { $vocab-link "io.sockets.secure" } "; this will reduce the size of images generated by " { $vocab-link "tools.deploy" } "."
$nl
"There are two primary usage patterns, data retrieval with GET requests and form submission with POST requests:"
{ $subsections
    "http.client.get"
    "http.client.post"
    "http.client.put"
}
"Submission data for POST and PUT requests:"
{ $subsections "http.client.post-data" }
"Other HTTP methods are also supported:"
{ $subsections
    "http.client.head"
    "http.client.delete"
    "http.client.options"
    "http.client.trace"
}
"More esoteric use-cases, for example HTTP methods other than the above, are accommodated by constructing an empty request object with " { $link <request> } " and filling everything in by hand."
{ $subsections
    "http.client.encoding"
    "http.client.errors"
}
"For authentication, only Basic Access Authentication is implemented, using the username/password from the target or proxy url. Alternatively, the " { $link set-basic-auth } " or " { $link set-proxy-basic-auth } " words can be called on the " { $link request } " object."
$nl
"The http client can use an HTTP proxy transparently, by using the " { $link "http.proxy-variables" } ". Additionally, the proxy variables can be ignored by setting the " { $slot "proxy-url" } " slot of each " { $link request } " manually:"
{ $list
    { "Setting " { $slot "proxy-url" } " to " { $link f } " prevents http.client from using a proxy." }
    { "Setting the slots of the default empty url in " { $slot "proxy-url" } " overrides the corresponding values from the proxy variables." }
}

{ $see-also "urls" } ;

ABOUT: "http.client"
