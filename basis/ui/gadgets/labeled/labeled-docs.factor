USING: ui.gadgets help.markup help.syntax strings models
ui.gadgets.panes ;
IN: ui.gadgets.labeled

HELP: labeled-gadget
{ $class-description "A labeled gadget can be created by calling " { $link <labeled-gadget> } "." } ;

HELP: <labeled-gadget>
{ $values { "gadget" gadget } { "title" string } { "newgadget" "a new " { $link <labeled-gadget> } } }
{ $description "Creates a new " { $link labeled-gadget } " display " { $snippet "gadget" } " with " { $snippet "title" } " on top." } ;

ARTICLE: "ui.gadgets.labeled" "Labeled gadgets"
"The " { $vocab-link "ui.gadgets.labeled" } " vocabulary implements labeled borders around child gadgets."
{ $subsections
    labeled-gadget
    <labeled-gadget>
} ;

ABOUT: "ui.gadgets.labeled"
