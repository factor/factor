! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax io math ;
IN: io.streams.limited

HELP: <limited-stream>
{ $values
    { "stream" "an input stream" } { "limit" integer }
    { "stream'" "an input stream" }
}
{ $description "Constructs a new " { $link limited-stream } " from an existing stream. User code should use " { $link limit-stream } " or " { $link limited-input } "." } ;

HELP: limit-stream
{ $values
    { "stream" "an input stream" } { "limit" integer }
    { "stream'" "a stream" }
}
{ $description "Changes a decoder's stream to be a limited stream, or wraps " { $snippet "stream" } " in a " { $link limited-stream } "." }
{ $examples
    "Limiting a longer stream to length three:"
    { $example
        "USING: accessors continuations io io.streams.limited"
        "io.streams.string kernel prettyprint ;"
        "\"123456\" <string-reader> 3 limit-stream"
        "100 swap stream-read ."
        "\"123\""
    }
} ;

HELP: limited-stream
{ $values
    { "value" "a limited-stream class" }
}
{ $description "Limited streams wrap other streams, changing their behavior to throw an exception or return " { $link f } " upon exhaustion." } ;

HELP: limited-input
{ $values { "limit" integer } }
{ $description "Wraps the current " { $link input-stream } " in a " { $link limited-stream } "." } ;

ARTICLE: "io.streams.limited" "Limited input streams"
"The " { $vocab-link "io.streams.limited" } " vocabulary wraps a stream to behave as if it had only a limited number of bytes. Limiting a seekable stream creates a window of bytes that supports seeking and re-reading of bytes in that window. If it is desirable for a stream to throw an exception upon exhaustion, use the " { $vocab-link "io.streams.throwing" } " vocabulary in conjunction with this one." $nl
"Wrap a stream in a limited stream:"
{ $subsections limited-stream }
"Wrap the current " { $link input-stream } " in a limited stream:"
{ $subsections limited-input } ;

ABOUT: "io.streams.limited"
