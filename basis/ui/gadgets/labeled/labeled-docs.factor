USING: ui.gadgets help.markup help.syntax strings models
ui.gadgets.panes ;
IN: ui.gadgets.labeled

HELP: labeled-gadget
{ $class-description "A labeled gadget can be created by calling " { $link <labeled-gadget> } "." } ;

HELP: <labeled-gadget>
{ $values { "gadget" gadget } { "title" string } { "newgadget" "a new " { $link <labeled-gadget> } } }
{ $description "Creates a new " { $link labeled-gadget } " display " { $snippet "gadget" } " with " { $snippet "title" } " on top." } ;

HELP: <labeled-pane>
{ $values { "model" model } { "quot" { $quotation "( value -- )" } } { "scrolls?" "a boolean" } { "title" string } { "gadget" "a new " { $link gadget } } }
{ $description "Creates a new control delegating to a " { $link pane } ", and wraps it in a " { $link labeled-gadget } ". When the value of the model changes, the value is pushed on the stack and the quotation is called using " { $link with-pane } "." } ;

{ <labeled-pane> <pane-control> } related-words

ARTICLE: "ui.gadgets.labeled" "Labelled gadgets"
"The " { $vocab-link "ui.gadgets.labeled" } " vocabulary implements labeled borders around child gadgets."
{ $subsection labeled-gadget }
{ $subsection <labeled-gadget> } ;

ABOUT: "ui.gadgets.labeled"
