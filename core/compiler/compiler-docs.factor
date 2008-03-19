USING: generator help.markup help.syntax words io parser
assocs words.private sequences compiler.units ;
IN: compiler

ARTICLE: "compiler-usage" "Calling the optimizing compiler"
"Normally, new word definitions are recompiled automatically, however in some circumstances the optimizing compiler may need to be called directly."
$nl
"The main entry point to the optimizing compiler:"
{ $subsection optimized-recompile-hook }
"Removing a word's optimized definition:"
{ $subsection decompile } ;

ARTICLE: "compiler" "Optimizing compiler"
"Factor is a fully compiled language implementation with two distinct compilers:"
{ $list
    { "The " { $emphasis "non-optimizing quotation compiler" } " compiles quotations to naive machine code very quickly. The non-optimizing quotation compiler is part of the VM." }
    { "The " { $emphasis "optimizing word compiler" } " compiles whole words at a time while performing extensive data and control flow analysis. This provides greater performance for generated code, but incurs a much longer compile time. The optimizing compiler is written in Factor." }
}
"The optimizing compiler only compiles words which have a static stack effect. This means that methods defined on fundamental generic words such as " { $link nth } " should have a static stack effect; for otherwise, most of the system would be compiled with the non-optimizing compiler. See " { $link "inference" } " and " { $link "cookbook-pitfalls" } "."
{ $subsection "compiler-usage" }
{ $subsection "compiler-errors" } ;

ABOUT: "compiler"

HELP: decompile
{ $values { "word" word } }
{ $description "Removes a word's optimized definition. The word will be compiled with the non-optimizing compiler until recompiled with the optimizing compiler again." } ;

HELP: (compile)
{ $values { "word" word } }
{ $description "Compile a single word." }
{ $notes "This is an internal word, and user code should call " { $link compile } " instead." } ;

HELP: optimized-recompile-hook
{ $values { "words" "a sequence of words" } { "alist" "an association list" } }
{ $description "Compile a set of words." }
{ $notes "This is an internal word, and user code should call " { $link compile } " instead." } ;
