USING: help.markup help.syntax sequences sequences.private ;
IN: growable

ARTICLE: "growable" "Resizable sequence implementation"
"Resizable sequences are implemented by having a wrapper object hold a reference to an underlying sequence, together with a fill pointer indicating how many elements of the underlying sequence are occupied. When the fill pointer exceeds the underlying sequence capacity, the underlying sequence grows."
$nl
"There is a resizable sequence mixin:"
{ $subsections growable }
"This mixin implements the sequence protocol by assuming the object has two specific slots:"
{ $list
    { { $snippet "length" } " - the fill pointer (number of occupied elements in the underlying storage)" }
    { { $snippet "underlying" } " - the underlying storage" }
}
"The underlying sequence must implement a generic word:"
{ $subsections resize }
{ $link "vectors" } " and " { $link "sbufs" } " are implemented using the resizable sequence facility." ;

ABOUT: "growable"

HELP: capacity
{ $values { "seq" "a vector or string buffer" } { "n" "the capacity of the sequence" } }
{ $description "Outputs the number of elements the sequence can hold without growing." } ;

HELP: new-size
{ $values { "old" "a positive integer" } { "new" "a positive integer" } }
{ $description "Computes the new size of a resizable sequence." } ;

HELP: ensure
{ $values { "n" "a non-negative integer" } { "seq" growable } }
{ $description "Ensures that " { $snippet "seq" } " has sufficient capacity to store an " { $snippet "n" } "th element." $nl "This word behaves as follows, depending on the relation between " { $snippet "n" } ", the capacity of the underlying storage, and the length of the sequence:"
{ $list
  { "If " { $snippet "n" } " is less than the length of the sequence, does nothing." }
  { "If " { $snippet "n" } " is greater than or equal to the capacity of the underlying storage, the underlying storage is grown." }
  { "If " { $snippet "n" } " is greater than or equal to the length, the length is increased." }
}
"In the case that new elements are added to the sequence (last two cases), the new elements are undefined." }
{ $notes "This word is used in the implementation of the " { $link set-nth } " generic for sequences supporting the resizable sequence protocol (see " { $link "growable" } ")."
} ;
