IN: alien.c-types
USING: alien help.syntax help.markup libc kernel.private
byte-arrays math strings hashtables alien.syntax alien.strings sequences
io.encodings.string debugger destructors ;

HELP: <c-type>
{ $values { "type" hashtable } }
{ $description "Creates a prototypical C type. User code should use higher-level facilities to define C types; see " { $link "c-data" } "." } ;

HELP: no-c-type
{ $values { "type" string } }
{ $description "Throws a " { $link no-c-type } " error." }
{ $error-description "Thrown by " { $link c-type } " if a given string does not name a C type. When thrown during compile time, indicates a typo in an " { $link alien-invoke } " or " { $link alien-callback } " form." } ;

HELP: c-types
{ $var-description "Global variable holding a hashtable mapping C type names to C types. Use the " { $link c-type } " word to look up C types." } ;

HELP: c-type
{ $values { "name" string } { "type" hashtable } }
{ $description "Looks up a C type by name." }
{ $errors "Throws a " { $link no-c-type } " error if the type does not exist." } ;

HELP: heap-size
{ $values { "type" string } { "size" integer } }
{ $description "Outputs the number of bytes needed for a heap-allocated value of this C type." }
{ $examples
    "On a 32-bit system, you will get the following output:"
    { $unchecked-example "USE: alien\n\"void*\" heap-size ." "4" }
}
{ $errors "Throws a " { $link no-c-type } " error if the type does not exist." } ;

HELP: stack-size
{ $values { "type" string } { "size" integer } }
{ $description "Outputs the number of bytes to reserve on the C stack by a value of this C type. In most cases this is equal to " { $link heap-size } ", except on some platforms where C structs are passed by invisible reference, in which case a C struct type only uses as much space as a pointer on the C stack." }
{ $errors "Throws a " { $link no-c-type } " error if the type does not exist." } ;

HELP: byte-length
{ $values { "seq" "A byte array or float array" } { "n" "a non-negative integer" } }
{ $contract "Outputs the size of the byte array or float array data in bytes as presented to the C library interface." } ;

HELP: c-getter
{ $values { "name" string } { "quot" { $quotation "( c-ptr n -- obj )" } } }
{ $description "Outputs a quotation which reads values of this C type from a C structure." }
{ $errors "Throws a " { $link no-c-type } " error if the type does not exist." } ;

HELP: c-setter
{ $values { "name" string } { "quot" { $quotation "( obj c-ptr n -- )" } } }
{ $description "Outputs a quotation which writes values of this C type to a C structure." }
{ $errors "Throws an error if the type does not exist." } ;

HELP: <c-array>
{ $values { "n" "a non-negative integer" } { "type" "a C type" } { "array" byte-array } }
{ $description "Creates a byte array large enough to hold " { $snippet "n" } " values of a C type." }
{ $errors "Throws an error if the type does not exist or the requested size is negative." } ;

{ <c-array> malloc-array } related-words

HELP: <c-object>
{ $values { "type" "a C type" } { "array" byte-array } }
{ $description "Creates a byte array suitable for holding a value with the given C type." }
{ $errors "Throws an " { $link no-c-type } " error if the type does not exist." } ;

{ <c-object> malloc-object } related-words

HELP: memory>byte-array
{ $values { "alien" c-ptr } { "len" "a non-negative integer" } { "byte-array" byte-array } }
{ $description "Reads " { $snippet "len" } " bytes starting from " { $snippet "base" } " and stores them in a new byte array." } ;

HELP: byte-array>memory
{ $values { "byte-array" byte-array } { "base" c-ptr } }
{ $description "Writes a byte array to memory starting from the " { $snippet "base" } " address." }
{ $warning "This word is unsafe. Improper use can corrupt memory." } ;

HELP: malloc-array
{ $values { "n" "a non-negative integer" } { "type" "a C type" } { "alien" alien } }
{ $description "Allocates an unmanaged memory block large enough to hold " { $snippet "n" } " values of a C type." }
{ $warning "Don't forget to deallocate the memory with a call to " { $link free } "." }
{ $errors "Throws an error if the type does not exist, if the requested size is negative, or if memory allocation fails." } ;

HELP: malloc-object
{ $values { "type" "a C type" } { "alien" alien } }
{ $description "Allocates an unmanaged memory block large enough to hold a value of a C type." }
{ $warning "Don't forget to deallocate the memory with a call to " { $link free } "." }
{ $errors "Throws an error if the type does not exist or if memory allocation fails." } ;

