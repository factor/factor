IN: alien.syntax
USING: alien alien.c-types alien.enums alien.libraries classes.struct
help.markup help.syntax see ;

HELP: DLL"
{ $syntax "DLL\" path\"" }
{ $values { "path" "a pathname string" } }
{ $description "Constructs a DLL handle at parse time." } ;

HELP: ALIEN:
{ $syntax "ALIEN: address" }
{ $values { "address" "a non-negative hexadecimal integer" } }
{ $description "Creates an alien object at parse time." }
{ $notes "Alien objects are invalidated between image saves and loads, and hence source files should not contain alien literals; this word is for interactive use only. See " { $link "alien-expiry" } " for details." } ;

ARTICLE: "syntax-aliens" "Alien object literal syntax"
{ $subsections
    POSTPONE: ALIEN:
    POSTPONE: DLL"
} ;

HELP: LIBRARY:
{ $syntax "LIBRARY: name" }
{ $values { "name" "a logical library name" } }
{ $description "Sets the logical library for consequent " { $link POSTPONE: FUNCTION: } ", " { $link POSTPONE: C-GLOBAL: } " and " { $link POSTPONE: CALLBACK: } " definitions, as well as " { $link POSTPONE: &: } " forms." }
{ $notes "Logical library names are defined with the " { $link add-library } " word." } ;

HELP: FUNCTION:
{ $syntax "FUNCTION: return name ( parameters ) ;" }
{ $values { "return" "a C return type" } { "name" "a C function name" } { "parameters" "a comma-separated sequence of type/name pairs; " { $snippet "type1 arg1, type2 arg2, ..." } } }
{ $description "Defines a new word " { $snippet "name" } " which calls the C library function with the same " { $snippet "name" } " in the logical library given by the most recent " { $link POSTPONE: LIBRARY: } " declaration."
$nl
"The new word must be compiled before being executed." }
{ $examples
"For example, suppose the " { $snippet "foo" } " library exports the following function:"
{ $code
    "void the_answer(char* question, int value) {"
    "    printf(\"The answer to %s is %d.\n\",question,value);"
    "}"
}
"You can define a word for invoking it:"
{ $unchecked-example
    "LIBRARY: foo\nFUNCTION: void the_answer ( c-string question, int value ) ;"
    "\"the question\" 42 the_answer"
    "The answer to the question is 42."
} }
"Using the " { $link c-string } " type instead of " { $snippet "char*" } " causes the FFI to automatically convert Factor strings to C strings. See " { $link "c-strings" } " for more information on using strings with the FFI."
{ $notes "Note that the parentheses and commas are only syntax sugar and can be omitted; they serve no purpose other than to make the declaration easier to read. The following definitions are equivalent:"
{ $code
    "FUNCTION: void glHint ( GLenum target, GLenum mode ) ;"
    "FUNCTION: void glHint GLenum target GLenum mode ;"
}
"To make a Factor word with a name different from the C function, use " { $link POSTPONE: FUNCTION-ALIAS: } "." } ;

