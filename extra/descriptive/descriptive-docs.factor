USING: help.syntax help.markup ;
IN: descriptive

HELP: DESCRIPTIVE:
{ $syntax "DESCRIPTIVE: word ( inputs -- outputs ) definition ;" }
{ $description "Defines a word such that, if an error is thrown from within it, that error is wrapped in a descriptive tag including the arguments to that word." } ;

HELP: DESCRIPTIVE::
{ $syntax "DESCRIPTIVE:: word ( inputs -- outputs ) definition ;" }
{ $description "Defines a word which uses locals such that, if an error is thrown from within it, that error is wrapped in a descriptive tag including the arguments to that word." } ;

HELP: descriptive
{ $class-description "The class of errors wrapping another error (in the underlying slot) which were thrown in a word (in the word slot) with a given set of arguments (in the args slot)." } ;

ARTICLE: "descriptive" "Descriptive errors"
"This vocabulary defines automatic descriptive errors. Using it, you can define a word which acts as normal, except when it throws an error, the error is wrapped in a special descriptor declaring that an error was thrown from inside that word, and including the arguments given to that word. The error is of the following class:"
{ $subsection descriptive }
"To define words which throw descriptive errors, use the following words:"
{ $subsection POSTPONE: DESCRIPTIVE: }
{ $subsection POSTPONE: DESCRIPTIVE:: } ;

ABOUT: "descriptive"