HELP: malloc-byte-array
{ $values { "byte-array" byte-array } { "alien" alien } }
{ $description "Allocates an unmanaged memory block of the same size as the byte array, and copies the contents of the byte array there." }
{ $warning "Don't forget to deallocate the memory with a call to " { $link free } "." }
{ $errors "Throws an error if memory allocation fails." } ;

HELP: box-parameter
{ $values { "n" integer } { "ctype" string } }
{ $description "Generates code for converting a C value stored at  offset " { $snippet "n" } " from the top of the stack into a Factor object to be pushed on the data stack." }
{ $notes "This is an internal word used by the compiler when compiling callbacks." } ;

HELP: box-return
{ $values { "ctype" string } }
{ $description "Generates code for converting a C value stored in return registers into a Factor object to be pushed on the data stack." }
{ $notes "This is an internal word used by the compiler when compiling alien calls." } ;

HELP: unbox-return
{ $values { "ctype" string } }
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

{ string>alien alien>string malloc-string } related-words

HELP: malloc-string
{ $values { "string" string } { "encoding" "an encoding descriptor" } { "alien" c-ptr } }
{ $description "Encodes a string together with a trailing null code point using the given encoding, and stores the resulting bytes in a freshly-allocated unmanaged memory block." }
{ $warning "Don't forget to deallocate the memory with a call to " { $link free } "." }
{ $errors "Throws an error if one of the following conditions occurs:"
    { $list
        "the string contains null code points"
        "the string contains characters not representable using the encoding specified"
        "memory allocation fails"
    }
} ;

ARTICLE: "c-strings" "C strings"
"C string types are arrays with shape " { $snippet "{ \"char*\" encoding }" } ", where " { $snippet "encoding" } " is an encoding descriptor. The type " { $snippet "\"char*\"" } " is an alias for " { $snippet "{ \"char*\" utf8 }" } ". See " { $link "encodings-descriptors" } " for information about encoding descriptors."
$nl
"Passing a Factor string to a C function expecting a C string allocates a " { $link byte-array } " in the Factor heap; the string is then converted to the requested format and a raw pointer is passed to the function."
$nl
"If the conversion fails, for example if the string contains null bytes or characters with values higher than 255, a " { $link c-string-error. } " is thrown."
$nl
"Care must be taken if the C function expects a " { $snippet "char*" } " with a length in bytes, rather than a null-terminated " { $snippet "char*" } "; passing the result of calling " { $link length } " on the string object will not suffice. This is because a Factor string of " { $emphasis "n" } " characters will not necessarily encode to " { $emphasis "n" } " bytes. The correct idiom for C functions which take a string with a length is to first encode the string using " { $link encode } ", and then pass the resulting byte array together with the length of this byte array."
$nl
"Sometimes a C function has a parameter type of " { $snippet "void*" } ", and various data types, among them strings, can be passed in. In this case, strings are not automatically converted to aliens, and instead you must call one of these words:"
{ $subsection string>alien }
{ $subsection malloc-string }
"The first allocates " { $link byte-array } "s, and the latter allocates manually-managed memory which is not moved by the garbage collector and has to be explicitly freed by calling " { $link free } ". See " { $link "byte-arrays-gc" } " for a discussion of the two approaches."
$nl
"A word to read strings from arbitrary addresses:"
{ $subsection alien>string }
"For example, if a C function returns a " { $snippet "char*" } " but stipulates that the caller must deallocate the memory afterward, you must define the function as returning " { $snippet "void*" } ", and call one of the above words before passing the pointer to " { $link free } "." ;

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

