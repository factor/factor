USING: help.markup help.syntax ;
IN: interval-maps

HELP: interval-at*
{ $values { "key" "an object" } { "map" "an interval map" } { "value" "the value for the key, or f" } { "?" "whether the key is present" } }
{ $description "Looks up a key in an interval map, returning the corresponding value if the item is in an interval in the map, and a boolean flag. The operation takes O(log n) time." } ;

HELP: interval-at
{ $values { "key" "an object" } { "map" "an interval map" } { "value" "the value for the key, or f" } }
{ $description "Looks up a key in an interval map, returning the value of the corresponding interval, or f if the interval is not present in the map." } ;

HELP: interval-key?
{ $values { "key" "an object" } { "map" "an interval map" } { "?" "a boolean" } }
{ $description "Tests whether an object is in an interval in the interval map, returning t if the object is present." } ;

HELP: <interval-map>
{ $values { "specification" "an assoc" } { "map" "an interval map" } }
{ $description "From a specification, produce an interval tree. The specification is an assoc where the keys are intervals, or pairs of numbers to represent intervals, or individual numbers to represent singleton intervals. The values are the values int he interval map. Construction time is O(n log n)." } ;

ARTICLE: "interval-maps" "Interval maps"
"The " { $vocab-link "interval-maps" } " vocabulary implements a data structure, similar to assocs, where a set of closed intervals of keys are associated with values. As such, interval maps do not conform to the assoc protocol, because intervals of floats, for example, can be used, and it is impossible to get a list of keys in between."
$nl
"The following operations are used to query interval maps:"
{ $subsection interval-at* }
{ $subsection interval-at }
{ $subsection interval-key? }
"Use the following to construct interval maps"
{ $subsection <interval-map> } ;

ABOUT: "interval-maps"
