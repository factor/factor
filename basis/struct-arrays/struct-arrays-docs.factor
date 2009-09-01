IN: struct-arrays
USING: classes.struct help.markup help.syntax alien strings math multiline ;

HELP: struct-array
{ $class-description "The class of C struct and union arrays."
$nl
"The " { $slot "underlying" } " slot holds a " { $link c-ptr } " with the raw data. This pointer can be passed to C functions." } ;

HELP: <struct-array>
{ $values { "length" integer } { "struct-class" struct-class } { "struct-array" struct-array } }
{ $description "Creates a new array for holding values of the specified struct type." } ;

HELP: <direct-struct-array>
{ $values { "alien" c-ptr } { "length" integer } { "struct-class" struct-class } { "struct-array" struct-array } }
{ $description "Creates a new array for holding values of the specified C type, backed by the memory at " { $snippet "alien" } "." } ;

HELP: struct-array-on
{ $values { "struct" struct } { "length" integer } { "struct-array" struct-array } }
{ $description "Create a new array for holding values of " { $snippet "struct" } "'s C type, backed by the memory starting at " { $snippet "struct" } "'s address." }
{ $examples
"This word is useful with the FFI. When a C function has a pointer to a struct as its return type (or a C callback has a struct pointer as an argument type), Factor automatically wraps the pointer in a " { $link struct } " object. If the pointer actually references an array of objects, this word will convert the struct object to a struct array object:"
{ $code <" USING: alien.syntax classes.struct struct-arrays ;
IN: scratchpad

STRUCT: zim { zang int } { zung int } ;

FUNCTION: zim* zingle ( ) ; ! Returns a pointer to 20 zims

zingle 20 struct-array-on "> }
} ;

HELP: struct-array{
{ $syntax "struct-array{ class value value value ... }" }
{ $description "Literal syntax for a " { $link struct-array } " containing structs of the given " { $link struct } " class." } ;

HELP: struct-array@
{ $syntax "struct-array@ class alien length" }
{ $description "Literal syntax for a " { $link struct-array } " at a particular memory address. The prettyprinter uses this syntax when the memory backing a struct array object is invalid. This syntax should not generally be used in source code." } ;

{ POSTPONE: struct-array{ POSTPONE: struct-array@ } related-words

ARTICLE: "struct-arrays" "C struct and union arrays"
"The " { $vocab-link "struct-arrays" } " vocabulary implements arrays specialized for holding C struct and union values."
{ $subsection struct-array }
{ $subsection <struct-array> }
{ $subsection <direct-struct-array> }
{ $subsection struct-array-on }
"Struct arrays have literal syntax:"
{ $subsection POSTPONE: struct-array{ } ;

ABOUT: "struct-arrays"
