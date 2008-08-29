USING: help.markup help.syntax quotations kernel ;
IN: macros

HELP: MACRO:
{ $syntax "MACRO: word ( inputs... -- ) definition... ;" }
{ $description "Defines a compile-time code transformation. If all inputs to the word are literal and the word calling the macro has a static stack effect, then the macro body is invoked at compile-time to produce a quotation; this quotation is then spliced into the compiled code. If the inputs are not literal, or if the word is invoked from a word which does not have a static stack effect, the macro body will execute every time and the result will be passed to " { $link call } "."
$nl
"The stack effect declaration must be present because it tells the compiler how many literal inputs to expect."
}
{ $notes
    "Semantically, the following two definitions are equivalent:"
    { $code "MACRO: foo ... ;" }
    { $code ": foo ... call ;" }
    "However, the compiler folds in macro definitions at compile-time where possible; if the macro body performs an expensive calculation, it can lead to a performance boost."
} ;

HELP: macro
{ $class-description "Class of words defined with " { $link POSTPONE: MACRO: } "." } ;

ARTICLE: "macros" "Macros"
"The " { $vocab-link "macros" } " vocabulary implements macros in the Lisp sense; compile-time code transformers and generators. Macros can be used to calculate lookup tables and generate code at compile time, which can improve performance, the level of abstraction and simplify code."
$nl
"Defining new macros:"
{ $subsection POSTPONE: MACRO: }
"Macros are really just a very thin layer of syntax sugar over " { $link "compiler-transforms" } "." ;

ABOUT: "macros"
