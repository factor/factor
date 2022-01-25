USING: help.markup help.syntax kernel
stack-checker.transforms combinators ;
IN: macros

HELP: MACRO:
{ $syntax "MACRO: word ( inputs... -- quot ) definition... ;" }
{ $description "Defines a macro word. The definition must have stack effect " { $snippet "( inputs... -- quot )" } "." }
{ $notes
  "A call of a macro inside a word definition is replaced with the quotation expansion at compile-time. The following two conditions must hold:"
  { $list
    { "All inputs to the macro call must be literals" }
    { "The expansion quotation produced by the macro has a static stack effect" }
  }
  "Macros allow computation to be moved from run-time to compile-time, splicing the result of this computation into the generated quotation."
}
{ $examples
  "A macro that calls a quotation but preserves any values it consumes off the stack:"
  { $code
    "USING: fry generalizations kernel macros stack-checker ;"
    "MACRO: preserving ( quot -- quot' )"
    "    [ inputs ] keep '[ _ ndup @ ] ;"
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
"Macros can be used to implement combinators whose stack effects depend on an input parameter. Since macros are expanded at compile time, this permits the compiler to infer a static stack effect for the word calling the macro."
$nl
"Macros can also be used to calculate lookup tables and generate code at compile time, which can improve performance, raise the level of abstraction, and simplify code."
$nl
"Factor macros are similar to Lisp macros; they are not like C preprocessor macros."
$nl
"Defining new macros:"
{ $subsections POSTPONE: MACRO: }
"A slightly lower-level facility, " { $emphasis "compiler transforms" } ", allows an ordinary word definition to co-exist with a version that performs compile-time expansion. The ordinary definition is only used from code compiled with the non-optimizing compiler. Under normal circumstances, macros should be used instead of compiler transforms; compiler transforms are only used for words such as " { $link cond } " which are frequently invoked during the bootstrap process, and this having a performant non-optimized definition which does not generate code on the fly is important."
{ $subsections define-transform }
{ $see-also "generalizations" "fry" } ;

ABOUT: "macros"
