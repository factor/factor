! Copyright (C) 2012 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math sequences ;
IN: sequences.windowed

HELP: <windowed-sequence>
{ $values
    { "sequence" sequence } { "n" integer }
    { "windowed-sequence" windowed-sequence }
}
{ $description "Create a new windowed sequence of window size " { $snippet "n" } " over " { $snippet "sequence" } "." } ;

HELP: in-bound
{ $values
    { "n" integer } { "sequence" sequence }
    { "n'" integer }
}
{ $description "Clamps an integer from 0 to the sequence length." } ;

HELP: in-bounds
{ $values
    { "a" integer } { "b" integer } { "sequence" sequence }
    { "a'" integer } { "b'" integer }
}
{ $description "Clamps two integers from 0 to the sequence length. While not in bounds for calling " { $link nth } ", these integers are in bounds for calling " { $link <slice> } "." } ;

ARTICLE: "sequences.windowed" "Windowed sequences"

"The " { $vocab-link "sequences.windowed" } " vocabulary provides a read-only virtual sequence whose elements are slices of length " { $snippet "n" } " from the current element looking backwards, inclusive of the current element. Slices may be less than " { $snippet "n" } " elements in length, especially at the head of the sequence, where the first slice will be of length 1." $nl
"Windowed sequences support " { $link nth } " and " { $link length } " from the " { $link "sequence-protocol" } "." $nl
"Creating a windowed sequence:"
{ $subsections <windowed-sequence> }
"Helper words for creating bounds-checked slices:"
{ $subsections in-bound in-bounds } ;

ABOUT: "sequences.windowed"