ARTICLE: "c-types-specs" "C type specifiers"
"C types are identified by strings, and type names occur as parameters to the " { $link alien-invoke } ", " { $link alien-indirect } " and " { $link alien-callback } " words, as well as " { $link POSTPONE: C-STRUCT: } ", " { $link POSTPONE: C-UNION: } " and " { $link POSTPONE: TYPEDEF: } "."
$nl
"The following numerical types are available; a " { $snippet "u" } " prefix denotes an unsigned type:"
{ $table
    { "C type" "Notes" }
    { { $snippet "char" } "always 1 byte" }
    { { $snippet "uchar" } { } }
    { { $snippet "short" } "always 2 bytes" }
    { { $snippet "ushort" } { } }
    { { $snippet "int" } "always 4 bytes" }
    { { $snippet "uint" } { } }
    { { $snippet "long" } { "same size as CPU word size and " { $snippet "void*" } ", except on 64-bit Windows, where it is 4 bytes" } }
    { { $snippet "ulong" } { } }
    { { $snippet "longlong" } "always 8 bytes" }
    { { $snippet "ulonglong" } { } }
    { { $snippet "float" } { } }
    { { $snippet "double" } { "same format as " { $link float } " objects" } }
    { { $snippet "complex-float" } { "C99 " { $snippet "complex float" } " type, converted to and from " { $link complex } " values" } }
    { { $snippet "complex-double" } { "C99 " { $snippet "complex double" } " type, converted to and from " { $link complex } " values" } }
}
"When making alien calls, Factor numbers are converted to and from the above types in a canonical way. Converting a Factor number to a C value may result in a loss of precision."
$nl
"Pointer types are specified by suffixing a C type with " { $snippet "*" } ", for example " { $snippet "float*" } ". One special case is " { $snippet "void*" } ", which denotes a generic pointer; " { $snippet "void" } " by itself is not a valid C type specifier. With the exception of strings (see " { $link "c-strings" } "), all pointer types are identical to " { $snippet "void*" } " as far as the C library interface is concerned."
$nl
"Fixed-size array types are supported; the syntax consists of a C type name followed by dimension sizes in brackets; the following denotes a 3 by 4 array of integers:"
{ $code "int[3][4]" }
"Fixed-size arrays differ from pointers in that they are allocated inside structures and unions; however when used as function parameters they behave exactly like pointers and thus the dimensions only serve as documentation."
$nl
"Structure and union types are specified by the name of the structure or union." ;

ARTICLE: "c-byte-arrays" "Passing data in byte arrays"
"Instances of the " { $link byte-array } " class can be passed to C functions; the C function receives a pointer to the first element of the array."
$nl
"Byte arrays can be allocated directly with a byte count using the " { $link <byte-array> } " word. However in most cases, instead of computing a size in bytes directly, it is easier to use a higher-level word which expects C type and outputs a byte array large enough to hold that type:"
{ $subsection <c-object> }
{ $subsection <c-array> }
{ $warning
"The Factor garbage collector can move byte arrays around, and code passing byte arrays to C must obey important guidelines. See " { $link "byte-arrays-gc" } "." }
{ $see-also "c-arrays" } ;

ARTICLE: "malloc" "Manual memory management"
"Sometimes data passed to C functions must be allocated at a fixed address. See " { $link "byte-arrays-gc" } " for an explanation of when this is the case."
$nl
"Allocating a C datum with a fixed address:"
{ $subsection malloc-object }
{ $subsection malloc-array }
{ $subsection malloc-byte-array }
"There is a set of words in the " { $vocab-link "libc" } " vocabulary which directly call C standard library memory management functions:"
{ $subsection malloc }
{ $subsection calloc }
{ $subsection realloc }
"You must always free pointers returned by any of the above words when the block of memory is no longer in use:"
{ $subsection free }
"Utilities for automatically freeing memory in conjunction with " { $link with-destructors } ":"
{ $subsection &free }
{ $subsection |free }
"The " { $link &free } " and " { $link |free } " words are generated using " { $link "alien.destructors" } "."
$nl
"You can unsafely copy a range of bytes from one memory location to another:"
{ $subsection memcpy }
"You can copy a range of bytes from memory into a byte array:"
{ $subsection memory>byte-array }
"You can copy a byte array to memory unsafely:"
{ $subsection byte-array>memory } ;

ARTICLE: "c-data" "Passing data between Factor and C"
"Two defining characteristics of Factor are dynamic typing and automatic memory management, which are somewhat incompatible with the machine-level data model exposed by C. Factor's C library interface defines its own set of C data types, distinct from Factor language types, together with automatic conversion between Factor values and C types. For example, C integer types must be declared and are fixed-width, whereas Factor supports arbitrary-precision integers."
$nl
"Furthermore, Factor's garbage collector can move objects in memory; for a discussion of the consequences, see " { $link "byte-arrays-gc" } "."
{ $subsection "c-types-specs" }
{ $subsection "c-byte-arrays" }
{ $subsection "malloc" }
{ $subsection "c-strings" }
{ $subsection "c-arrays" }
{ $subsection "c-out-params" }
"Important guidelines for passing data in byte arrays:"
{ $subsection "byte-arrays-gc" }
"C-style enumerated types are supported:"
{ $subsection POSTPONE: C-ENUM: }
"C types can be aliased for convenience and consitency with native library documentation:"
{ $subsection POSTPONE: TYPEDEF: }
"New C types can be defined:"
{ $subsection "c-structs" }
{ $subsection "c-unions" }
"A utility for defining " { $link "destructors" } " for deallocating memory:"
{ $subsection "alien.destructors" }
{ $see-also "aliens" } ;
