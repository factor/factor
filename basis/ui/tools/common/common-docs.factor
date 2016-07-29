USING: classes help.markup help.syntax sequences ui.gadgets ;
IN: ui.tools.common

HELP: set-tool-dim
{ $values { "dim" sequence } { "class" class } }
{ $description "Sets the preferred dimensions for instances of the given tool gadget class." } ;

HELP: with-lines
{ $values { "track" gadget } }
{ $description "Lines are added to the track gadget to visually demarcate its children." } ;
