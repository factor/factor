USING: help.markup help.syntax models models.arrow sequences ui.frp.signals ;
IN: ui.frp.signals

HELP: <merge>
{ $values { "models" "a list of models" } { "signal" basic-model } }
{ $description "Creates a signal that merges the updates of others" } ;

HELP: <filter>
{ $values { "model" model } { "quot" "quotation with stack effect ( a b -- c )" } { "filter-signal" filter-model } }
{ $description "Creates a signal that uses the updates of another model only when they satisfy a given predicate" } ;

HELP: <fold>
{ $values { "oldval" "starting value" } { "quot" "applied to update and previous values" } { "model" model } { "signal" model } }
{ $description "Similar to " { $link reduce } " but works on models, applying a quotation to the previous and new values at each update" } ;

HELP: <switch>
{ $values { "signal1" model } { "signal2" model } { "signal'" model } }
{ $description "Creates a signal that starts with the behavior of signal1 and switches to the behavior of signal2 on its update" } ;

HELP: <mapped>
{ $values { "model" model } { "quot" "applied to model's value on updates" } { "signal" model } }
{ $description "The signal version of an " { $link <arrow> } } ;

HELP: $>
{ $values { "model" model } { "quot" "applied to model's value on updates" } { "signal" model } }
{ $description "Like " { $link <mapped> } ", but doesn't produce a new value" } ;

HELP: <$
{ $values { "model" model } { "quot" "applied to model's value on updates" } { "signal" model } }
{ $description "Opposite of " { $link <$ } "- gives output, but takes no input" } ;