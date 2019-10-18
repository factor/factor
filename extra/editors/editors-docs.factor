USING: help.markup help.syntax parser vocabs.loader ;
IN: editors

ARTICLE: "editor" "Editor integration"
"Factor development is best done with one of the supported editors; this allows you to quickly jump to definitions from the Factor environment."
{ $subsection edit }
"Depending on the editor you are using, you must load one of the child vocabularies of the " { $vocab-link "editors" } " vocabulary, for example " { $vocab-link "editors.emacs" } "."
$nl
"Editor integration vocabularies store a quotation in a global variable when loaded:"
{ $subsection edit-hook }
"If a syntax error was thrown while loading a source file, you can jump to the location of the error in your editor:"
{ $subsection :edit } ;

ABOUT: "editor"

HELP: edit
{ $values { "defspec" "a definition specifier" } }
{ $description "Opens the source file containing the definition using the current " { $link edit-hook } ". See " { $link "editor" } "." }
{ $examples
    "Editing a word definition:"
    { $code "\\ foo edit" }
    "A word's documentation:"
    { $code "\\ foo >link edit" }
    "A method definition:"
    { $code "{ editor draw-gadget* } edit" }
    "A help article:"
    { $code "\"handbook\" >link edit" }
} ;

HELP: edit-location
{ $values { "file" "a pathname string" } { "line" "a positive integer" } }
{ $description "Opens a source file at the specified line number containing using the current " { $link edit-hook } ". Line numbers are indexed starting from 1. See " { $link "editor" } "." } ;

HELP: no-edit-hook
{ $error-description "Thrown when " { $link edit } " is called when the " { $link edit-hook } " variable is not set. See " { $link "editor" } "." } ;

HELP: :edit
{ $description "If the most recent error was a " { $link parse-error } " thrown while parsing a source file, opens the source file at the failing line in the default editor using the " { $link edit-hook } ". See " { $link "editor" } "." } ;
