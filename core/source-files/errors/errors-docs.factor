USING: help.markup help.syntax sequences ;
IN: source-files.errors

HELP: error-type-holder
{ $description "A definition of a class of errors"
  $nl
  "Instances contain the following slots:"
  { $slots
    { "type" { "symbol representing the error type." } }
    { "word" { "name of the word that lists all errors of this error type." } }
    { "plural" { "pluralized description of this error type." } }
    { "icon" { "path to an icon image representing this error type." } }
    { "quot" { "quotation that produces a list of all errors of this type." } }
    { "forget-quot" { "a quotation that removes errors of this type for a given word." } }
    { "fatal?" { "whether the error is fatal or not. default " { $link t } "." } }
  }
} ;

HELP: error-counts
{ $values { "alist" "error types and counts" } }
{ $description "Outputs an alist of error types and counts of the number of errors of that type. Only fatal errors and counts > 0 are included." } ;

HELP: define-error-type
{ $values { "error-type" error-type-holder } }
{ $description "Registers a new error type." } ;

HELP: all-errors
{ $values { "errors" sequence } }
{ $description "Lists all errors in the system." } ;

HELP: error-file
{ $values { "error" "an error" } { "file" "a file path" } }
{ $description "File in which the error occurred." } ;

HELP: new-source-file-error
{ $values
  { "error" "an error" }
  { "asset" "an asset that contains the error" }
  { "class" "a tuple class deriving source-file-error" }
  { "source-file-error" source-file-error }
}
{ $description "Creates a new " { $link source-file-error } " instance." } ;
