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
"Editor integration vocabularies store an object in a global variable when loaded:"
{ $subsections editor-class }
"If a syntax error was thrown while loading a source file, you can jump to the location of the error in your editor:"
{ $subsections :edit }
"If your favourite editor is missing, you can add support for it. A tutorial is available at "
{ $link "create-editor-integration" } "."
;

ARTICLE: "create-editor-integration" "Creating an editor integration"
"First, let's start with creating a vocabulary for our editor:"
{ $code "\"editors.foo\" scaffold-basis" }
"Open it up in your favourite editor (or your second favourite.)"
$nl
"To create a new integration, we need to implement the editor protocol:"
{ $list
  { "Define a new class to represent your integration, set in " { $link editor-class } }
  { "Define an " { $link editor-command } " method to construct a command that opens your editor" }
  { "Define an " { $link editor-detached? } " method that denotes whether your editor should be run in "
    "detached mode. This should return " { $link t } " for editors that run in a separate terminal." }
  { "Define an " { $link editor-is-child? } " method that tells Factor whether it should be run as "
    "a child process." }
}
$nl
"Every editor is required to reserve its own " { $link editor-class } ". For example:"
{ $code "SINGLETON: foo" }
{ $link editor-class } " will be set to this singleton when Factor is set to use your editor of"
" choice. Now, we will define words that will dispatch when the editor class is set to " 
{ $snippet "foo" } "."
$nl
{ $link editor-command } " takes a file path and line number as strings. Your implementation should "
"form a command that opens the editor to the given line. Many editors have a " { $snippet "+" } 
" option for this. For a simple example of this word's implementation, we can look at "
{ $vocab-link "editors.gedit" } ":"
{ $code "M: gedit editor-command
    [
            gedit-path , number>string \"+\" prepend , ,
    ] { } make ;" }
"Here, " { $snippet gedit-path } " is a word that either pushes the location of " { $snippet "gedit" }
" from PATH, or uses a user-defined path, set in a global."
$nl
"Finally, if your editor does not use a GUI, the " { $link editor-detached? } " method must be "
"defined:"
{ $code "M: foo editor-detached? t ;" }
"If your editor has both GUI and TUI frontends, you may want to use more complex logic, or "
"create a variable that the user can set."
;

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
