USING: help.markup help.syntax kernel sequences
sequences.private ;
IN: growable

ARTICLE: "growable" "Resizable sequence implementation"
"Resizable sequences are implementing by having a wrapper object hold a reference to an underlying sequence, together with a fill pointer indicating how many elements of the underlying sequence are occupied. When the fill pointer exceeds the underlying sequence capacity, the underlying sequence grows."
$nl
"There is a resizable sequence mixin:"
{ $subsection growable }
"This mixin implements the sequence protocol in terms of a growable protocol:"
{ $subsection underlying }
{ $subsection set-underlying }
{ $subsection set-fill }
"The underlying sequence must implement a generic word:"
{ $subsection resize }
{ $link "vectors" } " and " { $link "sbufs" } " are implemented using the resizable sequence facility." ;

ABOUT: "growable"

HELP: set-fill
{ $values { "n" "a new fill pointer" } { "seq" "a resizable sequence" } }
{ $contract "Sets the fill pointer (number of occupied elements in the underlying storage) of a resizable sequence." }
{ $side-effects "seq" }
{ $warning "This word is in the " { $vocab-link "sequences.private" } " vocabulary because it is not safe. Changing the fill pointer to a negative value, or a value higher than the underlying sequence length can lead to memory corruption. User code should use " { $link set-length } " instead." } ;

HELP: underlying
{ $values { "seq" "a resizable sequence" } { "underlying" "the underlying sequence" } }
{ $contract "Outputs the underlying storage of a resizable sequence." } ;

HELP: set-underlying
{ $values { "underlying" "a sequence" } { "seq" "a resizable sequence" } }
{ $contract "Modifies the underlying storage of a resizable sequence." }
{ $warning "This word is in the " { $vocab-link "sequences.private" } " vocabulary because it is not safe. Setting an underlying sequence shorter than the fill pointer can lead to memory corruption." } ;

HELP: capacity
{ $values { "seq" "a vector or string buffer" } { "n" "the capacity of the sequence" } }
{ $description "Outputs the number of elements the sequence can hold without growing." } ;

HELP: new-size
{ $values { "old" "a positive integer" } { "new" "a positive integer" } }
{ $description "Computes the new size of a resizable sequence." } ;

HELP: ensure
{ $values { "n" "a positive integer" } { "seq" "a resizable sequence" } }
{ $description "If " { $snippet "n" } " is less than the length of the sequence, does nothing. Otherwise, if " { $snippet "n" } " also exceeds the capacity of the underlying storage, the underlying storage is grown, and the fill pointer is reset. Finally, if " { $snippet "n" } " is greater than or equal to the length but less than the capacity of the underlying storage, the fill pointer is moved and nothing else is done."
$nl
"This word is used in the implementation of the " { $link set-nth } " generic for sequences supporting the resizable sequence protocol (see " { $link "growable" } ")."
} ;
