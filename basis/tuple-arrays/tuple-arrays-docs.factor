IN: tuple-arrays
USING: help.markup help.syntax sequences ;

HELP: TUPLE-ARRAY:
{ $syntax "TUPLE-ARRAY: class" }
{ $values { "class" "a final tuple class" } }
{ $description "Generates a new data type in the current vocabulary named " { $snippet { $emphasis "class" } "-array" } " for holding instances of " { $snippet "class" } ", which must be a tuple class word. Together with the class itself, this also generates words named " { $snippet "<" { $emphasis "class" } "-array>" } " and " { $snippet ">" { $emphasis "class" } "-array" } ", for creating new instances of this tuple array type." } ;

ARTICLE: "tuple-arrays" "Tuple arrays"
"The " { $vocab-link "tuple-arrays" } " vocabulary implements space-efficient unboxed tuple arrays. Whereas an ordinary array of tuples would consist of references to heap-allocated objects, a tuple array stores its elements as values."
$nl
"Calling " { $link nth } " copies an element into a new tuple, and calling " { $link set-nth } " copies an existing tuple's slots into an array."
$nl
"Since value semantics are incompatible with inheritance, the base type of a tuple array must be declared " { $link POSTPONE: final } ". A best practice that is not enforced is to have all slots in the tuple declared " { $link read-only } "."
$nl
"Tuple arrays do not get updated if tuples are redefined to add or remove slots, so caution should be exercised when doing interactive development on code that uses tuple arrays."
$nl
{ $subsections POSTPONE: TUPLE-ARRAY: }
"An example:"
{ $example
  "USE: tuple-arrays"
  "IN: scratchpad"
  "TUPLE: point x y ; final"
  "TUPLE-ARRAY: point"
  "{ T{ point f 1 2 } T{ point f 1 3 } T{ point f 2 3 } } >point-array first short."
  "T{ point f 1 2 }"
} ;

ABOUT: "tuple-arrays"
