USING: help.syntax help.markup kernel math classes classes.tuple
calendar sequences growable ;
IN: models

HELP: model
{ $class-description "A mutable cell holding a single value. When the value is changed, a sequence of connected objects are notified. Models have the following slots:"
    { $slots
        { "value" { "the value of the model. Use " { $link set-model } " to change the value." } }
        { "connections" { "a sequence of objects implementing the " { $link model-changed } " generic word, to be notified when the model's value changes." } }
        { "dependencies" { "a sequence of models which should have this model added to their sequence of connections when activated." } }
        { "ref" { "a reference count tracking the number of models which depend on this one." } }
        { "locked?" { "a slot set by " { $link with-locked-model } " to ensure that the model doesn't get changed recursively" } }
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

HELP: compute-model
{ $values { "model" model } { "value" object } }
{ $description "Activate and immediately deactivate the model, forcing recomputation of its value, which is returned. If the model is already activated, no dependencies are recalculated. Useful when using models outside of gadget context or for testing." } ;

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

HELP: update-model
{ $values { "model" model } }
{ $description "Notifies the model that its " { $slot "value" } " slot has been updated by " { $link set-model } "." } ;

HELP: set-model
{ $values { "value" object } { "model" model } }
{ $description "Changes the value of a model, calls " { $link update-model } " to notify it, then calls " { $link model-changed } " on all observers registered with " { $link add-connection } "." } ;

HELP: ?set-model
{ $values { "value" object } { "model" model } }
{ $description "Similar to " { $link set-model } ", but only sets the value if the new value is different." } ;

{ set-model ?set-model change-model change-model* (change-model) push-model pop-model } related-words

HELP: change-model
{ $values { "model" model } { "quot" { $quotation ( ..a obj -- ..b newobj ) } } }
{ $description "Applies the quotation to the current value of the model to yield a new value, then changes the value of the model to the new value, and calls " { $link model-changed } " on all observers registered with " { $link add-connection } "." } ;

HELP: change-model*
{ $values { "model" model } { "quot" { $quotation ( ..a obj -- ..b ) } } }
{ $description "Applies the quotation to the current value of the model and calls " { $link model-changed } " on all observers registered with " { $link add-connection } " without actually changing the value of the model. This is useful for notifying observers of operations that mutate a value, as in " { $link push-model } " and " { $link pop-model } "." } ;

HELP: (change-model)
{ $values { "model" model } { "quot" { $quotation ( ..a obj -- ..b newobj ) } } }
{ $description "Applies the quotation to the current value of the model to yield a new value, then changes the value of the model to the new value without notifying any observers registered with " { $link add-connection } "." }
{ $notes "There are very few reasons for user code to call this word. Instead, call " { $link change-model } ", which notifies observers." } ;

HELP: push-model
{ $values { "value" object } { "model" model } }
{ $description { $link push } "es " { $snippet "value" } " onto the " { $link growable } " sequence stored as the value of " { $snippet "model" } " and calls " { $link model-changed } " on all observers registered for the model with " { $link add-connection } "." } ;

HELP: pop-model
{ $values { "model" model } { "value" object } }
{ $description { $link pop } "s the topmost " { $snippet "value" } " off of the " { $link growable } " sequence stored as the value of " { $snippet "model" } " and calls " { $link model-changed } " on all observers registered for the model with " { $link add-connection } "." } ;

ARTICLE: "models" "Models"
"The " { $vocab-link "models" } " vocabulary provides basic support for dataflow programming. A model is an observable value. Changing a model's value notifies other objects which depend on the model automatically, and models may depend on each other's values."
$nl
"The class of models:"
{ $subsections model }
"Creating models:"
{ $subsections <model> }
"Adding and removing connections:"
{ $subsections
    add-connection
    remove-connection
}
"Generic word called on model connections when the model value changes:"
{ $subsections model-changed }
"When using models which are not associated with controls (or when unit testing controls), you must activate and deactivate models manually:"
{ $subsections
    activate-model
    deactivate-model
    "models-impl"
    "models.arrow"
    "models.product"
    "models.range"
    "models.delay"
} ;

ARTICLE: "models-impl" "Implementing models"
"New types of models can be defined, for example see " { $vocab-link "models.arrow" } "."
$nl
"Models can execute hooks when activated:"
{ $subsections model-activated }
"To avoid recursive updating and do proper notifications, you should set the model values via:"
{ $subsections set-model }
"Models are notified when their values are changed:"
{ $subsections update-model } ;

ABOUT: "models"
