IN: tools.errors
USING: help.markup help.syntax source-files.errors words io
compiler.errors ;

ARTICLE: "compiler-errors" "Compiler errors"
"After loading a vocabulary, you might see a message like:"
{ $code
    ":errors - print 2 compiler errors"
}
"This indicates that some words did not pass the stack checker. Stack checker error conditions are documented in " { $link "inference-errors" } ", and the stack checker itself in " { $link "inference" } "."
$nl
"Words to view errors:"
{ $subsection :errors }
{ $subsection :linkage }
"Compiler errors are reported using the " { $link "tools.errors" } " mechanism, and as a result, they are also are shown in the " { $link "ui.tools.error-list" } "." ;

HELP: compiler-error
{ $values { "error" compiler-error } { "word" word } }
{ $description "Saves the error for viewing with " { $link :errors } "." } ;

HELP: linkage-error
{ $values { "error" linkage-error } { "word" word } }
{ $description "Saves the error for viewing with " { $link :linkage } "." } ;

HELP: :errors
{ $description "Prints all compiler errors." } ;

HELP: :linkage
{ $description "Prints all C library interface linkage errors." } ;

{ :errors :linkage } related-words

HELP: errors.
{ $values { "errors" "a sequence of " { $link source-file-error } " instances" } }
{ $description "Prints a list of errors, grouped by source file." } ;

ARTICLE: "tools.errors" "Batch error reporting"
"Some tools, such as the " { $link "compiler" } ", " { $link "tools.test" } " and " { $link "help.lint" } " need to report multiple errors at a time. Each error is associated with a source file, line number, and optionally, a definition. " { $link "errors" } " cannot be used for this purpose, so the " { $vocab-link "source-files.errors" } " vocabulary provides an alternative mechanism. Note that the words in this vocabulary are used for implementation only; to actually list errors, consult the documentation for the relevant tools."
$nl
"Source file errors inherit from a class:"
{ $subsection source-file-error }
"Printing an error summary:"
{ $subsection error-summary }
"Printing a list of errors:"
{ $subsection errors. }
"Batch errors are reported in the " { $link "ui.tools.error-list" } "." ;

ABOUT: "tools.errors"