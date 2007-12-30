USING: generator help.markup help.syntax words io parser
assocs words.private sequences ;
IN: compiler

ARTICLE: "compiler-usage" "Calling the optimizing compiler"
"The main entry points to the optimizing compiler:"
{ $subsection compile }
{ $subsection recompile }
{ $subsection recompile-all }
"Removing a word's optimized definition:"
{ $subsection decompile }
"The optimizing compiler can also compile and call a single quotation:"
{ $subsection compile-call } ;

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

HELP: compile
{ $values { "seq" "a sequence of words" } }
{ $description "Compiles a set of words. Ignores words which are already compiled." } ;

HELP: recompile
{ $values { "seq" "a sequence of words" } }
{ $description "Compiles a set of words. Re-compiles words which are already compiled." } ;

HELP: compile-call
{ $values { "quot" "a quotation" } }
{ $description "Compiles and runs a quotation." }
{ $errors "Throws an error if the stack effect of the quotation cannot be inferred." } ;

HELP: recompile-all
{ $description "Recompiles all words." } ;

HELP: decompile
{ $values { "word" word } }
{ $description "Removes a word's optimized definition. The word will be compiled with the non-optimizing compiler until recompiled with the optimizing compiler again." } ;

HELP: (compile)
{ $values { "word" word } }
{ $description "Compile a single word." }
{ $notes "This is an internal word, and user code should call " { $link compile } " instead." } ;
