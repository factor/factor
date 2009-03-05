IN: ui.gadgets.line-support
USING: help.markup help.syntax ;

ARTICLE: "ui.gadgets.line-support" "Gadget line support"
"The " { $vocab-link "ui.gadgets.line-support" } " vocabulary provides common code shared by gadgets which display a sequence of lines of text. Currently, the two gadgets that use it are " { $link "ui.gadgets.editors" } " and " { $link "ui.gadgets.tables" } "."
$nl
"The class of line gadgets:"
{ $subsection line-gadget }
{ $subsection line-gadget? }
"Line gadgets are backed by a model which must be a sequence. The number of lines in the gadget is the length of the sequence."
$nl
"Line gadgets cannot be created and used directly, instead a subclass must be defined:"
{ $subsection new-line-gadget }
"Subclasses must implement a generic word:"
{ $subsection draw-line }
"Two optional generic words may be implemented; if they are not implemented in the subclass, a default implementation based on font metrics will be used:"
{ $subsection line-height }
{ $subsection line-leading }
"Validating line numbers:"
{ $subsection validate-line }
"Working with visible lines:"
{ $subsection visible-lines }
{ $subsection first-visible-line }
{ $subsection last-visible-line }
"Converting y co-ordinates to line numbers, and vice versa:"
{ $subsection line>y }
{ $subsection y>line } ;

ABOUT: "ui.gadgets.line-support"