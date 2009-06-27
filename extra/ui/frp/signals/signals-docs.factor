USING: help.markup help.syntax models models.arrow sequences ui.frp.signals monads ;
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
{ $description "Creates a signal that starts with the behavior of signal2 and switches to the behavior of signal1 on its update" } ;

HELP: <mapped>
{ $values { "model" model } { "quot" "applied to model's value on updates" } { "signal" model } }
{ $description "The signal version of an " { $link <arrow> } } ;

HELP: $>
{ $values { "model" model } { "quot" "applied to model's value on updates" } { "signal" model } }
{ $description "Like " { $link <mapped> } ", but doesn't produce a new value" } ;

HELP: <$
{ $values { "model" model } { "quot" "applied to model's value on updates" } { "signal" model } }
{ $description "Opposite of " { $link <$ } "- gives output, but takes no input" } ;

HELP: frp-when
{ $values { "model" model } { "quot" "called on the model if the quot yields true" } { "cond" "a quotation called on the model's value, yielding a boolean value"  } }
{ $description "Calls quot when model updates if its value meets the condition set in cond" } ;

HELP: with-self
{ $values { "quot" "quotation that recieves its own return value" } { "model" model } }
{ $description "Fixed points for signals: the quot reacts to the same signal to gives" } ;

HELP: #1
{ $values { "model" model } { "model'" model } }
{ $description "Moves a signal to the top of its dependencies' connections, thus being notified before the others" } ;

ARTICLE: { "signals" "about" } "FRP Signals"
"Unlike models, which always have a value, signals have discrete start and end times. "
"They are the core of the frp library: program flow using frp is controlled entirely through manipulating and combining signals. "
"The output signals of some gadgets (see " { $vocab-link "ui.frp.gadgets" } " ) can be manipulated and used as the input signals of others. "
"To combine signals see " { $vocab-link "ui.frp.functors" } ;

ABOUT: { "signals" "about" }