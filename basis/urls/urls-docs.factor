USING: assocs hashtables help.markup help.syntax
io.streams.string io.files io.pathnames kernel strings present
math ;
IN: urls

HELP: url
{ $class-description "The class of URLs. The slots correspond to the standard components of a URL." } ;

HELP: <url>
{ $values { "url" url } }
{ $description "Creates an empty URL." } ;

HELP: >url
{ $values { "obj" object } { "url" url } }
{ $description "Converts an object into a URL. If the object is already a URL, does nothing; if it is a string, then it is parsed as a URL." }
{ $errors "Throws an error if the object is of the wrong type, or if it is a string which is not a valid URL." }
{ $examples
    "If we convert a string to a URL and print it out again, it will print similarly to the input string, except some normalization may have occurred:"
    { $example
        "USING: accessors prettyprint urls ;"
        "\"http://www.apple.com\" >url ."
        "URL\" http://www.apple.com/\""
    }
    "We can examine the URL object:"
    { $example
        "USING: accessors io urls ;"
        "\"http://www.apple.com\" >url host>> print"
        "www.apple.com"
    }
    "A relative URL does not have a protocol, host or port:"
    { $example
        "USING: accessors prettyprint urls ;"
        "\"file.txt\" >url protocol>> ."
        "f"
    }
} ;

HELP: URL"
{ $syntax "URL\" url...\"" }
{ $description "URL literal syntax." }
{ $examples
    { $example
        "USING: accessors prettyprint urls ;"
        "URL\" http://factorcode.org:80\" port>> ."
        "80"
    }
} ;

HELP: derive-url
{ $values { "base" url } { "url" url } { "url'" url } }
{ $description "Builds a URL by filling in missing components of " { $snippet "url" } " from " { $snippet "base" } "." }
{ $examples
    { $example
        "USING: prettyprint urls ;"
        "URL\" http://factorcode.org\""
        "URL\" binaries.fhtml\" derive-url ."
        "URL\" http://factorcode.org/binaries.fhtml\""
    }
    { $example
        "USING: prettyprint urls ;"
        "URL\" http://www.truecasey.com/drinks/kombucha\""
        "URL\" master-cleanser\" derive-url ."
        "URL\" http://www.truecasey.com/drinks/master-cleanser\""
    }
} ;

HELP: ensure-port
{ $values { "url" url } { "url'" url } }
{ $description "If the URL does not specify a port number, create a new URL which is equal except the port number is set to the default for the URL's protocol. If the protocol is unknown, outputs an exact copy of the input URL." }
{ $examples
    { $example
        "USING: accessors prettyprint urls ;"
        "URL\" https://concatenative.org\" ensure-port port>> ."
        "443"
    }
} ;

HELP: parse-host
{ $values { "string" string } { "host/f" { $maybe string } } { "port/f" { $maybe integer } } }
{ $description "Splits a string of the form " { $snippet "host:port" } " into a host and a port number. If the port number is not specified, outputs " { $link f } "." }
{ $notes "This word is used by " { $link >url } ". It can also be used directly to parse " { $snippet "host:port" } " strings which are not full URLs." }
{ $examples
    { $example
        "USING: arrays kernel prettyprint urls ;"
        "\"sbcl.org:80\" parse-host 2array ."
        "{ \"sbcl.org\" 80 }"
    }
} ;

HELP: query-param
{ $values
    { "url" url } { "key" string }
    { "value" { $maybe string } } }
{ $description "Outputs the URL-decoded value of a URL query parameter." }
{ $examples
    { $example
        "USING: io urls ;"
        "URL\" http://food.com/calories?item=French+Fries\""
        "\"item\" query-param print"
        "French Fries"
    }
} ;

