USING: assocs compiler.cfg.builder compiler.cfg.optimizer
compiler.errors compiler.tree.builder compiler.tree.optimizer
compiler.units help.markup help.syntax io parser quotations
sequences words ;
IN: compiler

HELP: enable-optimizer
{ $description "Enables the optimizing compiler." } ;

HELP: disable-optimizer
{ $description "Disable the optimizing compiler." } ;

ARTICLE: "compiler-usage" "Calling the optimizing compiler"
"Normally, new word definitions are recompiled automatically. This can be changed:"
{ $subsection disable-optimizer }
{ $subsection enable-optimizer }
"Removing a word's optimized definition:"
{ $subsection decompile }
"Compiling a single quotation:"
{ $subsection compile-call }
"Higher-level words can be found in " { $link "compilation-units" } "." ;

ARTICLE: "compiler-impl" "Compiler implementation"
"The " { $vocab-link "compiler" } "vocabulary, in addition to providing the user-visible words of the compiler, implements the main compilation loop."
$nl
"Words are added to the " { $link compile-queue } " variable as needed and compiled."
{ $subsection compile-queue }
"Once compiled, a word is added to the assoc stored in the " { $link compiled } " variable. When compilation is complete, this assoc is passed to " { $link modify-code-heap } "."
$nl
"The " { $link compile-word } " word performs the actual task of compiling an individual word. The process proceeds as follows:"
{ $list
  { "The " { $link frontend } " word calls " { $link build-tree } ". If this fails, the error is passed to " { $link deoptimize } ". The logic for ignoring certain compile errors generated for inline words and macros is located here. If the error is not ignorable, it is added to the global " { $link compiler-errors } " assoc (see " { $link "compiler-errors" } ")." }
  { "If the word contains a breakpoint, compilation ends here. Otherwise, all remaining steps execute until machine code is generated. Any further errors thrown by the compiler are not reported as compile errors, but instead are ordinary exceptions. This is because they indicate bugs in the compiler, not errors in user code." }
  { "The " { $link frontend } " word then calls " { $link optimize-tree } ". This produces the final optimized tree IR, and this stage of the compiler is complete." }
  { "The " { $link backend } " word calls " { $link build-cfg } " followed by " { $link optimize-cfg } " and a few other stages. Finally, it calls " { $link save-asm } ", and adds any uncompiled words called by this word to the compilation queue with " { $link compile-dependency } "." }
}
"If compilation fails, the word is stored in the " { $link compiled } " assoc with a value of " { $link f } ". This causes the VM to compile the word with the non-optimizing compiler."
$nl
"Calling " { $link modify-code-heap } " is handled not by the " { $vocab-link "compiler" } " vocabulary, but rather " { $vocab-link "compiler.units" } ". The optimizing compiler merely provides an implementation of the " { $link recompile } " generic word." ;

ARTICLE: "compiler" "Optimizing compiler"
"Factor includes two compilers which work behind the scenes. Words are always compiled, and the compilers do not have to be invoked explicitly. For the most part, compilation is fully transparent. However, there are a few things worth knowing about the compilation process."
$nl
"The two compilers differ in the level of analysis they perform:"
{ $list
    { "The " { $emphasis "non-optimizing quotation compiler" } " compiles quotations to naive machine code very quickly. The non-optimizing quotation compiler is part of the VM." }
    { "The " { $emphasis "optimizing word compiler" } " compiles whole words at a time while performing extensive data and control flow analysis. This provides greater performance for generated code, but incurs a much longer compile time. The optimizing compiler is written in Factor." }
}
"The optimizing compiler also trades off compile time for performance of generated code, so loading certain vocabularies might take a while. Saving the image after loading vocabularies can save you a lot of time that you would spend waiting for the same code to load in every coding session; see " { $link "images" } " for information."
$nl
"Most code you write will run with the optimizing compiler. Sometimes, the non-optimizing compiler is used, for example for listener interactions, or for running the quotation passed to " { $link POSTPONE: call( } "."
{ $subsection "compiler-errors" }
{ $subsection "hints" }
{ $subsection "compiler-usage" }
{ $subsection "compiler-impl" } ;

ABOUT: "compiler"

HELP: decompile
{ $values { "word" word } }
{ $description "Removes a word's optimized definition. The word will be compiled with the non-optimizing compiler until recompiled with the optimizing compiler again." } ;

HELP: compile-word
{ $values { "word" word } }
{ $description "Compile a single word." }
{ $notes "This is an internal word, and user code should call " { $link compile } " instead." } ;

HELP: optimizing-compiler
{ $description "Singleton class implementing " { $link recompile } " to call the optimizing compiler." }
{ $notes "This is an internal word, and user code should call " { $link compile } " instead." } ;

HELP: compile-call
{ $values { "quot" quotation } }
{ $description "Compiles and runs a quotation." }
{ $notes "This word is used by compiler unit tests to test compilation of small pieces of code." } ;
