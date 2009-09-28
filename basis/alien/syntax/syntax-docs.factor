IN: alien.syntax
USING: alien alien.c-types alien.parser classes.struct help.markup help.syntax see ;

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
{ $subsection POSTPONE: ALIEN: }
{ $subsection POSTPONE: DLL" } ;

HELP: LIBRARY:
{ $syntax "LIBRARY: name" }
{ $values { "name" "a logical library name" } }
{ $description "Sets the logical library for consequent " { $link POSTPONE: FUNCTION: } " definitions that follow." } ;

HELP: FUNCTION:
{ $syntax "FUNCTION: return name ( parameters )" }
{ $values { "return" "a C return type" } { "name" "a C function name" } { "parameters" "a comma-separated sequence of type/name pairs; " { $snippet "type1 arg1, type2 arg2, ..." } } }
{ $description "Defines a new word " { $snippet "name" } " which calls a C library function with the same name, in the logical library given by the most recent " { $link POSTPONE: LIBRARY: } " declaration."
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
    "LIBRARY: foo\nFUNCTION: void the_answer ( char* question, int value ) ;"
    "USE: compiler"
    "\"the question\" 42 the_answer"
    "The answer to the question is 42."
} }
{ $notes "Note that the parentheses and commas are only syntax sugar and can be omitted; they serve no purpose other than to make the declaration slightly easier to read:"
{ $code
    "FUNCTION: void glHint ( GLenum target, GLenum mode ) ;"
    "FUNCTION: void glHint GLenum target GLenum mode ;"
} } ;

HELP: TYPEDEF:
{ $syntax "TYPEDEF: old new" }
{ $values { "old" "a C type" } { "new" "a C type" } }
{ $description "Aliases the C type " { $snippet "old" } " under the name " { $snippet "new" } " if ." }
{ $notes "This word differs from " { $link typedef } " in that it runs at parse time, to ensure correct ordering of operations when loading source files. Words defined in source files are compiled before top-level forms are run, so if a source file defines C binding words and uses " { $link typedef } ", the type alias won't be available at compile time." } ;

HELP: C-ENUM:
{ $syntax "C-ENUM: words... ;" }
{ $values { "words" "a sequence of word names" } }
{ $description "Creates a sequence of word definitions in the current vocabulary. Each word pushes an integer according to its index in the enumeration definition. The first word pushes 0." }
{ $notes "This word emulates a C-style " { $snippet "enum" } " in Factor. While this feature can be used for any purpose, using integer constants is discouraged unless it is for interfacing with C libraries. Factor code should use " { $link "words.symbol" } " or " { $link "singletons" } " instead." }
{ $examples
    "Here is an example enumeration definition:"
    { $code "C-ENUM: red green blue ;" }
    "It is equivalent to the following series of definitions:"
    { $code "CONSTANT: red 0" "CONSTANT: green 1" "CONSTANT: blue 2" }
} ;

HELP: C-TYPE:
{ $syntax "C-TYPE: type" }
{ $values { "type" "a new C type" } }
{ $description "Defines a new, opaque C type. Since it is opaque, " { $snippet "type" } " will not be directly usable as a parameter or return type of a " { $link POSTPONE: FUNCTION: } " or as a slot of a " { $link POSTPONE: STRUCT: } ". However, it can be used as the type of a pointer (that is, as " { $snippet "type*" } ")." $nl
{ $snippet "C-TYPE:" } " can also be used to forward-declare C types to enable circular dependencies. For example:"
{ $code """C-TYPE: forward 
STRUCT: backward { x forward* } ;
STRUCT: forward { x backward* } ; """ } }
{ $notes "Primitive C types are also displayed using " { $snippet "C-TYPE:" } " syntax when they are displayed by " { $link see } "." } ;

HELP: CALLBACK:
{ $syntax "CALLBACK: return type ( parameters ) ;" }
{ $values { "return" "a C return type" } { "type" "a type name" } { "parameters" "a comma-separated sequence of type/name pairs; " { $snippet "type1 arg1, type2 arg2, ..." } } }
{ $description "Defines a new function pointer C type word " { $snippet "type" } ". The newly defined word works both as a C type and as a wrapper for " { $link alien-callback } " for callbacks that accept the given return type and parameters with the " { $snippet "\"cdecl\"" } " ABI." }
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

HELP: STDCALL-CALLBACK:
{ $syntax "STDCALL-CALLBACK: return type ( parameters ) ;" }
{ $values { "return" "a C return type" } { "type" "a type name" } { "parameters" "a comma-separated sequence of type/name pairs; " { $snippet "type1 arg1, type2 arg2, ..." } } }
{ $description "Defines a new function pointer C type word " { $snippet "type" } ". The newly defined word works both as a C type and as a wrapper for " { $link alien-callback } " for callbacks that accept the given return type and parameters with the " { $snippet "\"stdcall\"" } " ABI." }
{ $examples
    { $code
        "STDCALL-CALLBACK: bool FakeCallback ( int message, void* payload ) ;"
        ": MyFakeCallback ( -- alien )"
        "    [| message payload |"
        "        \"message #\" write"
        "        message number>string write"
        "        \" received\" write nl"
        "        t"
        "    ] FakeCallback ;"
    }
} ;

{ POSTPONE: CALLBACK: POSTPONE: STDCALL-CALLBACK: } related-words 

HELP: &:
{ $syntax "&: symbol" }
{ $values { "symbol" "A C library symbol name" } }
{ $description "Pushes the address of a symbol named " { $snippet "symbol" } " from the current library, set with " { $link POSTPONE: LIBRARY: } "." } ;

HELP: typedef
{ $values { "old" "a string" } { "new" "a string" } }
{ $description "Aliases the C type " { $snippet "old" } " under the name " { $snippet "new" } "." }
{ $notes "Using this word in the same source file which defines C bindings can cause problems, because words are compiled before top-level forms are run. Use the " { $link POSTPONE: TYPEDEF: } " word instead." } ;

{ POSTPONE: TYPEDEF: typedef } related-words

HELP: c-struct?
{ $values { "c-type" "a C type name" } { "?" "a boolean" } }
{ $description "Tests if a C type is a structure defined by " { $link POSTPONE: STRUCT: } "." } ;

HELP: define-function
{ $values { "return" "a C return type" } { "library" "a logical library name" } { "function" "a C function name" } { "parameters" "a sequence of C parameter types" } }
{ $description "Defines a word named " { $snippet "function" } " in the current vocabulary (see " { $link "vocabularies" } "). The word calls " { $link alien-invoke } " with the specified parameters." }
{ $notes "This word is used to implement the " { $link POSTPONE: FUNCTION: } " parsing word." } ;
