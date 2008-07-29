USING: help.syntax help.markup splitting kernel sequences ;
IN: tuple-arrays

HELP: tuple-array
{ $description "The class of packed homogeneous tuple arrays. They are created with " { $link <tuple-array> } ". All elements are of the same tuple class. Mutations done to an element are not copied back to the packed array unless it is explicitly written back. To convert a sequence to a tuple array, use the word " { $link >tuple-array } "." } ;

HELP: <tuple-array>
{ $values { "class" "a tuple class" } { "length" "a non-negative integer" } { "tuple-array" tuple-array } }
{ $description "Creates an instance of the " { $link <tuple-array> } " class with the given length and containing the given tuple class." } ;

HELP: >tuple-array
{ $values { "seq" sequence } { "tuple-array" tuple-array } }
{ $description "Converts a sequence into a homogeneous unboxed tuple array of the type indicated by the first element." } ;
