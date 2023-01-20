! Copyright (C) 2008, 2009 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs help.markup help.syntax kernel sequences ;
IN: interval-maps

HELP: interval-at*
{ $values { "key" object } { "map" interval-map } { "value" "the value for the key, or f" } { "?" "whether the key is present" } }
{ $description "Looks up a key in an interval map, returning the corresponding value if the item is in an interval in the map, and a boolean flag. The operation takes O(log n) time." } ;

HELP: interval-at
{ $values { "key" object } { "map" interval-map } { "value" "the value for the key, or f" } }
{ $description "Looks up a key in an interval map, returning the value of the corresponding interval, or f if the interval is not present in the map." } ;

HELP: interval-key?
{ $values { "key" object } { "map" interval-map } { "?" boolean } }
{ $description "Tests whether an object is in an interval in the interval map, returning t if the object is present." } ;

HELP: <interval-map>
{ $values { "specification" assoc } { "map" interval-map } }
{ $description "From a specification, produce an interval tree. The specification is an assoc where the keys are intervals, or pairs of numbers to represent intervals, or individual numbers to represent singleton intervals. The values are the values int he interval map. Construction time is O(n log n)." } ;

HELP: interval-values
{ $values { "map" interval-map } { "values" sequence } }
{ $description "Constructs a list of all of the values that interval map keys are associated with. This list may contain duplicates." } ;

HELP: coalesce
{ $values { "alist" "an association list with integer keys" } { "specification" { "array of the format used by " { $link <interval-map> } } } }
{ $description "Finds ranges used in the given alist, coalescing them into a single range." } ;

ARTICLE: "interval-maps" "Interval maps"
"The " { $vocab-link "interval-maps" } " vocabulary implements a data structure, similar to assocs, where a set of closed intervals of keys are associated with values. As such, interval maps do not conform to the assoc protocol, because intervals of floats, for example, can be used, and it is impossible to get a list of keys in between."
$nl
"The following operations are used to query interval maps:"
{ $subsections
    interval-at*
    interval-at
    interval-key?
    interval-values
}
"Use the following to construct interval maps"
{ $subsections
    <interval-map>
    coalesce
} ;

ABOUT: "interval-maps"
