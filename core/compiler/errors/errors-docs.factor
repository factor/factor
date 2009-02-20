IN: compiler.errors
USING: help.markup help.syntax vocabs.loader words io
quotations words.symbol ;

ARTICLE: "compiler-errors" "Compiler warnings and errors"
"After loading a vocabulary, you might see messages like:"
{ $code
    ":errors - print 2 compiler errors."
    ":warnings - print 50 compiler warnings."
}
"These warnings arise from the compiler's stack effect checker. Warnings are non-fatal conditions -- not all code has a static stack effect, so you try to minimize warnings but understand that in many cases they cannot be eliminated. Errors indicate programming mistakes, such as erroneous stack effect declarations."
$nl
"The precise warning and error conditions are documented in " { $link "inference-errors" } "."
$nl
"Words to view warnings and errors:"
{ $subsection :errors }
{ $subsection :warnings }
{ $subsection :linkage }
"Words such as " { $link require } " use a combinator which counts errors and prints a report at the end:"
{ $subsection with-compiler-errors } ;

HELP: compiler-errors
{ $var-description "Global variable holding an assoc mapping words to compiler errors. This variable is set by " { $link with-compiler-errors } "." } ;

ABOUT: "compiler-errors"

HELP: compiler-error
{ $values { "error" "an error" } { "word" word } }
{ $description "If inside a " { $link with-compiler-errors } ", saves the error for future persual via " { $link :errors } ", " { $link :warnings } " and " { $link :linkage } ". If not inside a " { $link with-compiler-errors } ", ignores the error." } ;

HELP: compiler-error.
{ $values { "error" "an error" } { "word" word } }
{ $description "Prints a compiler error to " { $link output-stream } "." } ;

HELP: compiler-errors.
{ $values { "type" symbol } }
{ $description "Prints compiler errors to " { $link output-stream } ". The type parameter is one of " { $link +error+ } ", " { $link +warning+ } ", or " { $link +linkage+ } "." } ;
HELP: :errors
{ $description "Prints all serious compiler errors from the most recent compile to " { $link output-stream } "." } ;

HELP: :warnings
{ $description "Prints all ignorable compiler warnings from the most recent compile to " { $link output-stream } "." } ;

HELP: :linkage
{ $description "Prints all C library interface linkage errors from the most recent compile to " { $link output-stream } "." } ;

{ :errors :warnings } related-words

HELP: with-compiler-errors
{ $values { "quot" quotation } }
{ $description "Calls the quotation and collects any compiler warnings and errors. Compiler warnings and errors are summarized at the end and can be viewed with " { $link :errors } ", " { $link :warnings } ", and " { $link :linkage } "." }
{ $notes "Nested calls to " { $link with-compiler-errors } " are ignored, and only the outermost call collects warnings and errors." } ;