HELP: FUNCTION-ALIAS:
{ $syntax "FUNCTION-ALIAS: factor-name
    return c_name ( parameters ) ;" }
{ $values { "factor-name" "a Factor word name" } { "return" "a C return type" } { "name" "a C function name" } { "parameters" "a comma-separated sequence of type/name pairs; " { $snippet "type1 arg1, type2 arg2, ..." } } }
{ $description "Defines a new word " { $snippet "factor-name" } " which calls the C library function named " { $snippet "c_name" } " in the logical library given by the most recent " { $link POSTPONE: LIBRARY: } " declaration."
$nl
"The new word must be compiled before being executed." }
{ $notes "Note that the parentheses and commas are only syntax sugar and can be omitted. They serve no purpose other than to make the declaration easier to read." } ;

{ POSTPONE: FUNCTION: POSTPONE: FUNCTION-ALIAS: } related-words

HELP: TYPEDEF:
{ $syntax "TYPEDEF: old new" }
{ $values { "old" "a C type" } { "new" "a C type" } }
{ $description "Aliases the C type " { $snippet "old" } " under the name " { $snippet "new" } "." }
{ $notes "This word differs from " { $link typedef } " in that it runs at parse time, to ensure correct ordering of operations when loading source files. Words defined in source files are compiled before top-level forms are run, so if a source file defines C binding words and uses " { $link typedef } ", the type alias won't be available at compile time." } ;

HELP: ENUM:
{ $syntax "ENUM: type words... ;" "ENUM: type < base-type words..." }
{ $values { "type" "a name to typedef to int or f" } { "words" "a sequence of word names" } }
{ $description "Creates a c-type that boxes and unboxes integer values to singletons. A singleton is defined for each member word. The base c-type can optionally be specified and defaults to " { $snippet "int" } ". A constructor word " { $snippet "<type>" } " is defined for converting from integers to singletons. The generic word " { $link enum>number } " converts from singletons to integers. Enum-typed values are automatically prettyprinted as their singleton words. Unrecognizing enum numbers are kept as numbers." }
{ $examples
    "Here is an example enumeration definition:"
    { $code "ENUM: color_t red { green 3 } blue ;" }
    "The following expression returns true:"
    { $code "3 <color_t> [ green = ] [ enum>number 3 = ] bi and" }
} ;

HELP: C-TYPE:
{ $syntax "C-TYPE: type" }
{ $values { "type" "a new C type" } }
{ $description "Defines a new, opaque C type. Since it is opaque, " { $snippet "type" } " will not be directly usable as a parameter or return type of a " { $link POSTPONE: FUNCTION: } " or as a slot of a " { $link POSTPONE: STRUCT: } ". However, it can be used as the type of a " { $link pointer } "."
{ $snippet "C-TYPE:" } " can also be used to forward declare C types, allowing circular dependencies to occur between types. For example:"
{ $code """C-TYPE: forward 
STRUCT: backward { x forward* } ;
STRUCT: forward { x backward* } ; """ } }
{ $notes "Primitive C types are displayed using " { $snippet "C-TYPE:" } " syntax when they are " { $link see } "n." } ;

HELP: CALLBACK:
{ $syntax "CALLBACK: return type ( parameters ) ;" }
{ $values { "return" "a C return type" } { "type" "a type name" } { "parameters" "a comma-separated sequence of type/name pairs; " { $snippet "type1 arg1, type2 arg2, ..." } } }
{ $description "Defines a new function pointer C type word " { $snippet "type" } ". The newly defined word works both as a C type and as a wrapper for " { $link alien-callback } " for callbacks that accept the given return type and parameters. The ABI of the callback is decided from the ABI of the active " { $link POSTPONE: LIBRARY: } " declaration." }
{ $examples
    { $code
        "CALLBACK: bool FakeCallback ( int message, void* payload ) ;"
        ": MyFakeCallback ( -- alien )"
        "    [| message payload |"
        "        \"message #\" write"
        "        message number>string write"
        "        \" received\" write nl"
        "        t"
        "    ] FakeCallback ;"
    }
} ;

HELP: &:
{ $syntax "&: symbol" }
{ $values { "symbol" "A C global variable name" } }
{ $description "Pushes the address of a symbol named " { $snippet "symbol" } " from the current library, set with " { $link POSTPONE: LIBRARY: } "." } ;

HELP: typedef
{ $values { "old" "a C type" } { "new" "a C type" } }
{ $description "Aliases the C type " { $snippet "old" } " under the name " { $snippet "new" } "." }
{ $notes "Using this word in the same source file which defines C bindings can cause problems, because words are compiled before top-level forms are run. Use the " { $link POSTPONE: TYPEDEF: } " word instead." } ;

{ POSTPONE: TYPEDEF: typedef } related-words

HELP: c-struct?
{ $values { "c-type" "a C type" } { "?" "a boolean" } }
{ $description "Tests if a C type is a structure defined by " { $link POSTPONE: STRUCT: } "." } ;

HELP: C-GLOBAL:
{ $syntax "C-GLOBAL: type name" }
{ $values { "type" "a C type" } { "name" "a C global variable name" } }
{ $description "Defines a new word named " { $snippet "name" } " which accesses a global variable in the current library, set with " { $link POSTPONE: LIBRARY: } "." } ;
