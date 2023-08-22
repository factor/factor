USING: alien alien.syntax byte-arrays classes.struct help.markup
help.syntax kernel math sequences ;
IN: alien.c-types

HELP: heap-size
{ $values { "name" c-type-name } { "size" math:integer } }
{ $description "Outputs the number of bytes needed for a heap-allocated value of this C type." }
{ $examples
    { $example "USING: alien alien.c-types prettyprint ;\nint heap-size ." "4" }
}
{ $errors "Throws a " { $link no-c-type } " error if the type does not exist." } ;

HELP: <c-type>
{ $values { "c-type" c-type } }
{ $description "Creates a prototypical C type. User code should use higher-level facilities to define C types; see " { $link "c-data" } "." } ;

HELP: no-c-type
{ $values { "name" c-type-name } }
{ $description "Throws a " { $link no-c-type } " error." }
{ $error-description "Thrown by " { $link c-type } " if a given word is not a C type." } ;

HELP: lookup-c-type
{ $values { "name" c-type-name } { "c-type" c-type } }
{ $description "Looks up a C type by name." }
{ $errors "Throws a " { $link no-c-type } " error if the type does not exist, or the word is not a C type." } ;

HELP: alien-value
{ $values { "c-ptr" c-ptr } { "offset" integer } { "c-type" c-type-name } { "value" object } }
{ $description "Loads a value at a byte offset from a base C pointer." }
{ $errors "Throws a " { $link no-c-type } " error if the type does not exist." } ;

HELP: set-alien-value
{ $values { "value" object } { "c-ptr" c-ptr } { "offset" integer } { "c-type" c-type-name } }
{ $description "Stores a value at a byte offset from a base C pointer." }
{ $errors "Throws a " { $link no-c-type } " error if the type does not exist." } ;

HELP: char
{ $description "This C type represents a one-byte signed integer type. Input values will be converted to " { $link math:integer } "s and truncated to eight bits; output values will be returned as " { $link math:fixnum } "s." } ;
HELP: uchar
{ $description "This C type represents a one-byte unsigned integer type. Input values will be converted to " { $link math:integer } "s and truncated to eight bits; output values will be returned as " { $link math:fixnum } "s." } ;
HELP: short
{ $description "This C type represents a two-byte signed integer type. Input values will be converted to " { $link math:integer } "s and truncated to sixteen bits; output values will be returned as " { $link math:fixnum } "s." } ;
HELP: ushort
{ $description "This C type represents a two-byte unsigned integer type. Input values will be converted to " { $link math:integer } "s and truncated to sixteen bits; output values will be returned as " { $link math:fixnum } "s." } ;
HELP: int
{ $description "This C type represents a four-byte signed integer type. Input values will be converted to " { $link math:integer } "s and truncated to 32 bits; output values will be returned as " { $link math:integer } "s." } ;
HELP: uint
{ $description "This C type represents a four-byte unsigned integer type. Input values will be converted to " { $link math:integer } "s and truncated to 32 bits; output values will be returned as " { $link math:integer } "s." } ;
HELP: long
{ $description "This C type represents a four- or eight-byte signed integer type. On Windows and on 32-bit Unix platforms, it will be four bytes. On 64-bit Unix platforms, it will be eight bytes. Input values will be converted to " { $link math:integer } "s and truncated to 32 or 64 bits; output values will be returned as " { $link math:integer } "s." } ;
HELP: intptr_t
{ $description "This C type represents a signed integer type large enough to hold any pointer value; that is, on 32-bit platforms, it will be four bytes, and on 64-bit platforms, it will be eight bytes. Input values will be converted to " { $link math:integer } "s and truncated to 32 or 64 bits; output values will be returned as " { $link math:integer } "s." } ;
HELP: ulong
{ $description "This C type represents a four- or eight-byte unsigned integer type. On Windows and on 32-bit Unix platforms, it will be four bytes. On 64-bit Unix platforms, it will be eight bytes. Input values will be converted to " { $link math:integer } "s and truncated to 32 or 64 bits; output values will be returned as " { $link math:integer } "s." } ;
HELP: uintptr_t
{ $description "This C type represents an unsigned integer type large enough to hold any pointer value; that is, on 32-bit platforms, it will be four bytes, and on 64-bit platforms, it will be eight bytes. Input values will be converted to " { $link math:integer } "s and truncated to 32 or 64 bits; output values will be returned as " { $link math:integer } "s." } ;
HELP: ptrdiff_t
{ $description "This C type represents a signed integer type large enough to hold the distance between two pointer values; that is, on 32-bit platforms, it will be four bytes, and on 64-bit platforms, it will be eight bytes. Input values will be converted to " { $link math:integer } "s and truncated to 32 or 64 bits; output values will be returned as " { $link math:integer } "s." } ;
HELP: size_t
{ $description "This C type represents unsigned size values of the size expected by the platform's standard C library (usually four bytes on a 32-bit platform, and eight on a 64-bit platform). Input values will be converted to " { $link math:integer } "s and truncated to the appropriate size; output values will be returned as " { $link math:integer } "s." } ;
HELP: longlong
{ $description "This C type represents an eight-byte signed integer type. Input values will be converted to " { $link math:integer } "s and truncated to 64 bits; output values will be returned as " { $link math:integer } "s." } ;
HELP: ulonglong
{ $description "This C type represents an eight-byte unsigned integer type. Input values will be converted to " { $link math:integer } "s and truncated to 64 bits; output values will be returned as " { $link math:integer } "s." } ;
HELP: void
{ $description "This symbol is not a valid C type, but it can be used as the return type for a " { $link POSTPONE: FUNCTION: } " or " { $link POSTPONE: CALLBACK: } " definition or for an " { $link alien-invoke } " or " { $link alien-callback } " call." } ;
HELP: void*
{ $description "This C type represents a generic pointer to C memory. See " { $link pointer } " for information on pointer C types." } ;
HELP: c-string
{ $description "This C type represents a pointer to a C string. See " { $link "c-strings" } " for details about using strings with the FFI." } ;
HELP: float
{ $description "This C type represents a single-precision IEEE 754 floating-point type. Input values will be converted to Factor " { $link math:float } "s and demoted to single-precision; output values will be returned as Factor " { $link math:float } "s." } ;
HELP: double
{ $description "This C type represents a double-precision IEEE 754 floating-point type. Input values will be converted to Factor " { $link math:float } "s; output values will be returned as Factor " { $link math:float } "s." } ;

