USING: help.markup help.syntax parser source-files
source-files.errors vocabs.loader kernel ;
IN: editors

ARTICLE: "editor" "Editor integration"
"Factor development is best done with one of the supported editors; this allows you to quickly jump to definitions from the Factor environment."
{ $subsections edit }
"Depending on the editor you are using, you must load one of the child vocabularies of the " { $vocab-link "editors" } " vocabulary, for example " { $vocab-link "editors.emacs" } ":"
{ $code "USE: editors.emacs" }
"If you intend to always use the same editor, it helps to have it load during stage 2 bootstrap. Place the code to load and possibly configure it in the " { $link ".factor-boot-rc" } "."
$nl
"Editor integration vocabularies store a class or tuple in a global variable when loaded:"
{ $subsections editor-class }
"If a syntax error was thrown while loading a source file, you can jump to the location of the error in your editor:"
{ $subsections :edit } ;

ABOUT: "editor"

HELP: edit
{ $values { "object" object } }
{ $description "Opens the source file containing the definition using the current " { $link editor-class } ". See " { $link "editor" } "." }
{ $examples
    "Editing a word definition:"
    { $code "\\ foo edit" }
    "A word's documentation:"
    { $code "\\ foo >link edit" }
    "A method definition:"
    { $code "M\\ fixnum + edit" }
    "A help article:"
    { $code "\"handbook\" >link edit" }
} ;

HELP: edit-location
{ $values { "file" "a pathname string" } { "line" "a positive integer" } }
{ $description "Opens a source file at the specified line number containing using the current " { $link editor-class } ". Line numbers are indexed starting from 1. See " { $link "editor" } "." } ;

HELP: :edit
{ $description "If the most recent error was a " { $link source-file-error } " thrown while parsing a source file, opens the source file at the failing line in the default editor. See " { $link "editor" } "." } ;
