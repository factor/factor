! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math io ;
IN: io.streams.limited

HELP: <limited-stream>
{ $values
     { "stream" "an input stream" } { "limit" integer }
     { "stream'" "an input stream" }
}
{ $description "Constructs a new " { $link limited-stream } " from an existing stream. Upon exhaustion, the stream will throw an error by default." }
{ $examples "Throwing an exception:"
    { $example
        "USING: continuations io io.streams.limited io.streams.string"
        "kernel prettyprint ;"
        "["
        "    \"123456\" <string-reader> 3 <limited-stream>"
        "    100 swap stream-read ."
        "] [ ] recover ."
        "T{ limit-exceeded }"
    }
    "Returning " { $link f } " on exhaustion:"
    { $example
        "USING: accessors continuations io io.streams.limited"
        "io.streams.string kernel prettyprint ;"
        "\"123456\" <string-reader> 3 <limited-stream>"
        "stream-eofs >>mode"
        "100 swap stream-read ."
        "\"123\""
    }
} ;

HELP: limit
{ $values
     { "stream" "a stream" } { "limit" integer }
     { "stream'" "a stream" }
}
{ $description "Changes a decoder's stream to be a limited stream, or wraps " { $snippet "stream" } " in a " { $link limited-stream } "." } ;

HELP: limited-stream
{ $values
    { "value" "a limited-stream class" }
}
{ $description "Limited streams wrap other streams, changing their behavior to throw an exception or return " { $link f } " upon exhaustion. The default behavior is to throw an exception." } ;

HELP: limit-input
{ $values
     { "limit" integer }
}
{ $description "Wraps the current " { $link input-stream } " in a " { $link limited-stream } "." } ;

HELP: stream-eofs
{ $values
    { "value" "a " { $link limited-stream } " mode singleton" }
}
{ $description "If the " { $slot "mode" } " of a limited stream is set to this singleton, the stream will return " { $link f } " upon exhaustion." } ;

HELP: stream-throws
{ $values
    { "value" "a " { $link limited-stream } " mode singleton" }
}
{ $description "If the " { $slot "mode" } " of a limited stream is set to this singleton, the stream will throw " { $link limit-exceeded } " upon exhaustion." } ;

{ stream-eofs stream-throws } related-words

ARTICLE: "io.streams.limited" "Limited input streams"
"The " { $vocab-link "io.streams.limited" } " vocabulary wraps a stream to behave as if it had only a limited number of bytes, either throwing an error or returning " { $link f } " upon reaching the end. The default behavior is to throw an error." $nl
"Wrap an existing stream in a limited stream:"
{ $subsection <limited-stream> }
"Wrap a stream in a limited stream:"
{ $subsection limit }
"Wrap the current " { $link input-stream } " in a limited stream:"
{ $subsection limit-input }
"Make a limited stream throw an exception on exhaustion:"
{ $subsection stream-throws }
"Make a limited stream return " { $link f } " on exhaustion:"
{ $subsection stream-eofs } ;

ABOUT: "io.streams.limited"
