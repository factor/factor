USING: help.markup help.syntax ui.gadgets.buttons
ui.gadgets.menus models ui.operations summary kernel
ui.gadgets.worlds ui.gadgets ui.gadgets.status-bar ;
IN: ui.gadgets.presentations

HELP: presentation
{ $class-description "A presentation is a " { $link button } " which represents an object. Left-clicking a presentation invokes the default " { $link operation } ", and right-clicking displays a menu of possible operations output by " { $link object-operations } "."
$nl
"Presentations are created by calling " { $link <presentation> } "."
$nl
"Presentations have two slots:"
{ $list
    { { $snippet "object" } " - the object being presented." }
    { { $snippet "hook" } " - " { $quotation ( presentation -- ) } ". The default value is " { $snippet "[ drop ]" } "." }
} } ;

HELP: invoke-presentation
{ $values { "presentation" presentation } { "command" "a command" } }
{ $description "Calls the " { $snippet "hook" } " and then invokes the command on the " { $snippet "object" } "." } ;

{ invoke-presentation invoke-primary invoke-secondary } related-words

HELP: invoke-primary
{ $values { "presentation" presentation } }
{ $description "Invokes the " { $link primary-operation } " associated to the " { $snippet "object" } ". This word is executed when the presentation is clicked with the left mouse button." } ;

HELP: invoke-secondary
{ $values { "presentation" presentation } }
{ $description "Invokes the " { $link secondary-operation } " associated to the " { $snippet "object" } ". This word is executed when a list receives a " { $snippet "RET" } " key press." } ;

HELP: <presentation>
{ $values { "label" "a label" } { "object" object } { "button" "a new " { $link button } } }
{ $description "Creates a new " { $link presentation } " derived from " { $link <roll-button> } "." }
{ $see-also "presentations" } ;

{ <button> <border-button> <command-button> <roll-button> <presentation> } related-words

{ <status-bar> show-mouse-help show-status show-summary hide-status } related-words

HELP: show-mouse-help
{ $values { "presentation" presentation } }
{ $description "Displays a " { $link summary } " of the " { $snippet "object" } "in the status bar of the " { $link world } " containing this presentation. This word is executed when the mouse enters the presentation." } ;

ARTICLE: "ui.gadgets.presentations" "Presentation gadgets"
"The " { $vocab-link "ui.gadgets.presentations" } " vocabulary implements presentations, which are graphical representations of an object, associated with the object itself (see " { $link "ui-operations" } ")."
$nl
"Clicking a presentation with the left mouse button invokes the object's primary operation, and clicking with the right mouse button displays a menu of all applicable operations. Presentations are usually not constructed directly, and instead are written to " { $link "ui.gadgets.panes" } " with formatted stream output words (see " { $link "presentations" } ")."
{ $subsections
    presentation
    <presentation>
} ;

ABOUT: "ui.gadgets.presentations"
