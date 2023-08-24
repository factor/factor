! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax io math quotations words ;
IN: io.streams.throwing

HELP: stream-exhausted
{ $values
    { "n" integer } { "stream" "an input stream" } { "word" word }
}
{ $description "The exception that gets thrown when a stream is exhausted." } ;

HELP: stream-throw-on-eof
{ $values
    { "stream" "an input stream" } { "quot" quotation }
}
{ $description "Wraps a stream in a " { $link <throws-on-eof-stream> } " tuple and calls the quotation with this stream as the " { $link input-stream } " variable. Causes a " { $link stream-exhausted } " exception to be thrown upon stream exhaustion. The stream is left open after this combinator returns." }
"This example will throw a " { $link stream-exhausted } " exception:"
{ $unchecked-example "USING: io.streams.throwing prettyprint ;
\"abc\" <string-reader> [ 4 read ] stream-throw-on-eof"
""
} ;

HELP: throw-on-eof
{ $values
    { "quot" quotation }
}
{ $description "Wraps the value stored in the " { $link input-stream } " variable and causes a stream read that exhausts the input stream to throw a " { $link stream-exhausted } " exception. The stream is left open after this combinator returns." } $nl
"This example will throw a " { $link stream-exhausted } " exception:"
{ $unchecked-example "USING: io.streams.throwing prettyprint ;
\"abc\" [ [ 4 read ] throw-on-eof ] with-string-reader"
""
} ;

ARTICLE: "io.streams.throwing" "Throwing exceptions on stream exhaustion"
"The " { $vocab-link "io.streams.throwing" } " vocabulary implements combinators for changing the behavior of a stream to throw an exception upon exhaustion instead of returning " { $link f } "." $nl
"A general combinator to wrap any stream:"
{ $subsections stream-throw-on-eof }
"A combinator for the " { $link input-stream } " variable:"
{ $subsections throw-on-eof }
"The exception itself:"
{ $subsections stream-exhausted } ;

ABOUT: "io.streams.throwing"
