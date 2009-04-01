USING: help.syntax help.markup kernel math classes classes.tuple
calendar ;
IN: models

HELP: model
{ $class-description "A mutable cell holding a single value. When the value is changed, a sequence of connected objects are notified. Models have the following slots:"
    { $list
        { { $slot "value" } " - the value of the model. Use " { $link set-model } " to change the value." }
        { { $slot "connections" } " - a sequence of objects implementing the " { $link model-changed } " generic word, to be notified when the model's value changes." }
        { { $slot "dependencies" } " - a sequence of models which should have this model added to their sequence of connections when activated." }
        { { $slot "ref" } " - a reference count tracking the number of models which depend on this one." }
        { { $slot "locked?" } " - a slot set by " { $link with-locked-model } " to ensure that the model doesn't get changed recursively" }
    }
"Other classes may inherit from " { $link model } "."
} ;

HELP: <model>
{ $values { "value" object } { "model" "a new " { $link model } } }
{ $description "Creates a new model with an initial value." } ;

HELP: add-dependency
{ $values { "dep" model } { "model" model } }
{ $description "Registers a dependency. When " { $snippet "model" } " is activated, it will be added to " { $snippet "dep" } "'s connections and notified when " { $snippet "dep" } " changes." }
{ $notes "This word should not be called directly unless you are implementing your own model class." } ;

{ add-dependency remove-dependency activate-model deactivate-model } related-words

HELP: remove-dependency
{ $values { "dep" model } { "model" model } }
{ $description "Unregisters a dependency." }
{ $notes "This word should not be called directly unless you are implementing your own model class." } ;

HELP: model-activated
{ $values { "model" model } }
{ $contract "Called after a model has been activated." } ;

{ model-activated activate-model deactivate-model } related-words

HELP: activate-model
{ $values { "model" model } }
{ $description "Increments the reference count of the model. If it was previously zero, this model is added as a connection to all models registered as dependencies by " { $link add-dependency } "." }
{ $warning "Calls to " { $link activate-model } " and " { $link deactivate-model } " should be balanced to keep the reference counting consistent, otherwise " { $link model-changed } " might be called at the wrong time or not at all." } ;

HELP: deactivate-model
{ $values { "model" model } }
{ $description "Decrements the reference count of the model. If it reaches zero, this model is removed as a connection from all models registered as dependencies by " { $link add-dependency } "." }
{ $warning "Calls to " { $link activate-model } " and " { $link deactivate-model } " should be balanced to keep the reference counting consistent, otherwise " { $link model-changed } " might be called at the wrong time or not at all." } ;

HELP: model-changed
{ $values { "model" model } { "observer" object } }
{ $contract "Called to notify observers of a model that the model value has changed as a result of a call to " { $link set-model } ". Observers can be registered with " { $link add-connection } "." } ;

{ add-connection remove-connection model-changed } related-words

HELP: add-connection
{ $values { "observer" object } { "model" model } }
{ $contract "Registers an object interested in being notified of changes to the model's value. When the value is changed as a result of a call to " { $link set-model } ", the " { $link model-changed } " word is called on the observer." } ;

HELP: remove-connection
{ $values { "observer" object } { "model" model } }
{ $contract "Unregisters an object no longer interested in being notified of changes to the model's value." } ;

HELP: set-model
{ $values { "value" object } { "model" model } }
{ $description "Changes the value of a model and calls " { $link model-changed } " on all observers registered with " { $link add-connection } "." } ;

{ set-model change-model (change-model) } related-words

HELP: change-model
{ $values { "model" model } { "quot" { $quotation "( obj -- newobj )" } } }
{ $description "Applies the quotation to the current value of the model to yield a new value, then changes the value of the model to the new value, and calls " { $link model-changed } " on all observers registered with " { $link add-connection } "." } ;

HELP: (change-model)
{ $values { "model" model } { "quot" { $quotation "( obj -- newobj )" } } }
{ $description "Applies the quotation to the current value of the model to yield a new value, then changes the value of the model to the new value without notifying any observers registered with " { $link add-connection } "." }
{ $notes "There are very few reasons for user code to call this word. Instead, call " { $link change-model } ", which notifies observers." } ;

HELP: range-value
{ $values { "model" model } { "value" object } }
{ $contract "Outputs the current value of a range model." } ;

HELP: range-page-value
{ $values { "model" model } { "value" object } }
{ $contract "Outputs the page size of a range model." } ;

HELP: range-min-value
{ $values { "model" model } { "value" object } }
{ $contract "Outputs the minimum value of a range model." } ;

HELP: range-max-value
{ $values { "model" model } { "value" object } }
{ $contract "Outputs the maximum value of a range model." } ;

HELP: range-max-value*
{ $values { "model" model } { "value" object } }
{ $contract "Outputs the slider position for a range model. Since the bottom of the slider cannot exceed the maximum value, this is equal to the maximum value minus the page size." } ;

HELP: set-range-value
{ $values { "value" object } { "model" model } }
{ $description "Sets the current value of a range model." } 
{ $side-effects "model" } ;

HELP: set-range-page-value
{ $values { "value" object } { "model" model } }
{ $description "Sets the page size of a range model." } 
{ $side-effects "model" } ;

HELP: set-range-min-value
{ $values { "value" object } { "model" model } }
{ $description "Sets the minimum value of a range model." } 
{ $side-effects "model" } ;

HELP: set-range-max-value
{ $values { "value" object } { "model" model } }
{ $description "Sets the maximum value of a range model." }
{ $side-effects "model" } ;

ARTICLE: "models" "Models"
"The " { $vocab-link "models" } " vocabulary provides basic support for dataflow programming. A model is an observable value. Changing a model's value notifies other objects which depend on the model automatically, and models may depend on each other's values."
$nl
"The class of models:"
{ $subsection model }
"Creating models:"
{ $subsection <model> }
"Adding and removing connections:"
{ $subsection add-connection }
{ $subsection remove-connection }
"Generic word called on model connections when the model value changes:"
{ $subsection model-changed }
"When using models which are not associated with controls (or when unit testing controls), you must activate and deactivate models manually:"
{ $subsection activate-model }
{ $subsection deactivate-model }
{ $subsection "models-impl" }
{ $subsection "models.arrow" }
{ $subsection "models.product" }
{ $subsection "models-history" }
{ $subsection "models-range" }
{ $subsection "models-delay" } ;

ARTICLE: "models-impl" "Implementing models"
"New types of models can be defined, for example see " { $vocab-link "models.arrow" } "."
$nl
"Models can execute hooks when activated:"
{ $subsection model-activated }
"Models can override requests to change their value, for example to perform validation:"
{ $subsection set-model } ;

ABOUT: "models"
