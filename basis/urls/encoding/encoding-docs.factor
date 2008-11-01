IN: urls.encoding
USING: strings help.markup help.syntax assocs multiline ;

HELP: url-decode
{ $values { "str" string } { "decoded" string } }
{ $description "Decodes a URL-encoded string." } ;

HELP: url-encode
{ $values { "str" string } { "encoded" string } }
{ $description "URL-encodes a string, excluding certain characters, such as \"/\"." } ;

HELP: url-encode-full
{ $values { "str" string } { "encoded" string } }
{ $description "URL-encodes a string, including all reserved characters, such as \"/\"." } ;

HELP: url-quotable?
{ $values { "ch" "a character" } { "?" "a boolean" } }
{ $description "Tests if a character be used without URL-encoding in a URL." } ;

HELP: assoc>query
{ $values { "assoc" assoc } { "str" string } }
{ $description "Converts an assoc of query parameters into a query string, performing URL encoding." }
{ $notes "This word is used by the implementation of " { $link "urls" } ". It is also used by the HTTP client to encode POST requests." }
{ $examples
    { $example
        "USING: io urls.encoding ;"
        "{ { \"from\" \"Lead\" } { \"to\" \"Gold, please\" } }"
        "assoc>query print"
        "from=Lead&to=Gold%2c%20please"
    }
} ;

HELP: query>assoc
{ $values { "query" string } { "assoc" assoc } }
{ $description "Parses a URL query string and URL-decodes each component." }
{ $notes "This word is used by the implementation of " { $link "urls" } ". It is also used by the HTTP server to parse POST requests." }
{ $examples
    { $unchecked-example
        "USING: prettyprint urls.encoding ;"
        "\"gender=female&agefrom=22&ageto=28&location=Omaha+NE\""
        "query>assoc ."
        <" H{
    { "gender" "female" }
    { "agefrom" "22" }
    { "ageto" "28" }
    { "location" "Omaha NE" }
}">
    }
} ;

ARTICLE: "url-encoding" "URL encoding and decoding"
"URL encoding and decoding strings:"
{ $subsection url-encode }
{ $subsection url-decode }
{ $subsection url-quotable? }
"Encoding and decoding queries:"
{ $subsection assoc>query }
{ $subsection query>assoc }
"See " { $url "http://en.wikipedia.org/wiki/Percent-encoding" } " for a description of URL encoding." ;

ABOUT: "url-encoding"
