USING: help.syntax help.markup words ;
IN: descriptive

HELP: DESCRIPTIVE:
{ $syntax "DESCRIPTIVE: word ( inputs -- outputs ) definition ;" }
{ $description "Defines a word such that, if an error is thrown from within it, that error is wrapped in a " { $link descriptive-error } " with the arguments to that word." } ;

HELP: DESCRIPTIVE::
{ $syntax "DESCRIPTIVE:: word ( inputs -- outputs ) definition ;" }
{ $description "Defines a word which uses locals such that, if an error is thrown from within it, that error is wrapped in a " { $link descriptive-error } " with the arguments to that word." } ;

HELP: descriptive-error
{ $error-description "The class of errors wrapping another error (in the underlying slot) which were thrown in a word (in the word slot) with a given set of arguments (in the args slot)." } ;

HELP: make-descriptive
{ $values { "word" word } }
{ $description "Makes the word wrap errors in " { $link descriptive-error } " instances." } ;

ARTICLE: "descriptive" "Descriptive errors"
"This vocabulary defines automatic descriptive errors. Using it, you can define a word which acts as normal, except when it throws an error, the error is wrapped in an instance of a class:"
{ $subsection descriptive-error }
"The wrapper contains the word itself, the input parameters, as well as the original error."
$nl
"To annotate an existing word with descriptive error checking:"
{ $subsection make-descriptive }
"To define words which throw descriptive errors, use the following words:"
{ $subsection POSTPONE: DESCRIPTIVE: }
{ $subsection POSTPONE: DESCRIPTIVE:: } ;

ABOUT: "descriptive"
