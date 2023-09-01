USING: help.markup help.syntax models models.arrow sequences monads ;
IN: models.combinators

HELP: merge
{ $values { "models" "a list of models" } { "model" basic-model } }
{ $description "Creates a model that merges the updates of others" } ;

HELP: filter-model
{ $values { "model" model } { "quot" "quotation with stack effect ( a b -- c )" } { "filter-model" filter-model } }
{ $description "Creates a model that uses the updates of another model only when they satisfy a given predicate" } ;

HELP: fold
{ $values { "model" model } { "oldval" "starting value" } { "quot" "applied to update and previous values" } { "model" model } }
{ $description "Similar to " { $link reduce } " but works on models, applying a quotation to the previous and new values at each update" } ;

HELP: switch-models
{ $values { "model1" model } { "model2" model } { "model'" model } }
{ $description "Creates a model that starts with the behavior of model2 and switches to the behavior of model1 on its update" } ;

HELP: <mapped>
{ $values { "model" model } { "quot" "applied to model's value on updates" } { "model" model } }
{ $description "An expanded version of " { $link <arrow> } ". Use " { $link fmap } " instead." } ;

HELP: when-model
{ $values { "model" model } { "quot" "called on the model if the quot yields true" } { "cond" "a quotation called on the model's value, yielding a boolean value"  } }
{ $description "Calls quot when model updates if its value meets the condition set in cond" } ;

HELP: with-self
{ $values { "quot" "quotation that recieves its own return value" } { "model" model } }
{ $description "Fixed points for models: the quot reacts to the same model to gives" } ;

HELP: #1
{ $values { "model" model } { "model'" model } }
{ $description "Moves a model to the top of its dependencies' connections, thus being notified before the others" } ;

ARTICLE: "models.combinators" "Extending models"
"The " { $vocab-link "models.combinators" } " library expands models to have discrete start and end times. "
"Also, it provides methods of manipulating and combining models, expecially useful when programming user interfaces: "
"The output models of some gadgets (see " { $vocab-link "ui.gadgets.controls" } " ) can be manipulated and used as the input models of others." ;

ABOUT: "models.combinators"