HELP: pointer:
{ $syntax "pointer: c-type" }
{ $description "Constructs a " { $link pointer } " C type." } ;

HELP: pointer
{ $class-description "Represents a pointer C type. The " { $snippet "to" } " slot contains the C type being pointed to. Both " { $link byte-array } " and " { $link alien } " values can be provided as pointer function inputs, but see " { $link "byte-arrays-gc" } " for notes about passing byte arrays into C functions. Objects with methods on " { $link >c-ptr } ", such as structs and specialized arrays, may also be used as pointer inputs."
$nl
"Pointer output values are represented in Factor as " { $link alien } "s. If the pointed-to type is a struct, the alien will automatically be wrapped in a struct object if it is not null."
$nl
"In " { $link POSTPONE: TYPEDEF: } ", " { $link POSTPONE: FUNCTION: } ", " { $link POSTPONE: CALLBACK: } ", and " { $link POSTPONE: STRUCT: } " definitions, pointer types can be created by suffixing " { $snippet "*" } " to a C type name. Outside of FFI definitions, a pointer C type can be created using the " { $link POSTPONE: pointer: } " syntax word:"
{ $unchecked-example "FUNCTION: int* foo ( char* bar )" }
{ $unchecked-example ": foo ( bar -- int* )
    pointer: int f \"foo\" { pointer: char } f alien-invoke ;" } } ;

ARTICLE: "byte-arrays-gc" "Byte arrays and the garbage collector"
"The Factor garbage collector can move byte arrays around, and it is only safe to pass byte arrays to C functions if the garbage collector will not run while C code still has a reference to the data."
$nl
"In particular, a byte array can only be passed as a parameter if the the C function does not use the parameter after one of the following occurs:"
{ $list
    "the C function returns"
    "the C function calls Factor code via a callback"
}
"Returning from C to Factor, as well as invoking Factor code via a callback, may trigger garbage collection, and if the function had stored a pointer to the byte array somewhere, this pointer may cease to be valid."
$nl
"If this condition is not satisfied, " { $link "malloc" } " must be used instead."
{ $warning "Failure to comply with these requirements can lead to crashes, data corruption, and security exploits." } ;

