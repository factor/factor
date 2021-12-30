USING: help.syntax help.markup arrays sequences ;
IN: ranges

ARTICLE: "ranges" "Numeric ranges"
"A " { $emphasis "range" } " is a virtual sequence with real number elements "
"ranging from " { $emphasis "a" } " to " { $emphasis "b" } " by " { $emphasis "step" } ". Ascending as well as descending ranges are supported."
$nl
"The class of ranges:"
{ $subsections range }
"Creating ranges with integer end-points. The standard mathematical convention is used, where " { $snippet "(" } " or " { $snippet ")" } " denotes that the end-point itself " { $emphasis "is not" } " part of the range; " { $snippet "[" } " or " { $snippet "]" } " denotes that the end-point " { $emphasis "is" } " part of the range:"
{ $subsections
    [a..b]
    (a..b]
    [a..b)
    (a..b)
    [0..b]
    [1..b]
    [0..b)
}
"Creating general ranges:"
{ $subsections <range> }
"Ranges are most frequently used with sequence combinators as a means of iterating over integers. For example,"
{ $code "3 10 [a..b] [ sqrt ] map" }
"Computing the factorial of 100 with a descending range:"
{ $code "100 1 [a..b] product" }
"A range can be converted into a concrete sequence using a word such as " { $link >array } ". In most cases this is unnecessary since ranges implement the sequence protocol already. It is necessary if a mutable sequence is needed, for use with words such as " { $link set-nth } " or " { $link map! } "." ;

ABOUT: "ranges"
