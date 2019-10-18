! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math io ;
IN: io.streams.limited

HELP: <limited-stream>
{ $values
     { "stream" "an input stream" } { "limit" integer } { "mode" { $link stream-throws } " or " { $link stream-eofs } }
     { "stream'" "an input stream" }
}
{ $description "Constructs a new " { $link limited-stream } " from an existing stream. User code should use " { $link limit } " or " { $link limit-input } "." } ;

HELP: limit
{ $values
     { "stream" "an input stream" } { "limit" integer } { "mode" { $link stream-throws } " or " { $link stream-eofs } }
     { "stream'" "a stream" }
}
{ $description "Changes a decoder's stream to be a limited stream, or wraps " { $snippet "stream" } " in a " { $link limited-stream } "." }
{ $examples "Throwing an exception:"
    { $example
        "USING: continuations io io.streams.limited io.streams.string"
        "kernel prettyprint ;"
        "["
        "    \"123456\" <string-reader> 3 stream-throws limit"
        "    100 swap stream-read ."
        "] [ ] recover ."
"""T{ limit-exceeded
    { n 1 }
    { stream
        T{ limited-stream
            { stream
                T{ string-reader
                    { underlying "123456" }
                    { i 3 }
                }
            }
            { mode stream-throws }
            { count 4 }
            { limit 3 }
        }
    }
}"""
    }
    "Returning " { $link f } " on exhaustion:"
    { $example
        "USING: accessors continuations io io.streams.limited"
        "io.streams.string kernel prettyprint ;"
        "\"123456\" <string-reader> 3 stream-eofs limit"
        "100 swap stream-read ."
        "\"123\""
    }
} ;

HELP: unlimited
{ $values
     { "stream" "an input stream" }
     { "stream'" "a stream" }
}
{ $description "Returns the underlying stream of a limited stream." } ;

HELP: limited-stream
{ $values
    { "value" "a limited-stream class" }
}
{ $description "Limited streams wrap other streams, changing their behavior to throw an exception or return " { $link f } " upon exhaustion." } ;

HELP: limit-input
{ $values
     { "limit" integer } { "mode" { $link stream-throws } " or " { $link stream-eofs } }
}
{ $description "Wraps the current " { $link input-stream } " in a " { $link limited-stream } "." } ;

HELP: unlimited-input
{ $description "Returns the underlying stream of the limited-stream stored in " { $link input-stream } "." } ;

HELP: stream-eofs
{ $values
    { "value" { $link stream-throws } " or " { $link stream-eofs } }
}
{ $description "If the " { $slot "mode" } " of a limited stream is set to this singleton, the stream will return " { $link f } " upon exhaustion." } ;

HELP: stream-throws
{ $values
    { "value" { $link stream-throws } " or " { $link stream-eofs } }
}
{ $description "If the " { $slot "mode" } " of a limited stream is set to this singleton, the stream will throw " { $link limit-exceeded } " upon exhaustion." } ;

{ stream-eofs stream-throws } related-words

ARTICLE: "io.streams.limited" "Limited input streams"
"The " { $vocab-link "io.streams.limited" } " vocabulary wraps a stream to behave as if it had only a limited number of bytes, either throwing an error or returning " { $link f } " upon reaching the end. Limiting a non-seekable stream keeps a byte count and triggers the end-of-stream behavior when this byte count has been reached. However, limiting a seekable stream creates a window of bytes that supports seeking and re-reading of bytes in that window." $nl
"Wrap a stream in a limited stream:"
{ $subsections limit }
"Wrap the current " { $link input-stream } " in a limited stream:"
{ $subsections limit-input }
"Unlimits a limited stream:"
{ $subsections unlimited }
"Unlimits the current " { $link input-stream } ":"
{ $subsections unlimited-input }
"Make a limited stream throw an exception on exhaustion:"
{ $subsections stream-throws }
"Make a limited stream return " { $link f } " on exhaustion:"
{ $subsections stream-eofs } ;

ABOUT: "io.streams.limited"