ARTICLE: "c-types.primitives" "Primitive C types"
"The following numerical types are defined in the " { $vocab-link "alien.c-types" } " vocabulary; a " { $snippet "u" } " prefix denotes an unsigned type:"
{ $table
    { { $strong "C type" } { $strong "Notes" } }
    { { $link char } "always 1 byte" }
    { { $link uchar } { } }
    { { $link short } "always 2 bytes" }
    { { $link ushort } { } }
    { { $link int } "always 4 bytes" }
    { { $link uint } { } }
    { { $link long } { "same size as CPU word size and " { $link void* } ", except on 64-bit Windows, where it is 4 bytes" } }
    { { $link ulong } { } }
    { { $link longlong } "always 8 bytes" }
    { { $link ulonglong } { } }
    { { $link float } { "single-precision float (not the same as Factor's " { $link math:float } " class!)" } }
    { { $link double } { "double-precision float (the same format as Factor's " { $link math:float } " objects)" } }
}
"C99 complex number types are defined in the " { $vocab-link "alien.complex" } " vocabulary."
$nl
"When making alien calls, Factor numbers are converted to and from the above types in a canonical way. Converting a Factor number to a C value may result in a loss of precision." ;

ARTICLE: "c-types.pointers" "Pointer and array types"
"Pointer types are specified by suffixing a C type with " { $snippet "*" } ", for example " { $snippet "float*" } ". One special case is " { $link void* } ", which denotes a generic pointer; " { $link void } " by itself is not a valid C type specifier. This syntax constructs a " { $link pointer } " object to represent the C type."
$nl
"Fixed-size array types are supported; the syntax consists of a C type name followed by dimension sizes in brackets; the following denotes a 3 by 4 array of integers:"
{ $code "int[3][4]" }
"Fixed-size arrays differ from pointers in that they are allocated inside structures and unions; however, when used as function parameters, they behave exactly like pointers with the dimensions only serving as documentation." ;

ARTICLE: "c-types.ambiguity" "Word name clashes with C types"
"Note that some of the C type word names clash with commonly-used Factor words:"
{ $list
  { { $link float } " clashes with the " { $link math:float } " word in the " { $vocab-link "math" } " vocabulary" }
}
"If you use the wrong vocabulary, you will see a " { $link no-c-type } " error. For example, the following is " { $strong "not" } " valid, and will raise an error because the " { $link math:float } " word from the " { $vocab-link "math" } " vocabulary is not a C type:"
{ $code
  "USING: alien.syntax math prettyprint ;"
  "FUNCTION: float magic_number ( )"
  "magic_number 3.0 + ."
}
"The following won't work either; now the problem is that there are two vocabularies in the search path that define a word named " { $snippet "float" } ":"
{ $code
  "USING: alien.c-types alien.syntax math prettyprint ;"
  "FUNCTION: float magic_number ( )"
  "magic_number 3.0 + ."
}
"The correct solution is to use one of " { $link POSTPONE: FROM: } ", " { $link POSTPONE: QUALIFIED: } " or " { $link POSTPONE: QUALIFIED-WITH: } " to disambiguate word lookup:"
{ $code
  "USING: alien.syntax math prettyprint ;"
  "QUALIFIED-WITH: alien.c-types c"
  "FUNCTION: c:float magic_number ( )"
  "magic_number 3.0 + ."
}
"See " { $link "word-search-semantics" } " for details." ;

ARTICLE: "c-types.structs" "Struct and union types"
"Struct and union types are identified by their class word. See " { $link "classes.struct" } "." ;

ARTICLE: "c-types-specs" "C type specifiers"
"C types are identified by special words. Type names occur as parameters to the " { $link alien-invoke } ", " { $link alien-indirect } " and " { $link alien-callback } " words."
$nl
"Defining new C types:"
{ $subsections
    POSTPONE: STRUCT:
    POSTPONE: UNION-STRUCT:
    POSTPONE: CALLBACK:
    POSTPONE: TYPEDEF:
}
"Getting the c-type of a class:"
{ $subsections lookup-c-type }
{ $heading "Related articles" }
{ $subsections
    "c-types.primitives"
    "c-types.pointers"
    "c-types.ambiguity"
    "c-types.structs"
}
;

ABOUT: "c-types-specs"
