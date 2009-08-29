IN: alien.syntax
USING: alien alien.c-types alien.parser alien.structs
classes.struct help.markup help.syntax ;

HELP: DLL"
{ $syntax "DLL\" path\"" }
{ $values { "path" "a pathname string" } }
{ $description "Constructs a DLL handle at parse time." } ;

HELP: ALIEN:
{ $syntax "ALIEN: address" }
{ $values { "address" "a non-negative integer" } }
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

HELP: C-STRUCT:
{ $deprecated "New code should use " { $link "classes.struct" } ". See the " { $link POSTPONE: STRUCT: } " word." }
{ $syntax "C-STRUCT: name pairs... ;" }
{ $values { "name" "a new C type name" } { "pairs" "C type / field name string pairs" } }
{ $description "Defines a C struct layout and accessor words." }
{ $notes "C type names are documented in " { $link "c-types-specs" } "." } ;

HELP: C-UNION:
{ $deprecated "New code should use " { $link "classes.struct" } ". See the " { $link POSTPONE: UNION-STRUCT: } " word." }
{ $syntax "C-UNION: name members... ;" }
{ $values { "name" "a new C type name" } { "members" "a sequence of C types" } }
{ $description "Defines a new C type sized to fit its largest member." }
{ $notes "C type names are documented in " { $link "c-types-specs" } "." }
{ $examples { $code "C-UNION: event \"active-event\" \"keyboard-event\" \"mouse-event\" ;" } } ;

HELP: C-ENUM:
{ $syntax "C-ENUM: words... ;" }
{ $values { "words" "a sequence of word names" } }
{ $description "Creates a sequence of word definitions in the current vocabulary. Each word pushes an integer according to its index in the enumeration definition. The first word pushes 0." }
{ $notes "This word emulates a C-style " { $snippet "enum" } " in Factor. While this feature can be used for any purpose, using integer constants is discouraged unless it is for interfacing with C libraries. Factor code should use symbolic constants instead." }
{ $examples
    "The following two lines are equivalent:"
    { $code "C-ENUM: red green blue ;" ": red 0 ;  : green 1 ;  : blue 2 ;" }
} ;

HELP: &:
{ $syntax "&: symbol" }
{ $values { "symbol" "A C library symbol name" } }
{ $description "Pushes the address of a symbol named " { $snippet "symbol" } " from the current library, set with " { $link POSTPONE: LIBRARY: } "." } ;

HELP: typedef
{ $values { "old" "a string" } { "new" "a string" } }
{ $description "Alises the C type " { $snippet "old" } " under the name " { $snippet "new" } "." }
{ $notes "Using this word in the same source file which defines C bindings can cause problems, because words are compiled before top-level forms are run. Use the " { $link POSTPONE: TYPEDEF: } " word instead." } ;

{ POSTPONE: TYPEDEF: typedef } related-words

HELP: c-struct?
{ $values { "type" "a string" } { "?" "a boolean" } }
{ $description "Tests if a C type is a structure defined by " { $link POSTPONE: C-STRUCT: } "." } ;

HELP: define-function
{ $values { "return" "a C return type" } { "library" "a logical library name" } { "function" "a C function name" } { "parameters" "a sequence of C parameter types" } }
{ $description "Defines a word named " { $snippet "function" } " in the current vocabulary (see " { $link "vocabularies" } "). The word calls " { $link alien-invoke } " with the specified parameters." }
{ $notes "This word is used to implement the " { $link POSTPONE: FUNCTION: } " parsing word." } ;
