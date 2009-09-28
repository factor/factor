USING: alien alien.complex help.syntax help.markup libc kernel.private
byte-arrays strings hashtables alien.syntax alien.strings sequences
io.encodings.string debugger destructors vocabs.loader
classes.struct ;
QUALIFIED: math
QUALIFIED: sequences
IN: alien.c-types

HELP: byte-length
{ $values { "seq" "A byte array or float array" } { "n" "a non-negative integer" } }
{ $contract "Outputs the size of the byte array, struct, or specialized array data in bytes." } ;

HELP: heap-size
{ $values { "name" "a C type name" } { "size" math:integer } }
{ $description "Outputs the number of bytes needed for a heap-allocated value of this C type." }
{ $examples
    { $example "USING: alien alien.c-types prettyprint ;\nint heap-size ." "4" }
}
{ $errors "Throws a " { $link no-c-type } " error if the type does not exist." } ;

HELP: stack-size
{ $values { "name" "a C type name" } { "size" math:integer } }
{ $description "Outputs the number of bytes to reserve on the C stack by a value of this C type. In most cases this is equal to " { $link heap-size } ", except on some platforms where C structs are passed by invisible reference, in which case a C struct type only uses as much space as a pointer on the C stack." }
{ $errors "Throws a " { $link no-c-type } " error if the type does not exist." } ;

HELP: <c-type>
{ $values { "c-type" c-type } }
{ $description "Creates a prototypical C type. User code should use higher-level facilities to define C types; see " { $link "c-data" } "." } ;

HELP: no-c-type
{ $values { "name" "a C type name" } }
{ $description "Throws a " { $link no-c-type } " error." }
{ $error-description "Thrown by " { $link c-type } " if a given string does not name a C type. When thrown during compile time, indicates a typo in an " { $link alien-invoke } " or " { $link alien-callback } " form." } ;

HELP: c-types
{ $var-description "Global variable holding a hashtable mapping C type names to C types. Use the " { $link c-type } " word to look up C types." } ;

HELP: c-type
{ $values { "name" "a C type" } { "c-type" c-type } }
{ $description "Looks up a C type by name." }
{ $errors "Throws a " { $link no-c-type } " error if the type does not exist." } ;

HELP: c-getter
{ $values { "name" "a C type" } { "quot" { $quotation "( c-ptr n -- obj )" } } }
{ $description "Outputs a quotation which reads values of this C type from a C structure." }
{ $errors "Throws a " { $link no-c-type } " error if the type does not exist." } ;

HELP: c-setter
{ $values { "name" "a C type" } { "quot" { $quotation "( obj c-ptr n -- )" } } }
{ $description "Outputs a quotation which writes values of this C type to a C structure." }
{ $errors "Throws an error if the type does not exist." } ;

HELP: box-parameter
{ $values { "n" math:integer } { "c-type" "a C type" } }
{ $description "Generates code for converting a C value stored at  offset " { $snippet "n" } " from the top of the stack into a Factor object to be pushed on the data stack." }
{ $notes "This is an internal word used by the compiler when compiling callbacks." } ;

HELP: box-return
{ $values { "c-type" "a C type" } }
{ $description "Generates code for converting a C value stored in return registers into a Factor object to be pushed on the data stack." }
{ $notes "This is an internal word used by the compiler when compiling alien calls." } ;

HELP: unbox-return
{ $values { "c-type" "a C type" } }
{ $description "Generates code for converting a Factor value on the data stack into a C value to be stored in the return registers." }
{ $notes "This is an internal word used by the compiler when compiling callbacks." } ;

HELP: define-deref
{ $values { "name" "a word name" } }
{ $description "Defines a word " { $snippet "*name" } " with stack effect " { $snippet "( c-ptr -- value )" } " for reading a value with C type " { $snippet "name" } " stored at an alien pointer." }
{ $notes "This is an internal word called when defining C types, there is no need to call it on your own." } ;

HELP: define-out
{ $values { "name" "a word name" } }
{ $description "Defines a word " { $snippet "<" { $emphasis "name" } ">" } " with stack effect " { $snippet "( value -- array )" } ". This word allocates a byte array large enough to hold a value with C type " { $snippet "name" } ", and writes the value at the top of the stack to the array." }
{ $notes "This is an internal word called when defining C types, there is no need to call it on your own." } ;

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
{ $description "This C type represents a pointer to C memory. " { $link byte-array } " and " { $link alien } " values can be passed as " { $snippet "void*" } " function inputs, but see " { $link "byte-arrays-gc" } " for notes about passing byte arrays into C functions. " { $snippet "void*" } " output values are returned as " { $link alien } "s." } ;
HELP: char*
{ $description "This C type represents a pointer to a C string. See " { $link "c-strings" } " for details about using strings with the FFI." } ;
HELP: float
{ $description "This C type represents a single-precision IEEE 754 floating-point type. Input values will be converted to Factor " { $link math:float } "s and demoted to single-precision; output values will be returned as Factor " { $link math:float } "s." } ;
HELP: double
{ $description "This C type represents a double-precision IEEE 754 floating-point type. Input values will be converted to Factor " { $link math:float } "s; output values will be returned as Factor " { $link math:float } "s." } ;
HELP: complex-float
{ $description "This C type represents a single-precision IEEE 754 floating-point complex type. Input values will be converted from Factor " { $link math:complex } " objects into a single-precision complex float type; output values will be returned as Factor " { $link math:complex } " objects." } ;
HELP: complex-double
{ $description "This C type represents a double-precision IEEE 754 floating-point complex type. Input values will be converted from Factor " { $link math:complex } " objects into a double-precision complex float type; output values will be returned as Factor " { $link math:complex } " objects." } ;


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

