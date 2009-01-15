USING: documents help.markup help.syntax ui.gadgets
ui.gadgets.scrollers models strings ui.commands ;
IN: ui.gadgets.editors

HELP: editor
{ $class-description "An editor is a control for editing a multi-line passage of text stored in a " { $link document } " model. Editors are crated by calling " { $link <editor> } "."
$nl
"Editors have the following slots:"
{ $list
    { { $snippet "font" } " - a font specifier." }
    { { $snippet "color" } " - text color specifier." }
    { { $snippet "caret-color" } " - caret color specifier." }
    { { $snippet "selection-color" } " - selection background color specifier." }
    { { $snippet "caret" } " - a model storing a line/column pair." }
    { { $snippet "mark" } " - a model storing a line/column pair. If there is no selection, the mark is equal to the caret, otherwise the mark is located at the opposite end of the selection from the caret." }
    { { $snippet "focused?" } " - a boolean." }
} } ;

HELP: <editor>
{ $values { "editor" "a new " { $link editor } } }
{ $description "Creates a new " { $link editor } " with an empty document." } ;

{ editor-caret editor-mark } related-words

HELP: editor-caret
{ $values { "editor" editor } { "loc" "a pair of integers" } }
{ $description "Outputs the current caret location as a line/column number pair." } ;

HELP: editor-mark
{ $values { "editor" editor } { "loc" "a pair of integers" } }
{ $description "Outputs the current mark location as a line/column number pair." } ;

HELP: change-caret
{ $values { "editor" editor } { "quot" { $quotation "( loc -- newloc )" } } }
{ $description "Applies a quotation to the current caret location and moves the caret to the location output by the quotation." } ;

{ change-caret change-caret&mark mark>caret } related-words

HELP: mark>caret
{ $values { "editor" editor } }
{ $description "Moves the mark to the caret location, effectively deselecting any selected text." } ;

HELP: change-caret&mark
{ $values { "editor" editor } { "quot" { $quotation "( loc -- newloc )" } } }
{ $description "Applies a quotation to the current caret location and moves the caret and the mark to the location output by the quotation." } ;

HELP: point>loc
{ $values { "point" "a pair of integers" } { "editor" editor } { "loc" "a pair of integers" } }
{ $description "Converts a point to a line/column number pair." } ;

HELP: scroll>caret
{ $values { "editor" editor } }
{ $description "Ensures that the caret becomes visible in a " { $link scroller } " containing the editor. Does nothing if no parent of " { $snippet "gadget" } " is a " { $link scroller } "." } ;

HELP: remove-selection
{ $values { "editor" editor } }
{ $description "Removes currently selected text from the editor's " { $link document } "." } ;

HELP: editor-string
{ $values { "editor" editor } { "string" string } }
{ $description "Outputs the contents of the editor's " { $link document } " as a string. Lines are separated by " { $snippet "\\n" } "." } ;

HELP: set-editor-string
{ $values { "string" string } { "editor" editor } }
{ $description "Sets the contents of the editor's " { $link document } " to a string,  which may use either " { $snippet "\\n" } ", " { $snippet "\\r\\n" } " or " { $snippet "\\r" } " line separators." } ;

ARTICLE: "gadgets-editors-selection" "The caret and mark"
"If there is no selection, the caret and the mark are at the same location; otherwise the mark delimits the end-point of the selection opposite the caret."
{ $subsection editor-caret }
{ $subsection editor-mark }
{ $subsection change-caret }
{ $subsection change-caret&mark }
{ $subsection mark>caret }
"Getting the selected text:"
{ $subsection gadget-selection? }
{ $subsection gadget-selection }
"Removing selected text:"
{ $subsection remove-selection }
"Scrolling to the caret location:"
{ $subsection scroll>caret }
"Use " { $link user-input* } " to change selected text." ;

ARTICLE: "gadgets-editors" "Editor gadgets"
"The " { $vocab-link "ui.gadgets.editors" } " vocabulary implements editor gadgets. An editor edits a passage of text."
{ $command-map editor "general" }
{ $command-map editor "caret-motion" }
{ $command-map editor "selection" }
{ $command-map multiline-editor "multiline" }
{ $heading "Editor words" }
{ $subsection editor }
{ $subsection <editor> }
{ $subsection <multiline-editor> }
{ $subsection editor-string }
{ $subsection set-editor-string }
{ $subsection "gadgets-editors-selection" }
{ $subsection "documents" }
{ $subsection "document-locs-elts" } ;

ABOUT: "gadgets-editors"
