USING: generator help.markup help.syntax words io parser
assocs words.private sequences ;
IN: compiler

ARTICLE: "compiler-usage" "Calling the optimizing compiler"
"The main entry point to the optimizing compiler is a single word taking a word as input:"
{ $subsection compile }
"The above word throws an error if the word did not compile. Another variant simply prints the error and returns:"
{ $subsection try-compile }
"The optimizing compiler can also compile a single quotation:"
{ $subsection compile-quot }
{ $subsection compile-1 }
"Three utility words for bulk compilation:"
{ $subsection compile-batch }
{ $subsection compile-vocabs }
{ $subsection compile-all }
"Bulk compilation saves compile warnings and errors in a global variable, instead of printing them as they arise:"
{ $subsection compile-errors }
"The warnings and errors can be viewed later:"
{ $subsection :warnings }
{ $subsection :errors }
{ $subsection forget-errors } ;

ARTICLE: "recompile" "Automatic recompilation"
"When a word is redefined, you can recompile all affected words automatically:"
{ $subsection recompile }
"Normally loading a source file or a module also calls " { $link recompile } ". This can be disabled by wrapping file loading in a combinator:"
{ $subsection no-parse-hook } ;

ARTICLE: "compiler" "Optimizing compiler"
"Factor is a fully compiled language implementation with two distinct compilers:"
{ $list
    { "The " { $emphasis "non-optimizing quotation compiler" } " compiles quotations to naive machine code very quickly. The non-optimizing quotation compiler is part of the VM." }
    { "The " { $emphasis "optimizing word compiler" } " compiles whole words at a time while performing extensive data and control flow analysis. This provides greater performance for generated code, but incurs a much longer compile time. The optimizing compiler is written in Factor." }
}
"While the quotation compiler is transparent to the developer, the optimizing compiler is invoked explicitly. It differs in two important ways from the non-optimizing compiler:"
{ $list
    { "The optimizing compiler only compiles words which have a static stack effect. This means that methods defined on fundamental generic words such as " { $link nth } " should have a static stack effect; for otherwise, most of the system would be compiled with the non-optimizing compiler. See " { $link "inference" } " and " { $link "cookbook-pitfalls" } "." }
    { "The optimizing compiler performs " { $emphasis "early binding" } "; if a compiled word " { $snippet "A" } " calls another compiled word " { $snippet "B" } " and " { $snippet "B" } " is subsequently redefined, the compiled definition of " { $snippet "A" } " will still refer to the earlier compiled definition of " { $snippet "B" } ", until " { $snippet "A" } " explicitly recompiled." }
}
{ $subsection "compiler-usage" }
{ $subsection "recompile" } ;

ABOUT: "compiler"

HELP: compile-error
{ $values { "word" word } { "error" "an error" } }
{ $description "If inside a " { $link compile-batch } ", saves the error for future persual via " { $link :errors } " and " { $link :warnings } ", otherwise reports the error to the " { $link stdio } " stream." } ;

HELP: begin-batch
{ $values { "seq" "a sequence of words" } }
{ $description "Begins batch compilation. Any compile errors reported until a call to " { $link end-batch } " are stored in the " { $link compile-errors } " global variable." }
$low-level-note ;

HELP: compile-error.
{ $values { "pair" "a " { $snippet "{ word error }" } " pair" } }
{ $description "Prints a compiler error to the " { $link stdio } " stream." } ;

HELP: (:errors)
{ $values { "seq" "an alist" } }
{ $description "Outputs all serious compiler errors from the most recent compile batch as a sequence of " { $snippet "{ word error }" } " pairs."  } ;

HELP: :errors
{ $description "Prints all serious compiler errors from the most recent compile batch to the " { $link stdio } " stream." } ;

HELP: (:warnings)
{ $values { "seq" "an alist" } }
{ $description "Outputs all ignorable compiler warnings from the most recent compile batch as a sequence of " { $snippet "{ word error }" } " pairs."  } ;

HELP: :warnings
{ $description "Prints all ignorable compiler warnings from the most recent compile batch to the " { $link stdio } " stream." } ;

HELP: end-batch
{ $description "Ends batch compilation, printing a summary of the errors and warnings produced to the " { $link stdio } " stream." }
$low-level-note ;

HELP: compile
{ $values { "word" word } }
{ $description "Compiles a word together with any uncompiled dependencies. Does nothing if the word is already compiled." }
{ $errors "If compilation fails, this word can throw an error. In particular, if the word's stack effect cannot be inferred, this word will throw an error. The related " { $link try-compile } " word logs errors and returns rather than throwing." } ;

HELP: compile-failed
{ $values { "word" word } { "error" "an error" } }
{ $description "Called when the optimizing compiler fails to compile a word. The word is removed from the set of words pending compilation, and it's un-optimized compiled definition will be used. The error is reported by calling " { $link compile-error } "." } ;

HELP: try-compile
{ $values { "word" word } }
{ $description "Compiles a word together with any uncompiled dependencies. Does nothing if the word is already compiled." }
{ $errors "If compilation fails, this calls " { $link compile-failed } "." } ;

HELP: forget-errors
{ $values { "seq" "a sequence of words" } }
{ $description "If any of the words in the sequence previously failed to compile, removes the marker indicating such."
$nl
"The compiler remembers which words failed to compile as an optimization, so that it does not try to infer the stack effect of words which do not have one over and over again." }
{ $notes "Usually this word does not need to be called directly; if a word failed to compile because of a stack effect error, fixing the word definition clears the flag automatically. However, if words failed to compile due to external factors which were subsequently rectified, such as an unavailable C library or a missing or broken compiler transform, this flag can be cleared for all words:"
{ $code "all-words forget-errors" }
"Subsequent invocations of the compiler will consider all words for compilation." } ;

HELP: compile-batch
{ $values { "seq" "a sequence of words" } }
{ $description "Compiles a batch of words. Any compile errors are summarized at the end and can be viewed with " { $link :warnings } " and " { $link :errors } "." } ;

{ :errors (:errors) :warnings (:warnings) } related-words

HELP: compile-vocabs
{ $values { "seq" "a sequence of strings" } }
{ $description "Compiles all words which have not been compiled yet from the given vocabularies." } ;

HELP: compile-quot
{ $values { "quot" "a quotation" } { "word" "a new, uninterned word" } }
{ $description "Creates a new uninterned word having the given quotation as its definition, and compiles it. The returned word can be passed to " { $link execute } "." }
{ $errors "Throws an error if the stack effect of the quotation cannot be inferred." } ;

HELP: compile-1
{ $values { "quot" "a quotation" } }
{ $description "Compiles and runs a quotation." }
{ $errors "Throws an error if the stack effect of the quotation cannot be inferred." } ;

HELP: recompile
{ $description "Recompiles words whose compiled definitions have become out of date as a result of dependent words being redefined." } ;

HELP: compile-all
{ $description "Compiles all words which have not been compiled yet." } ;

HELP: recompile-all
{ $description "Recompiles all words." } ;

HELP: changed-words
{ $var-description "Global variable holding words which need to be recompiled. Implemented as a hashtable where a key equals its value. This hashtable is updated by " { $link define } " when words are redefined, and inspected and cleared by " { $link recompile } "." } ;

HELP: compile-begins
{ $values { "word" word } }
{ $description "Prints a message stating the word is being compiled, unless we are inside a " { $link compile-batch } "." } ;

HELP: (compile)
{ $values { "word" word } }
{ $description "Compile a word. This word recursively calls itself to compile all dependencies." }
{ $notes "This is an internal word, and user code should call " { $link compile } " instead." } ;
