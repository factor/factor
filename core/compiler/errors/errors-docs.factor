IN: compiler.errors
USING: help.markup help.syntax vocabs.loader words io
quotations ;

ARTICLE: "compiler-errors" "Compiler warnings and errors"
"The compiler saves compile warnings and errors in a global variable:"
{ $subsection compiler-errors }
"The warnings and errors can be viewed later:"
{ $subsection :warnings }
{ $subsection :errors }
"Normally, all warnings and errors are displayed at the end of a batch compilation, such as a call to " { $link require } " or " { $link refresh-all } ". This can be controlled with a combinator:"
{ $link with-compiler-errors } ;

HELP: compiler-errors
{ $var-description "Global variable holding an assoc mapping words to compiler errors. This variable is set by " { $link with-compiler-errors } "." } ;

HELP: compiler-error
{ $values { "error" "an error" } { "word" word } }
{ $description "If inside a " { $link with-compiler-errors } ", saves the error for future persual via " { $link :errors } " and " { $link :warnings } ", otherwise ignores the error." } ;

HELP: compiler-error.
{ $values { "error" "an error" } { "word" word } }
{ $description "Prints a compiler error to the " { $link stdio } " stream." } ;

HELP: compiler-errors.
{ $values { "errors" "an assoc mapping words to errors" } }
{ $description "Prints a set of compiler errors to the " { $link stdio } " stream." } ;

HELP: (:errors)
{ $values { "seq" "an alist" } }
{ $description "Outputs all serious compiler errors from the most recent compile."  } ;

HELP: :errors
{ $description "Prints all serious compiler errors from the most recent compile to the " { $link stdio } " stream." } ;

HELP: (:warnings)
{ $values { "seq" "an alist" } }
{ $description "Outputs all ignorable compiler warnings from the most recent compile."  } ;

HELP: :warnings
{ $description "Prints all ignorable compiler warnings from the most recent compile to the " { $link stdio } " stream." } ;

{ :errors (:errors) :warnings (:warnings) } related-words

HELP: with-compiler-errors
{ $values { "quot" quotation } }
{ $description "Calls the quotation and collects any compiler warnings and errors. Compiler warnings and errors are summarized at the end and can be viewed with " { $link :warnings } " and " { $link :errors } "." }
{ $notes "Nested calls to " { $link with-compiler-errors } " are ignored, and only the outermost call collects warnings and errors." } ;
