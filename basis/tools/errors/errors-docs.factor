IN: tools.errors
USING: help.markup help.syntax source-files.errors ;

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