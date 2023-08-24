USING: calendar help.markup help.syntax kernel math present
strings urls ;
IN: http

HELP: <request>
{ $values { "request" request } }
{ $description "Creates an empty request containing default headers." } ;

HELP: request
{ $description "An HTTP request."
$nl
"Instances contain the following slots:"
{ $slots
    { "method" { "The HTTP method as a " { $link string } ". The most frequently-used HTTP methods are " { $snippet "GET" } ", " { $snippet "HEAD" } " and " { $snippet "POST" } "." } }
    { "url" { "The " { $link url } " being requested" } }
    { "proxy-url" { "The proxy " { $link url } " to use, or " { $link f } " for no proxy. If not " { $link f } ", the url will additionally be " { $link derive-url } "'d from the " { $link "http.proxy-variables" } ". The proxy is used if the result has at least the " { $slot "host" } " slot set." } }
    { "version" { "The HTTP version. Default is " { $snippet "1.1" } " and should not be changed without good reason." } }
    { "header" { "An assoc of HTTP header values. See " { $link "http.headers" } } }
    { "post-data" { "See " { $link "http.post-data" } } }
    { "cookies" { "A sequence of HTTP cookies. See " { $link "http.cookies" } } }
    { "redirects" { "Number of redirects to attempt before throwing an error. Default is " { $snippet "max-redirects" } "." } }
} } ;

HELP: <response>
{ $values { "response" response } }
{ $description "Creates an empty response containing default headers." } ;

HELP: response
{ $class-description "An HTTP response."
$nl
"Instances contain the following slots:"
{ $slots
    { "version" { "The HTTP version. Default is " { $snippet "1.1" } " and should not be changed without good reason." } }
    { "code" { "HTTP status code, an " { $link integer } ". Examples are 200 for success, 404 for file not found, and so on." } }
    { "message" { "HTTP status message, only displayed to the user. If the status code is 200, the status message might be “Success”, for example." } }
    { "header" { "An assoc of HTTP header values. See " { $link "http.headers" } } }
    { "cookies" { "A sequence of HTTP cookies. See " { $link "http.cookies" } } }
    { "content-type" { "an HTTP content type" } }
    { "content-charset" { "an encoding name" } }
    { "content-encoding" { "an encoding descriptor. See " { $link "io.encodings" } } }
    { "body" { "an HTTP response body" } }
} } ;

HELP: <raw-response>
{ $values { "response" raw-response } }
{ $description "Creates an empty raw response." } ;

HELP: raw-response
{ $class-description "A minimal HTTP response used by webapps which need full control over all output sent to the client. Most webapps can use " { $link response } " instead."
$nl
"Instances contain the following slots:"
{ $slots
    { "version" { "The HTTP version. Default is " { $snippet "1.1" } " and should not be changed without good reason." } }
    { "code" { "HTTP status code, an " { $link integer } ". Examples are 200 for success, 404 for file not found, and so on." } }
    { "message" { "HTTP status message, only displayed to the user. If the status code is 200, the status message might be “Success”, for example." } }
    { "body" { "an HTTP response body" } }
} } ;

HELP: <cookie>
{ $values { "value" object } { "name" string } { "cookie" cookie } }
{ $description "Creates a cookie with the specified name and value. The value can be any object supported by the " { $link present } " word." } ;

HELP: cookie
{ $class-description
"An HTTP cookie."
$nl
"Instances contain a number of slots which correspond exactly to the fields of a cookie in the cookie specification:"
{ $slots
    { "name" { "The cookie name, a " { $link string } } }
    { "value" { "The cookie value, an object supported by " { $link present } } }
    { "comment" { "A " { $link string } } }
    { "path" { "The pathname prefix where the cookie is valid, a " { $link string } } }
    { "domain" { "The domain name where the cookie is valid, a " { $link string } } }
    { "expires" { "The expiry time, a " { $link timestamp } " or " { $link f } " for a session cookie" } }
    { "max-age" { "The expiry duration, a " { $link duration } " or " { $link f } " for a session cookie" } }
    { "http-only" { "If set to a true value, JavaScript code cannot see the cookie" } }
    { "secure" { "If set to a true value, the cookie is only sent for " { $snippet "https" } " protocol connections" } }
}
"Only one of " { $snippet "expires" } " and " { $snippet "max-age" } " can be set; the latter is preferred and is supported by all modern browsers." } ;

