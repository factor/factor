USING: alien alien.c-types help.syntax help.markup libc
kernel.private byte-arrays math strings ;

HELP: <c-type>
{ $values { "type" "a hashtable" } }
{ $description "Creates a prototypical C type. User code should use higher-level facilities to define C types; see " { $link "c-data" } "." } ;

HELP: no-c-type
{ $values { "type" string } }
{ $description "Throws a " { $link no-c-type } " error." }
{ $error-description "Thrown by " { $link c-type } " if a given string does not name a C type. When thrown during compile time, indicates a typo in an " { $link alien-invoke } " or " { $link alien-callback } " form." } ;

HELP: c-types
{ $var-description "Global variable holding a hashtable mapping C type names to C types. Use the " { $link c-type } " word to look up C types." } ;

HELP: c-type
{ $values { "name" string } { "type" "a hashtable" } }
{ $description "Looks up a C type by name." }
{ $errors "Throws a " { $link no-c-type } " error if the type does not exist." } ;

HELP: heap-size
{ $values { "type" string } { "size" "an integer" } }
{ $description "Outputs the number of bytes needed for a heap-allocated value of this C type." }
{ $examples
    "On a 32-bit system, you will get the following output:"
    { $unchecked-example "USE: alien\n\"void*\" heap-size ." "4" }
}
{ $errors "Throws a " { $link no-c-type } " error if the type does not exist." } ;

HELP: stack-size
{ $values { "type" string } { "size" "an integer" } }
{ $description "Outputs the number of bytes to reserve on the C stack by a value of this C type. In most cases this is equal to " { $link heap-size } ", except on some platforms where C structs are passed by invisible reference, in which case a C struct type only uses as much space as a pointer on the C stack." }
{ $errors "Throws a " { $link no-c-type } " error if the type does not exist." } ;

HELP: c-getter
{ $values { "name" string } { "quot" "a quotation with stack effect " { $snippet "( c-ptr n -- obj )" } } }
{ $description "Outputs a quotation which reads values of this C type from a C structure." }
{ $errors "Throws a " { $link no-c-type } " error if the type does not exist." } ;

HELP: c-setter
{ $values { "name" string } { "quot" "a quotation with stack effect " { $snippet "( obj c-ptr n -- )" } } }
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

HELP: string>char-alien ( string -- array )
{ $values { "string" string } { "array" byte-array } }
{ $description "Copies the string to a new byte array, converting it to 8-bit ASCII and adding a trailing null byte." }
{ $errors "Throws an error if the string contains null characters, or characters beyond the 8-bit range." } ;

{ string>char-alien alien>char-string malloc-char-string } related-words

HELP: alien>char-string ( c-ptr -- string )
{ $values { "c-ptr" c-ptr } { "string" string } }
{ $description "Reads a null-terminated 8-bit C string from the specified address." } ;

HELP: string>u16-alien ( string -- array )
{ $values { "string" string } { "array" byte-array } }
{ $description "Copies the string to a new byte array in UCS-2 format with a trailing null byte." }
{ $errors "Throws an error if the string contains null characters." } ;

{ string>u16-alien alien>u16-string malloc-u16-string } related-words

HELP: alien>u16-string ( c-ptr -- string )
{ $values { "c-ptr" c-ptr } { "string" string } }
{ $description "Reads a null-terminated UCS-2 string from the specified address." } ;

HELP: memory>string ( base len -- string )
{ $values { "base" c-ptr } { "len" "a non-negative integer" } { "string" string } }
{ $description "Reads " { $snippet "len" } " bytes starting from " { $snippet "base" } " and stores them in a new Factor string." } ;

HELP: string>memory ( string base -- )
{ $values { "string" string } { "base" c-ptr } }
{ $description "Writes the string to memory starting from the " { $snippet "base" } " address." }
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

HELP: malloc-char-string
{ $values { "string" string } { "alien" c-ptr } }
{ $description "Allocates an unmanaged memory block, and stores a string in 8-bit ASCII encoding with a trailing null byte to the block." }
{ $warning "Don't forget to deallocate the memory with a call to " { $link free } "." }
{ $errors "Throws an error if memory allocation fails." } ;

HELP: malloc-u16-string
{ $values { "string" string } { "alien" c-ptr } }
{ $description "Allocates an unmanaged memory block, and stores a string in UCS2 encoding with a trailing null character to the block." }
{ $warning "Don't forget to deallocate the memory with a call to " { $link free } "." }
{ $errors "Throws an error if memory allocation fails." } ;

HELP: define-nth
{ $values { "name" "a word name" } { "vocab" "a vocabulary name" } }
{ $description "Defines a word " { $snippet { $emphasis "name" } "-nth" } " with stack effect " { $snippet "( n c-ptr -- value )" } " for reading the value with C type " { $snippet "name" } " stored at an alien pointer, displaced by a multiple of the C type's size." }
{ $notes "This is an internal word called when defining C types, there is no need to call it on your own." } ;

HELP: define-set-nth
{ $values { "name" "a word name" } { "vocab" "a vocabulary name" } }
{ $description "Defines a word " { $snippet "set-" { $emphasis "name" } "-nth" } " with stack effect " { $snippet "( value n c-ptr -- )" } " for writing the value with C type " { $snippet "name" } " to an alien pointer, displaced by a multiple of the C type's size." }
{ $notes "This is an internal word called when defining C types, there is no need to call it on your own." } ;

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
{ $values { "name" "a word name" } { "vocab" "a vocabulary name" } }
{ $description "Defines a word " { $snippet "*name" } " with stack effect " { $snippet "( c-ptr -- value )" } " for reading a value with C type " { $snippet "name" } " stored at an alien pointer." }
{ $notes "This is an internal word called when defining C types, there is no need to call it on your own." } ;

HELP: define-out
{ $values { "name" "a word name" } { "vocab" "a vocabulary name" } }
{ $description "Defines a word " { $snippet "<" { $emphasis "name" } ">" } " with stack effect " { $snippet "( value -- array )" } ". This word allocates a byte array large enough to hold a value with C type " { $snippet "name" } ", and writes the value at the top of the stack to the array." }
{ $notes "This is an internal word called when defining C types, there is no need to call it on your own." } ;
