USING: colors documents fonts help.markup help.syntax help.tips models
sequences strings ui.commands ui.gadgets ui.gadgets.line-support
ui.gadgets.scrollers ;
IN: ui.gadgets.editors

HELP: <multiline-editor>
{ $values { "editor" multiline-editor } }
{ $description "Creates a new multi-line editor gadget." } ;

HELP: editor
{ $class-description "An editor is a control for editing a multi-line passage of text stored in a " { $link document } " model. Editors are created by calling " { $link <editor> } "."
$nl
"Editors have the following slots:"
{ $slots
    { "caret" { "a " { $link model } " storing a line/column pair." } }
    { "mark" { "a " { $link model } " storing a line/column pair. If there is no selection, the mark is equal to the caret, otherwise the mark is located at the opposite end of the selection from the caret." } }
    { "focused?" { "a boolean." } }
    { "preedit-start" { "a line/column pair or " { $link f } ". It represents the starting point of the string being edited by an input method." } }
    { "preedit-end" { "a line/column pair or " { $link f } ". It represents the end point of the string being edited by an input method." } }
    { "preedit-selected-start" { "a line/column pair or " { $link f } ". It represents the starting point of the string being selected by an input method." } }
    { "preedit-selected-end" { "a line/column pair or " { $link f } ". It represents the end point of the string being selected by an input method." } }
    { "preedit-selection-mode?" { "a boolean. It means the mode of selecting convertion canditate word. The caret in an editor is not drawn if it is true." } }
    { "preedit-underlines" { "an array or " { $link f } ". It stores underline attributes for its preedit area." } }
}
$nl
" Slots that are prefixed with \"preedit-\" should not be modified directly. They are changed by the platform-dependent backend."
}
{ $see-also line-gadget } ;

HELP: <editor>
{ $values { "editor" "a new " { $link editor } } }
{ $description "Creates a new " { $link editor } " with an empty document." } ;

{ editor-caret editor-mark } related-words

HELP: caret-style
{ $description "Caret styles available:"
{ $table
  { "Value" "Shape" }
  { { $link +line+ } "line (default)" }
  { { $link +box+ } "box" }
  { { $link +filled+ } "filled box" }
}
}
{ $references "Set desired caret style in your .factor-rc file" "rc-files" } ;

HELP: editor-caret
{ $values { "editor" editor } { "loc" "a pair of integers" } }
{ $description "Outputs the current caret location as a line/column number pair." } ;

HELP: editor-mark
{ $values { "editor" editor } { "loc" "a pair of integers" } }
{ $description "Outputs the current mark location as a line/column number pair." } ;

HELP: change-caret
{ $values { "editor" editor } { "quot" { $quotation ( loc document -- newloc ) } } }
{ $description "Applies a quotation to the current caret location and moves the caret to the location output by the quotation." } ;

{ change-caret change-caret&mark mark>caret } related-words

HELP: mark>caret
{ $values { "editor" editor } }
{ $description "Moves the mark to the caret location, effectively deselecting any selected text." } ;

HELP: change-caret&mark
{ $values { "editor" editor } { "quot" { $quotation ( loc document -- newloc ) } } }
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

HELP: <model-field>
{ $values { "model" model } { "gadget" editor } }
{ $description "Creates an editor gadget which targets the specified model. The model must contain a string, or another item with a defined " { $link length } ", as this will be checked during layout." } ;

HELP: <action-field>
{ $values { "quot" { $quotation ( string -- ) } } { "gadget" editor } }
{ $description "Creates an editor gadget with a blank model. Whenever a value is entered into the editor and Return pressed, the value is pushed on the stack as a string and the specified quotation is called. Note that the quotation cannot update the value in the field." } ;


HELP: editor-string
{ $values { "editor" editor } { "string" string } }
{ $description "Outputs the contents of the editor's " { $link document } " as a string. Lines are separated by " { $snippet "\\n" } "." } ;



HELP: set-editor-string
{ $values { "string" string } { "editor" editor } }
{ $description "Sets the contents of the editor's " { $link document } " to a string, which may use either " { $snippet "\\n" } ", " { $snippet "\\r\\n" } " or " { $snippet "\\r" } " line separators." } ;

ARTICLE: "gadgets-editors-selection" "The caret and mark"
"If there is no selection, the caret and the mark are at the same location; otherwise the mark delimits the end-point of the selection opposite the caret."
{ $subsections
    editor-caret
    editor-mark
    change-caret
    change-caret&mark
    mark>caret
}
"Getting the selected text:"
{ $subsections
    gadget-selection?
    gadget-selection
}
"Removing selected text:"
{ $subsections remove-selection }
"Scrolling to the caret location:"
{ $subsections scroll>caret }
"Use " { $link user-input* } " to change selected text." ;

ARTICLE: "gadgets-editors-contents" "Getting and setting editor contents"
{ $subsections
    editor-string
    set-editor-string
    clear-editor
} ;

ARTICLE: "gadgets-editors-commands" "Editor gadget commands"
{ $command-map editor "editing" }
{ $command-map editor "caret-motion" }
{ $command-map editor "selection" }
{ $command-map editor "clipboard" }
{ $command-map multiline-editor "multiline" } ;

ARTICLE: "ui.gadgets.editors" "Editor gadgets"
"The " { $vocab-link "ui.gadgets.editors" } " vocabulary implements editor gadgets. An editor edits a passage of text. Editors display a " { $link document } ". Editors are built from and inherit all features of " { $link "ui.gadgets.line-support" } "."
{ $subsections "gadgets-editors-commands" }
"Editors:"
{ $subsections
    editor
    <editor>
    "gadgets-editors-contents"
    "gadgets-editors-selection"
}
"Multiline editors:"
{ $subsections <multiline-editor> }
"Fields:"
{ $subsections
    <model-field>
    <action-field>
}
"Editors edit " { $emphasis "documents" } ":"
{ $subsections "documents" } ;

TIP: "Editor gadgets support undo and redo; press " { $command editor "editing" com-undo } " and " { $command editor "editing" com-redo } "." ;

TIP: "Learn the keyboard shortcuts used in " { $link "ui.gadgets.editors" } "." ;

ABOUT: "ui.gadgets.editors"
