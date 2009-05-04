USING: help.markup help.syntax ui.commands ui.gadgets.slots
ui.gadgets.editors kernel ;
IN: ui.tools.inspector

ARTICLE: "ui-inspector-edit" "Editing slot values in the inspector"
"Slot values can be edited in the inspector. Clicking the ellipsis to the left of the slot's textual representation displays a slot editor gadget. A text representation of the object can be edited in the slot editor. The parser is used to turn the text representation back into an object. Keep in mind that some structure is lost in the conversion; see " { $link "prettyprint-limitations" } "."
$nl
"The slot editor's text editing commands are standard; see " { $link "ui.gadgets.editors" } "."
$nl
"The slot editor has a toolbar containing various commands."
{ $command-map slot-editor "toolbar" } ;

ARTICLE: "ui-inspector" "UI inspector"
"The graphical inspector provides functionality similar to the terminal inspector (see " { $link "inspector" } "), adding in-place editing of slot values."
$nl
"To display an object in the UI inspector, right-click a presentation and choose " { $strong "Inspector" } " from the menu that appears. The inspector can also be opened from the listener using a word:"
{ $subsection inspector }
"The inspector embeds a table gadget, which supports keyboard navigation; see " { $link "ui.gadgets.tables" } ". It also provides a few other commands:"
{ $command-map inspector-gadget "toolbar" }
{ $command-map inspector-gadget "multi-touch" }
"The UI inspector is an instance of " { $link inspector-gadget } "."
{ $subsection "ui-inspector-edit" } ;

HELP: inspector
{ $values { "obj" object } }
{ $description "Opens a new inspector window displaying the slots of " { $snippet "obj" } "." } ;

ABOUT: "ui-inspector"