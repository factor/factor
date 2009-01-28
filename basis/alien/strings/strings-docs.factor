USING: help.markup help.syntax strings byte-arrays alien libc
debugger io.encodings.string sequences ;
IN: alien.strings

HELP: string>alien
{ $values { "string" string } { "encoding" "an encoding descriptor" } { "byte-array" byte-array } }
{ $description "Encodes a string together with a trailing null code point using the given encoding, and stores the resulting bytes in a freshly-allocated byte array." }
{ $errors "Throws an error if the string contains null characters, or characters not representable in the given encoding." } ;

{ string>alien alien>string malloc-string } related-words

HELP: alien>string
{ $values { "c-ptr" c-ptr } { "encoding" "an encoding descriptor" } { "string/f" "a string or " { $link f } } }
{ $description "Reads a null-terminated C string from the specified address with the given encoding." } ;

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

HELP: string>symbol
{ $values { "str" string } { "alien" alien } }
{ $description "Converts the string to a format which is a valid symbol name for the Factor VM's compiled code linker. By performing this conversion ahead of time, the image loader can run without allocating memory."
$nl
"On Windows CE, symbols are represented as UCS2 strings, and on all other platforms they are ASCII strings." } ;

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

ABOUT: "c-strings"
