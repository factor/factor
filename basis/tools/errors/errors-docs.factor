IN: tools.errors
USING: compiler.errors tools.errors help.markup help.syntax vocabs.loader
words quotations io ;

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
{ $subsection :linkage } ;

HELP: compiler-error
{ $values { "error" "an error" } { "word" word } }
{ $description "Saves the error for future persual via " { $link :errors } ", " { $link :warnings } " and " { $link :linkage } "." } ;

HELP: :errors
{ $description "Prints all serious compiler errors from the most recent compile to " { $link output-stream } "." } ;

HELP: :warnings
{ $description "Prints all ignorable compiler warnings from the most recent compile to " { $link output-stream } "." } ;

HELP: :linkage
{ $description "Prints all C library interface linkage errors from the most recent compile to " { $link output-stream } "." } ;

{ :errors :warnings } related-words
