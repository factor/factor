USING: help.markup help.syntax
ui.gadgets.buttons ui.gadgets.menus models ui.operations
inspector kernel ui.gadgets.worlds ui.gadgets ;
IN: ui.gadgets.presentations

HELP: presentation
{ $class-description "A presentation is a " { $link button } " which represents an object. Left-clicking a presentation invokes the default " { $link operation } ", and right-clicking displays a menu of possible operations output by " { $link object-operations } "."
$nl
"Presentations are created by calling " { $link <presentation> } "."
$nl
"Presentations have two slots:"
{ $list
    { { $link presentation-object } " - the object being presented." }
    { { $link presentation-hook } " - a quotation with stack effect " { $snippet "( presentation -- )" } ". The default value is " { $snippet "[ drop ]" } "." }
} } ;

HELP: invoke-presentation
{ $values { "presentation" presentation } { "command" "a command" } }
{ $description "Calls the " { $link presentation-hook } " and then invokes the command on the " { $link presentation-object } "." } ;

{ invoke-presentation invoke-primary invoke-secondary } related-words

HELP: invoke-primary
{ $values { "presentation" presentation } } 
{ $description "Invokes the " { $link primary-operation } " associated to the " { $link presentation-object } ". This word is executed when the presentation is clicked with the left mouse button." } ;

HELP: invoke-secondary
{ $values { "presentation" presentation } } 
{ $description "Invokes the " { $link secondary-operation } " associated to the " { $link presentation-object } ". This word is executed when a list receives a " { $snippet "RET" } " key press." } ;

HELP: <presentation>
{ $values { "label" "a label" } { "object" object } { "button" "a new " { $link button } } }
{ $description "Creates a new " { $link presentation } " derived from " { $link <roll-button> } "." }
{ $see-also "presentations" } ;

{ <button> <bevel-button> <command-button> <roll-button> <presentation> } related-words

{ <commands-menu> <toolbar> operations-menu show-menu } related-words

HELP: show-mouse-help
{ $values { "presentation" presentation } }
{ $description "Displays a " { $link summary } " of the " { $link presentation-object } "in the status bar of the " { $link world } " containing this presentation. This word is executed when the mouse enters the presentation." } ;

ARTICLE: "ui.gadgets.presentations" "Presentation gadgets"
"Outliner gadgets are usually not constructed directly, and instead are written to " { $link "ui.gadgets.panes" } " with formatted stream output words (" { $link "presentations" } ")."
{ $subsection presentation }
{ $subsection <presentation> }
"Presentations remember the object they are presenting; operations can be performed on the presented object. See " { $link "ui-operations" } "." ;

ABOUT: "ui.gadgets.presentations"
