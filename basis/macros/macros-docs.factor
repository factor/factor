USING: help.markup help.syntax quotations kernel
stack-checker.transforms sequences ;
IN: macros

HELP: MACRO:
{ $syntax "MACRO: word ( inputs... -- ) definition... ;" }
{ $description "Defines a code transformation. The definition must have stack effect " { $snippet "( inputs... -- quot )" } "." }
{ $notes
  "A call of a macro inside a word definition is replaced with the quotation expansion at compile-time if precisely the following conditions hold:"
  { $list
    { "All inputs to the macro call are literal" }
    { "The word calling the macro has a static stack effect" }
    { "The expansion quotation produced by the macro has a static stack effect" }
  }
  "If any of these conditions fail to hold, the macro will still work, but expansion will be performed at run-time."
  $nl
  "Other than possible compile-time expansion, the following two definition styles are equivalent:"
    { $code "MACRO: foo ... ;" }
    { $code ": foo ... call ;" }
  "Conceptually, macros allow computation to be moved from run-time to compile-time, splicing the result of this computation into the generated quotation."
}
{ $examples
  "A macro that calls a quotation but preserves any values it consumes off the stack:"
  { $code
    "USING: fry generalizations ;" 
    "MACRO: preserving ( quot -- )"
    "    [ infer in>> length ] keep '[ _ ndup @ ] ;"
  }
  "Using this macro, we can define a variant of " { $link if } " which takes a predicate quotation instead of a boolean; any values consumed by the predicate quotation are restored immediately after:"
  { $code
    ": ifte ( pred true false -- ) [ preserving ] 2dip if ; inline"
  }
  "Note that " { $snippet "ifte" } " is an ordinary word, and it passes one of its inputs to the macro. If another word calls " { $snippet "ifte" } " with all three input quotations literal, then " { $snippet "ifte" } " will be inlined and " { $snippet "preserving" } " will expand at compile-time, and the generated machine code will be exactly the same as if the inputs consumed by the predicate were duplicated by hand."
  $nl
  "The " { $snippet "ifte" } " combinator presented here has similar semantics to the " { $snippet "ifte" } " combinator of the Joy programming language."
} ;

HELP: macro
{ $class-description "Class of words defined with " { $link POSTPONE: MACRO: } "." } ;

ARTICLE: "macros" "Macros"
"The " { $vocab-link "macros" } " vocabulary implements " { $emphasis "macros" } ", which are code transformations that may run at compile-time under the right circumstances."
$nl
"Macros can be used to give static stack effects to combinators that otherwise would not have static stack effects. Macros can be used to calculate lookup tables and generate code at compile time, which can improve performance, the level of abstraction and simplify code."
$nl
"Factor macros are similar to Lisp macros; they are not like C preprocessor macros."
$nl
"Defining new macros:"
{ $subsection POSTPONE: MACRO: }
"A slightly lower-level facility, " { $emphasis "compiler transforms" } ", allows an ordinary word definition to co-exist with a version that performs compile-time expansion."
{ $subsection define-transform }
"An example is the " { $link member? } " word. If the input sequence is a literal, the compile transform kicks in and converts the " { $link member? } " call into a series of conditionals. Otherwise, if the input sequence is not literal, a call to the definition of " { $link member? } " is generated."
{ $see-also "generalizations" "fry" } ;

ABOUT: "macros"
