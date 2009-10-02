! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel quotations classes sequences ;
IN: splitting.monotonic

HELP: monotonic-slice
{ $values
     { "seq" sequence } { "quot" quotation } { "class" class }
     { "slices" "a sequence of slices" }
}
{ $description "Monotonically splits a sequence into slices of the type " { $snippet "class" } "." }
{ $examples
    { $example
        "USING: splitting.monotonic math prettyprint ;"
        "{ 1 2 3 2 3 4 } [ < ] upward-slice monotonic-slice ."
        """{
    T{ upward-slice
        { from 0 }
        { to 3 }
        { seq { 1 2 3 2 3 4 } }
    }
    T{ upward-slice
        { from 3 }
        { to 6 }
        { seq { 1 2 3 2 3 4 } }
    }
}"""
    }
} ;

HELP: monotonic-split
{ $values
     { "seq" sequence } { "quot" quotation }
     { "newseq" "a sequence of sequences" }
}
{ $description "Compares pairs of elements in a sequence and collects elements into sequences while they satisfy the predicate. Once the predicate fails, a new sequence is started, and all sequences are returned in a single sequence." }
{ $examples
    { $example
        "USING: splitting.monotonic math prettyprint ;"
        "{ 1 2 3 2 3 4 } [ < ] monotonic-split ."
        "{ V{ 1 2 3 } V{ 2 3 4 } }"
    }
} ;

HELP: downward-slices
{ $values
     { "seq" sequence }
     { "slices" "a sequence of downward-slices" }
}
{ $description "Returns an array of monotonically decreasing slices of type " { $link downward-slice } ". Slices of one element are discarded." } ;

HELP: stable-slices
{ $values
    { "seq" sequence }
    { "slices" "a sequence of stable-slices" }
}
{ $description "Returns an array of monotonically decreasing slices of type " { $link downward-slice } ". Slices of one element are discarded." } ;

HELP: upward-slices
{ $values
    { "seq" sequence }
    { "slices" "a sequence of upward-slices" }
}
{ $description "Returns an array of monotonically increasing slices of type " { $link downward-slice } ". Slices of one element are discarded." } ;

HELP: trends
{ $values
    { "seq" sequence }
    { "slices" "a sequence of downward, stable, and upward slices" }
}
{ $description "Returns a sorted sequence of downward, stable, or upward slices. The endpoints of some slices may overlap with each other." }
{ $examples
    { $example
        "USING: splitting.monotonic math prettyprint ;"
        "{ 1 2 3 3 2 1 } trends ."
        """{
    T{ upward-slice
        { from 0 }
        { to 3 }
        { seq { 1 2 3 3 2 1 } }
    }
    T{ stable-slice
        { from 2 }
        { to 4 }
        { seq { 1 2 3 3 2 1 } }
    }
    T{ downward-slice
        { from 3 }
        { to 6 }
        { seq { 1 2 3 3 2 1 } }
    }
}"""
    }
} ;

ARTICLE: "splitting.monotonic" "Splitting trending sequences"
"The " { $vocab-link "splitting.monotonic" } " vocabulary splits sequences that are trending downwards, upwards, or stably." $nl
"Splitting into sequences:"
{ $subsections monotonic-split }
"Splitting into slices:"
{ $subsections monotonic-slice }
"Trending:"
{ $subsections
    downward-slices
    stable-slices
    upward-slices
    trends
} ;

ABOUT: "splitting.monotonic"
