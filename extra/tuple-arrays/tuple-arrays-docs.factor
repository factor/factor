USING: help.syntax help.markup tuple-arrays splitting kernel ;

HELP: tuple-array
{ $description "The class of packed homogeneous tuple arrays. They are created with " { $link <tuple-array> } ". All elements are of the same tuple class. Mutations done to an element are not copied back to the packed array unless it is explicitly written back. Packed follows the sequence protocol and is implemented using the " { $link groups } " class." } ;

HELP: <tuple-array>
{ $values { "example" tuple } { "length" "a non-negative integer" } { "tuple-array" tuple-array } }
{ $description "Creates an instance of the " { $link <tuple-array> } " class with the given length and containing the given tuple class. The tuple class is specified in the form of an example tuple. If the example tuple has a delegate, the tuple array will store a delegate for each element. Otherwise, the delegate will be assumed to be f." } ;