HELP: set-query-param
{ $values { "url" url } { "value" object } { "key" string } }
{ $description "Sets a query parameter. The value can be any object supported by " { $link present } ", or " { $link f } ", in which case the key is removed." }
{ $notes "This word always returns the same URL object that was input. This allows for a \"pipeline\" coding style, where several query parameters are set in a row. Since it mutates the input object, you must " { $link clone } " it first if it is literal, as in the below example."
}
{ $examples
    { $code
        "USING: kernel http.client urls ;
URL\" http://search.yahooapis.com/WebSearchService/V1/webSearch\" clone
    \"concatenative programming (NSFW)\" \"query\" set-query-param
    \"1\" \"adult_ok\" set-query-param
http-get"
    }
    "(For a complete Yahoo! search web service implementation, see the " { $vocab-link "yahoo" } " vocabulary.)"
}
{ $side-effects "url" } ;

HELP: relative-url
{ $values { "url" url } { "url'" url } }
{ $description "Outputs a new URL with the same path and query components as the input value, but with the protocol, host and port set to " { $link f } "." }
{ $examples
    { $example
        "USING: prettyprint urls ;"
        "URL\" http://factorcode.org/binaries.fhtml\""
        "relative-url ."
        "URL\" /binaries.fhtml\""
    }
} ;

HELP: relative-url?
{ $values
    { "url" url }
    { "?" boolean } }
{ $description "Tests whether a URL is relative." } ;

HELP: redacted-url
{ $values { "url" url } { "url'" url } }
{ $description "Outputs a new URL with the password (if specified) replaced with " { $snippet "xxxxx" } ". This is useful for logging utilities where you want to avoid printing out the password in the logs." } ;

HELP: secure-protocol?
{ $values { "protocol" string } { "?" boolean } }
{ $description "Tests if protocol connections must be made with secure sockets (SSL/TLS)." }
{ $examples
    { $example
        "USING: prettyprint urls ;"
        "\"https\" secure-protocol? ."
        "t"
    }
} ;

HELP: url-addr
{ $values { "url" url } { "addr" "an address specifier" } }
{ $description "Outputs an address specifier for use with " { $link "network-connection" } "." }
{ $examples
    { $example
        "USING: prettyprint urls ;"
        "URL\" ftp://ftp.cdrom.com\" url-addr ."
        "T{ inet { host \"ftp.cdrom.com\" } { port 21 } }"
    }
    { $example
        "USING: io.sockets.secure prettyprint urls ;"
        "URL\" https://google.com/\" url-addr ."
        "T{ secure\n    { addrspec T{ inet { host \"google.com\" } { port 443 } } }\n    { hostname \"google.com\" }\n}"
    }
} ;

HELP: url-append-path
{ $values { "path1" string } { "path2" string } { "path" string } }
{ $description "Like " { $link append-path } ", but intended for use with URL paths and not filesystem paths." } ;

ARTICLE: "url-utilities" "URL implementation utilities"
{ $subsections
    parse-host
    secure-protocol?
    url-append-path
} ;

ARTICLE: "urls" "URL objects"
"The " { $vocab-link "urls" } " vocabulary implements a URL data type. The benefit of using a data type to prepresent URLs rather than a string is that the parsing, printing and escaping logic is encapsulated and reused, rather than re-implemented in a potentially buggy manner every time."
$nl
"URL objects are used heavily by the " { $vocab-link "http" } " and " { $vocab-link "furnace" } " vocabularies, and are also useful on their own."
$nl
"The class of URLs, and a constructor:"
{ $subsections
    url
    <url>
}
"Converting strings to URLs:"
{ $subsections >url }
"URLs can be converted back to strings using the " { $link present } " word."
$nl
"URL literal syntax:"
{ $subsections POSTPONE: URL" }
"Manipulating URLs:"
{ $subsections
    derive-url
    relative-url
    ensure-port
    query-param
    set-query-param
}
"Creating " { $link "network-addressing" } " from URLs:"
{ $subsections url-addr }
"The URL implementation encodes and decodes components of " { $link url } " instances automatically, but sometimes this functionality is needed for non-URL strings."
{ $subsections "url-encoding" }
"Utility words used by the URL implementation:"
{ $subsections "url-utilities" } ;

ABOUT: "urls"
