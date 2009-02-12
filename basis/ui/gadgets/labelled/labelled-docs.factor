USING: ui.gadgets help.markup help.syntax strings models
ui.gadgets.panes ;
IN: ui.gadgets.labelled

HELP: labelled-gadget
{ $class-description "A labelled gadget can be created by calling " { $link <labelled-gadget> } "." } ;

HELP: <labelled-gadget>
{ $values { "gadget" gadget } { "title" string } { "newgadget" "a new " { $link <labelled-gadget> } } }
{ $description "Creates a new " { $link labelled-gadget } " display " { $snippet "gadget" } " with " { $snippet "title" } " on top." } ;

HELP: <labelled-pane>
{ $values { "model" model } { "quot" { $quotation "( value -- )" } } { "scrolls?" "a boolean" } { "title" string } { "gadget" "a new " { $link gadget } } }
{ $description "Creates a new control delegating to a " { $link pane } ", and wraps it in a " { $link labelled-gadget } ". When the value of the model changes, the value is pushed on the stack and the quotation is called using " { $link with-pane } "." } ;

{ <labelled-pane> <pane-control> } related-words

ARTICLE: "ui.gadgets.labelled" "Labelled gadgets"
"The " { $vocab-link "ui.gadgets.labelled" } " vocabulary implements labelled borders around child gadgets."
{ $subsection labelled-gadget }
{ $subsection <labelled-gadget> } ;

ABOUT: "ui.gadgets.labelled"
