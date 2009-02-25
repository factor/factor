USING: help.markup help.syntax words io parser
assocs words.private sequences compiler.units quotations ;
IN: compiler

HELP: enable-compiler
{ $description "Enables the optimizing compiler." } ;

HELP: disable-compiler
{ $description "Disable the optimizing compiler." } ;

ARTICLE: "compiler-usage" "Calling the optimizing compiler"
"Normally, new word definitions are recompiled automatically. This can be changed:"
{ $subsection disable-compiler }
{ $subsection enable-compiler }
"The optimizing compiler can be called directly, although this should not be necessary under normal circumstances:"
{ $subsection optimized-recompile-hook }
"Removing a word's optimized definition:"
{ $subsection decompile }
"Compiling a single quotation:"
{ $subsection compile-call }
"Higher-level words can be found in " { $link "compilation-units" } "." ;

ARTICLE: "compiler" "Optimizing compiler"
"Factor includes two compilers which work behind the scenes. Words are always compiled, and the compilers do not have to be invoked explicitly. For the most part, compilation is fully transparent. However, there are a few things worth knowing about the compilation process."
$nl
"The two compilers differ in the level of analysis they perform:"
{ $list
    { "The " { $emphasis "non-optimizing quotation compiler" } " compiles quotations to naive machine code very quickly. The non-optimizing quotation compiler is part of the VM." }
    { "The " { $emphasis "optimizing word compiler" } " compiles whole words at a time while performing extensive data and control flow analysis. This provides greater performance for generated code, but incurs a much longer compile time. The optimizing compiler is written in Factor." }
}
"The optimizing compiler only compiles words which have a static stack effect. This means that methods defined on fundamental generic words such as " { $link nth } " should have a static stack effect. See " { $link "inference" } " and " { $link "cookbook-pitfalls" } "."
$nl
"The optimizing compiler also trades off compile time for performance of generated code, so loading certain vocabularies might take a while. Saving the image after loading vocabularies can save you a lot of time that you would spend waiting for the same code to load in every coding session; see " { $link "images" } " for information."
{ $subsection "compiler-errors" }
{ $subsection "hints" }
{ $subsection "compiler-usage" } ;

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

HELP: compile-call
{ $values { "quot" quotation } }
{ $description "Compiles and runs a quotation." }
{ $notes "This word is used by compiler unit tests to test compilation of small pieces of code." } ;
