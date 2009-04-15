IN: compiler.errors
USING: help.markup help.syntax vocabs.loader words io
quotations words.symbol ;

ARTICLE: "compiler-errors" "Compiler warnings and errors"
"After loading a vocabulary, you might see messages like:"
{ $code
    ":errors - print 2 compiler errors"
    ":warnings - print 50 compiler warnings"
}
"These messages arise from the compiler's stack effect checker. Production code should not have any warnings and errors in it. Warning and error conditions are documented in " { $link "inference-errors" } "."
$nl
"Words to view warnings and errors:"
{ $subsection :warnings }
{ $subsection :errors }
{ $subsection :linkage }
"Compiler warnings and errors are reported using the " { $link "tools.errors" } " mechanism and are shown in the " { $link "ui.tools.error-list" } "." ;

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

ABOUT: "compiler-errors"