ARTICLE: "c-out-params" "Output parameters in C"
"A frequently-occurring idiom in C code is the \"out parameter\". If a C function returns more than one value, the caller passes pointers of the correct type, and the C function writes its return values to those locations."
$nl
"Each numerical C type, together with " { $snippet "void*" } ", has an associated " { $emphasis "out parameter constructor" } " word which takes a Factor object as input, constructs a byte array of the correct size, and converts the Factor object to a C value stored into the byte array:"
{ $subsection <char> }
{ $subsection <uchar> }
{ $subsection <short> }
{ $subsection <ushort> }
{ $subsection <int> }
{ $subsection <uint> }
{ $subsection <long> }
{ $subsection <ulong> }
{ $subsection <longlong> }
{ $subsection <ulonglong> }
{ $subsection <float> }
{ $subsection <double> }
{ $subsection <void*> }
"You call the out parameter constructor with the required initial value, then pass the byte array to the C function, which receives a pointer to the start of the byte array's data area. The C function then returns, leaving the result in the byte array; you read it back using the next set of words:"
{ $subsection *char }
{ $subsection *uchar }
{ $subsection *short }
{ $subsection *ushort }
{ $subsection *int }
{ $subsection *uint }
{ $subsection *long }
{ $subsection *ulong }
{ $subsection *longlong }
{ $subsection *ulonglong }
{ $subsection *float }
{ $subsection *double }
{ $subsection *void* }
"Note that while structure and union types do not get these words defined for them, there is no loss of generality since " { $link <void*> } " and " { $link *void* } " may be used." ;

ARTICLE: "c-types.primitives" "Primitive C types"
"The following numerical types are defined in the " { $vocab-link "alien.c-types" } " vocabulary; a " { $snippet "u" } " prefix denotes an unsigned type:"
{ $table
    { "C type" "Notes" }
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
"The following C99 complex number types are defined in the " { $vocab-link "alien.complex" } " vocabulary:"
{ $table
    { { $link complex-float } { "C99 or Fortran " { $snippet "complex float" } " type, converted to and from Factor " { $link math:complex } " values" } }
    { { $link complex-double } { "C99 or Fortran " { $snippet "complex double" } " type, converted to and from Factor " { $link math:complex } " values" } }
}
"When making alien calls, Factor numbers are converted to and from the above types in a canonical way. Converting a Factor number to a C value may result in a loss of precision." ;

ARTICLE: "c-types.pointers" "Pointer and array types"
"Pointer types are specified by suffixing a C type with " { $snippet "*" } ", for example " { $snippet "float*" } ". One special case is " { $link void* } ", which denotes a generic pointer; " { $link void } " by itself is not a valid C type specifier. With the exception of strings (see " { $link "c-strings" } "), all pointer types are identical to " { $snippet "void*" } " as far as the C library interface is concerned."
$nl
"Fixed-size array types are supported; the syntax consists of a C type name followed by dimension sizes in brackets; the following denotes a 3 by 4 array of integers:"
{ $code "int[3][4]" }
"Fixed-size arrays differ from pointers in that they are allocated inside structures and unions; however when used as function parameters they behave exactly like pointers and thus the dimensions only serve as documentation." ;

ARTICLE: "c-types.ambiguity" "Word name clashes with C types"
"Note that some of the C type word names clash with commonly-used Factor words:"
{ $list
  { { $link short } " clashes with the " { $link sequences:short } " word in the " { $vocab-link "sequences" } " vocabulary" }
  { { $link float } " clashes with the " { $link math:float } " word in the " { $vocab-link "math" } " vocabulary" }
}
"If you use the wrong vocabulary, you will see a " { $link no-c-type } " error. For example, the following is " { $strong "not" } " valid, and will raise an error because the " { $link math:float } " word from the " { $vocab-link "math" } " vocabulary is not a C type:"
{ $code
  "USING: alien.syntax math prettyprint ;"
  "FUNCTION: float magic_number ( ) ;"
  "magic_number 3.0 + ."
}
"The following won't work either; now the problem is that there are two vocabularies in the search path that define a word named " { $snippet "float" } ":"
{ $code
  "USING: alien.c-types alien.syntax math prettyprint ;"
  "FUNCTION: float magic_number ( ) ;"
  "magic_number 3.0 + ."
}
"The correct solution is to use one of " { $link POSTPONE: FROM: } ", " { $link POSTPONE: QUALIFIED: } " or " { $link POSTPONE: QUALIFIED-WITH: } " to disambiguate word lookup:"
{ $code
  "USING: alien.syntax math prettyprint ;"
  "QUALIFIED-WITH: alien.c-types c"
  "FUNCTION: c:float magic_number ( ) ;"
  "magic_number 3.0 + ."
}
"See " { $link "word-search-semantics" } " for details." ;

ARTICLE: "c-types.structs" "Struct and union types"
"Struct and union types are identified by their class word. See " { $link "classes.struct" } "." ;

ARTICLE: "c-types-specs" "C type specifiers"
"C types are identified by special words, and type names occur as parameters to the " { $link alien-invoke } ", " { $link alien-indirect } " and " { $link alien-callback } " words. New C types can be defined by the words " { $link POSTPONE: STRUCT: } ", " { $link POSTPONE: UNION-STRUCT: } ", " { $link POSTPONE: CALLBACK: } ", and " { $link POSTPONE: TYPEDEF: } "."
{ $subsection "c-types.primitives" }
{ $subsection "c-types.pointers" }
{ $subsection "c-types.ambiguity" }
{ $subsection "c-types.structs" }
;

ABOUT: "c-types-specs"