HELP: delete-cookie
{ $values { "request/response" "a " { $link request } " or a " { $link response } } { "name" string } }
{ $description "Deletes a cookie from a request or response." }
{ $side-effects "request/response" } ;

HELP: get-cookie
{ $values { "request/response" "a " { $link request } " or a " { $link response } } { "name" string } { "cookie/f" { $maybe cookie } } }
{ $description "Gets a named cookie from a request or response." } ;

HELP: put-cookie
{ $values { "request/response" "a " { $link request } " or a " { $link response } } { "cookie" cookie } }
{ $description "Stores a cookie in a request or response." }
{ $side-effects "request/response" } ;

HELP: <post-data>
{ $values { "content-type" "a MIME type string" } { "post-data" post-data } }
{ $description "Creates a new " { $link post-data } "." } ;

HELP: header
{ $values { "request/response" "a " { $link request } " or a " { $link response } } { "key" string } { "value" string } }
{ $description "Obtains an HTTP header value from a request or response." } ;

HELP: post-data
{ $class-description "HTTP POST data passed in a POST request."
$nl
"Instances contain the following slots:"
{ $slots
    { "data" { "The POST data. This can be in a higher-level form, such as an assoc of POST parameters, a string, or an XML document" } }
    { "params" { "Parameters passed in the POST request." } }
    { "content-type" { "A MIME type" } }
    { "content-encoding" { "Encoding used for the POST data" } }
} } ;

HELP: set-header
{ $values { "request/response" "a " { $link request } " or a " { $link response } } { "value" object } { "key" string } }
{ $description "Stores a value into the HTTP header of a request or response. The value can be any object supported by " { $link present } "." }
{ $notes "This word always returns the same object that was input. This allows for a “pipeline” coding style, where several header parameters are set in a row." }
{ $side-effects "request/response" } ;

HELP: set-basic-auth
{ $values { "request" request } { "username" string } { "password" string } }
{ $description "Sets the " { $snippet "Authorization" } " header of " { $snippet "request" } " to perform HTTP Basic authentication with the given " { $snippet "username" } " and " { $snippet "password" } "." }
{ $notes "This word always returns the same object that was input. This allows for a “pipeline” coding style, where several header parameters are set in a row." }
{ $side-effects "request" } ;

HELP: set-proxy-basic-auth
{ $values { "request" request } { "username" string } { "password" string } }
{ $description "Sets the " { $snippet "Proxy-Authorization" } " header of " { $snippet "request" } " to perform HTTP Basic authentication with the given " { $snippet "username" } " and " { $snippet "password" } "." }
{ $notes "This word always returns the same object that was input. This allows for a “pipeline” coding style, where several header parameters are set in a row." }
{ $side-effects "request" } ;

ARTICLE: "http.cookies" "HTTP cookies"
"Every " { $link request } " and " { $link response } " instance can contain cookies."
$nl
"The " { $vocab-link "furnace.sessions" } " vocabulary implements session management using cookies, thus the most common use case can be taken care of without working with cookies directly."
$nl
"The class of cookies:"
{ $subsections cookie }
"Creating cookies:"
{ $subsections <cookie> }
"Getting, adding, and deleting cookies in " { $link request } " and " { $link response } " objects:"
{ $subsections
    get-cookie
    put-cookie
    delete-cookie
} ;

ARTICLE: "http.headers" "HTTP headers"
"Every " { $link request } " and " { $link response } " has a set of HTTP headers stored in the " { $slot "header" } " slot. Header names are normalized to lower-case when a request or response is being parsed."
{ $subsections
    header
    set-header
} ;

ARTICLE: "http.post-data" "HTTP post data"
"Every " { $link request } " where the " { $slot "method" } " slot is " { $snippet "POST" } " can contain post data."
{ $subsections
    post-data
    <post-data>
} ;

