USING: ui.gadgets help.markup help.syntax strings models
ui.gadgets.panes ui.gadgets.controls ;
IN: ui.gadgets.labelled

HELP: labelled-gadget
{ $class-description "A labelled gadget can be created by calling " { $link <labelled-gadget> } "." } ;

HELP: <labelled-gadget>
{ $values { "gadget" gadget } { "title" string } { "newgadget" "a new " { $link <labelled-gadget> } } }
{ $description "Creates a new " { $link labelled-gadget } " display " { $snippet "gadget" } " with " { $snippet "title" } " on top." } ;

HELP: closable-gadget
{ $class-description "A closable gadget displays a title bar with a close box on top of another gadget. Clicking the close box invokes a quotation. Closable gadgets are created by calling " { $link <closable-gadget> } "." } ;

HELP: <closable-gadget>
{ $values { "gadget" gadget } { "title" string } { "quot" "a quotation with stack effect " { $snippet "( button -- )" } } }
{ $description "Creates a new " { $link closable-gadget } ". Clicking the close box calls " { $snippet "quot" } "." }
{ $notes "The quotation can find the " { $link closable-gadget } " instance, or any other parent gadget by calling " { $link find-parent } " with the gadget it receives on the stack." } ;

HELP: <labelled-pane>
{ $values { "model" model } { "quot" "a quotation with stack effect " { $snippet "( value -- )" } } { "title" string } { "gadget" "a new " { $link gadget } } }
{ $description "Creates a new " { $link control } " delegating to a " { $link pane } ", and wraps it in a " { $link labelled-gadget } ". When the value of the model changes, the value is pushed on the stack and the quotation is called using " { $link with-pane } "." } ;

{ <labelled-pane> <pane-control> } related-words

ARTICLE: "ui.gadgets.labelled" "Labelled gadgets"
"It is possible to create a labelled border around a child gadget:"
{ $subsection labelled-gadget }
{ $subsection <labelled-gadget> }
"Or a labelled border with a close box:"
{ $subsection closable-gadget }
{ $subsection <closable-gadget> } ;

ABOUT: "ui.gadgets.labelled"
