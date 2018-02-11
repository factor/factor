USING: ui.gadgets help.markup help.syntax strings models
ui.gadgets.panes ui.theme ;
IN: ui.gadgets.labeled

HELP: labeled-gadget
{ $class-description "A labeled gadget can be created by calling " { $link <labeled-gadget> } "." } ;

HELP: <labeled-gadget>
{ $values { "content" gadget } { "title" string } { "labeled" labeled-gadget } }
{ $description "Creates a new " { $link labeled-gadget } " displaying " { $snippet "content" } " with " { $snippet "title" } " on top." } ;

HELP: <colored-labeled-gadget>
{ $values { "content" gadget } { "title" string } { "color" "a color" } { "labeled" labeled-gadget } }
{ $description "Creates a new " { $link labeled-gadget } " displaying " { $snippet "content" } " with " { $snippet "title" } " on top, adding a " { $snippet "color" } " colored divider between title bar and content." } ;

HELP: <framed-labeled-gadget>
{ $values { "content" gadget } { "title" string } { "color" "a color" } { "labeled" labeled-gadget } }
{ $description "Creates a new " { $link labeled-gadget } " displaying " { $snippet "content" } " with " { $snippet "title" } " on top, adding a " { $snippet "color" } " colored divider between title bar and content and a " { $link labeled-border-color } " frame." } ;

ARTICLE: "ui.gadgets.labeled" "Labeled gadgets"
"The " { $vocab-link "ui.gadgets.labeled" } " vocabulary implements labeled borders around child gadgets."
{ $subsections
    labeled-gadget
    <labeled-gadget>
    <colored-labeled-gadget>
    <framed-labeled-gadget>
} ;

ABOUT: "ui.gadgets.labeled"