ARTICLE: "http.requests" "HTTP requests"
"HTTP requests:"
{ $subsections
    request
    <request>
}
"Requests can contain form submissions:"
{ $subsections "http.post-data" } ;

ARTICLE: "http.responses" "HTTP responses"
"HTTP responses:"
{ $subsections
    response
    <response>
}
"Raw responses only contain a status line, with no header. They are used by webapps which need full control over the HTTP response, for example " { $vocab-link "http.server.cgi" } ":"
{ $subsections
    raw-response
    <raw-response>
} ;

ARTICLE: "http" "HTTP protocol objects"
"The " { $vocab-link "http" } " vocabulary contains data types shared by " { $vocab-link "http.client" } " and " { $vocab-link "http.server" } "."
$nl
"The HTTP client sends an HTTP request to the server and receives an HTTP response back. The HTTP server receives HTTP requests from clients and sends HTTP responses back."
{ $subsections
    "http.requests"
    "http.responses"
}
"Both requests and responses support some common functionality:"
{ $subsections
    "http.headers"
    "http.cookies"
}
{ $see-also "urls" } ;

ARTICLE: "http.proxy-variables" "HTTP(S) proxy variables"
{ $heading "Proxy Variables" }
"The http and https proxies can be configured per request, or with Factor's dynamic variables, or with the system's environment variables (searched from left to right) :"
{ $table
{ "variable" "Factor dynamic" "environment #1" "environment #2" }
{ "HTTP" { $snippet "\"http.proxy\"" } "http_proxy" "HTTP_PROXY" }
{ "HTTPS" { $snippet "\"https.proxy\"" } "https_proxy" "HTTPS_PROXY" }
{ "no proxy" { $snippet "\"no_proxy\"" } "no_proxy" "NO_PROXY" }
}
"When making an http request, if the target host is not matched by the no_proxy list, the " { $vocab-link "http.client" } " will fill the missing components of the " { $slot "proxy-url" } " slot of the " { $link request } " from the value of these variables. If the filled result is not valid, an error is thrown."
{ $notes "The dynamic variables are keyed by strings. This allows to use Factor's command line support to define them (see in the examples below)." }

{ $heading "no_proxy" }
"The no_proxy list must be a string containing of comma-separated list of IP addresses (eg " { $snippet "127.0.0.1" } "), hostnames (eg " { $snippet "bar.private" } ") or domain suffixes (eg " { $snippet ".private" } "). A match happens when a value of the list is the same or a suffix of the target for each full subdomain."
{ $example
    "USING: http.client http.client.private namespaces prettyprint ;"
    "\"bar.private\" \"no_proxy\" ["
         "\"bar.private\" <get-request> no-proxy? ."
    "] with-variable"
    "\"bar.private\" \"no_proxy\" ["
         "\"baz.bar.private\" <get-request> no-proxy? ."
    "] with-variable"
    "\"bar.private\" \"no_proxy\" ["
         "\"foobar.private\" <get-request> no-proxy? ."
    "] with-variable"
    "\".private\" \"no_proxy\" ["
         "\"foobar.private\" <get-request> no-proxy? ."
    "] with-variable"
"t
t
f
t"
}

{ $examples
{
{ $subheading "At factor startup:" }
{ $list
"$ ./factor -http.proxy=http://localhost:3128"
"$ http_proxy=\"http://localhost:3128\" ./factor"
"$ HTTP_PROXY=\"http://localhost:3128\" ./factor"
}

{ $subheading "Using variables:" }
{ $example "USE: namespaces \"http://localhost:3128\" \"http.proxy\" set ! or set-global" "" }
{ $example "USE: namespaces \"http://localhost:3128\" \"http.proxy\" [ ] with-variable" "" }

{ $subheading "Manually making the request:" }
{ $example "USING: http http.client urls ; URL\" http://localhost:3128\" <request> proxy-url<<" "" }

{ $subheading "Full example:" }
"$ no_proxy=\"localhost,127.0.0.1,.private\" http_proxy=\"http://proxy.private:3128\" https_proxy=\"http://proxysec.private:3128\" ./factor"
}
}
;

ABOUT: "http"
