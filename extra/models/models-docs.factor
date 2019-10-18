USING: help.syntax help.markup kernel math classes tuples ;
IN: models

HELP: model
{ $class-description "A mutable cell holding a single value. When the value is changed, a sequence of connected objects are notified. Models have the following slots:"
    { $list
        { { $link model-value } " - the value of the model. Use " { $link set-model } " to change the value." }
        { { $link model-connections } " - a sequence of objects implementing the " { $link model-changed } " generic word, to be notified when the model's value changes." }
        { { $link model-dependencies } " - a sequence of models which should have this model added to their sequence of connections when activated." }
        { { $link model-ref } " - a reference count tracking the number of models which depend on this one." }
    }
"Other classes may delegate to " { $link model } "."
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
{ $values { "observer" object } }
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

{ set-model set-model-value change-model (change-model) } related-words

HELP: set-model-value ( value model -- )
{ $values { "value" object } { "model" model } }
{ $description "Changes the value of a model without notifying any observers registered with " { $link add-connection } "." }
{ $notes "There are very few reasons for user code to call this word. Instead, call " { $link set-model } ", which notifies observers." } ;

HELP: change-model
{ $values { "model" model } { "quot" "a quotation with stack effect " { $snippet "( obj -- newobj )" } } }
{ $description "Applies the quotation to the current value of the model to yield a new value, then changes the value of the model to the new value, and calls " { $link model-changed } " on all observers registered with " { $link add-connection } "." } ;

HELP: (change-model)
{ $values { "model" model } { "quot" "a quotation with stack effect " { $snippet "( obj -- newobj )" } } }
{ $description "Applies the quotation to the current value of the model to yield a new value, then changes the value of the model to the new value without notifying any observers registered with " { $link add-connection } "." }
{ $notes "There are very few reasons for user code to call this word. Instead, call " { $link change-model } ", which notifies observers." } ;

HELP: filter
{ $class-description "Filter model values are computed by applying a quotation to the value of another model. Filters are automatically updated when the underlying model changes. Filters are constructed by " { $link <filter> } "." }
{ $examples
    "The following code displays a label showing the result of applying " { $link sq } " to the value 5:"
    { $code
        "USING: models gadgets-labels gadgets-panes ;"
        "5 <model> [ sq ] <filter> [ number>string ] <filter>"
        "<label-control> gadget."
    }
    "An exercise for the reader is to keep the original model around on the stack, and change its value to 6, observing that the label will immediately display 36."
} ;

HELP: <filter>
{ $values { "model" model } { "quot" "a quotation with stack effect " { $snippet "( obj -- newobj )" } } { "filter" "a new " { $link filter } } }
{ $description "Creates a new instance of " { $link filter } ". The value of the new filter model is computed by applying the quotation to the value." }
{ $examples "See the example in the documentation for " { $link filter } "." } ;

HELP: compose
{ $class-description "Composed model values are computed by collecting the values from a sequence of underlying models into a new sequence. Composed models are automatically updated when underlying models change. Composed models are constructed by " { $link <compose> } "."
$nl
"A composed model whose children are all " { $link "models-range" } " conforms to the " { $link "range-model-protocol" } " and represents a point in n-dimensional space which is bounded by a rectangle." }
{ $examples
    "The following code displays a pair of sliders, and an updating label showing their current values:"
    { $code
        "USING: models ui.gadgets.labels ui.gadgets.sliders ui.gadgets.panes ;"
        ": <funny-slider> <x-slider> 100 over set-slider-max ;"
        "<funny-slider> <funny-slider> 2array"
        "dup make-pile gadget."
        "dup [ control-model ] map <compose> [ unparse ] <filter>"
        "<label-control> gadget."
    }
} ;

HELP: <compose>
{ $values { "models" "a sequence of models" } { "compose" "a new " { $link compose } } }
{ $description "Creates a new instance of " { $link compose } ". The value of the new compose model is obtained by mapping " { $link model-value } " over the given sequence of models." }
{ $examples "See the example in the documentation for " { $link compose } "." } ;

HELP: history
{ $class-description "History models record a timeline of previous values on calls to " { $link add-history } ", and can travel back and forth on the timeline with " { $link go-back } " and " { $link go-forward } ". History models are constructed by " { $link <history> } "." } ;

HELP: <history>
{ $values { "value" object } { "history" "a new " { $link history } } }
{ $description "Creates a new history model with an initial value." } ;

{ <history> add-history go-back go-forward } related-words

HELP: go-back
{ $values { "history" history } }
{ $description "Restores the previous value and calls " { $link model-changed } " on all observers registered with " { $link add-connection } "." } ;

HELP: go-forward
{ $values { "history" history } }
{ $description "Restores the value set prior to the last call to " { $link go-back } " and calls " { $link model-changed } " on all observers registered with " { $link add-connection } "." } ;

HELP: add-history
{ $values { "history" history } }
{ $description "Adds the current value to the history." } ;

HELP: delay
{ $class-description "Delay models have the same value as their underlying model, however the value only changes after a timer expires. If the underlying model's value changes again before the timer expires, the timer restarts. Delay models are constructed by " { $link <delay> } "." }
{ $examples
    "The following code displays a sliders and a label which is updated half a second after the slider stops changing:"
    { $code
        "USING: models gadgets-labels gadgets-sliders gadgets-panes ;"
        ": <funny-slider>"
        "    0 0 0 100 <range> <x-slider> 500 over set-slider-max ;"
        "<funny-slider> dup gadget."
        "control-model 500 <delay> [ number>string ] <filter>"
        "<label-control> gadget."
    }
} ;

HELP: <delay>
{ $values { "model" model } { "timeout" "a positive integer" } { "delay" delay } }
{ $description "Creates a new instance of " { $link delay } ". A timer of " { $snippet "timeout" } " milliseconds must elapse from the time the underlying model last changed to when the delay model value is changed and its connections are notified." }
{ $examples "See the example in the documentation for " { $link delay } "." } ;

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

HELP: range
{ $class-description "Range models implement the " { $link "range-model-protocol" } " with real numbers as the minimum, current, maximum, and page size. Range models are created with " { $link <range> } "." }
{ $notes { $link "ui.gadgets.sliders" } " use range models." } ;

HELP: range-model
{ $values { "range" range } { "model" model } }
{ $description "Outputs a model holding a range model's current value." }
{ $notes "This word is not part of the " { $link "range-model-protocol" } ", and can only be used on direct instances of " { $link range } "." } ;

HELP: range-min
{ $values { "range" range } { "model" model } }
{ $description "Outputs a model holding a range model's minimum value." }
{ $notes "This word is not part of the " { $link "range-model-protocol" } ", and can only be used on direct instances of " { $link range } "." } ;

HELP: range-max
{ $values { "range" range } { "model" model } }
{ $description "Outputs a model holding a range model's maximum value." }
{ $notes "This word is not part of the " { $link "range-model-protocol" } ", and can only be used on direct instances of " { $link range } "." } ;

HELP: range-page
{ $values { "range" range } { "model" model } }
{ $description "Outputs a model holding a range model's page size." }
{ $notes "This word is not part of the " { $link "range-model-protocol" } ", and can only be used on direct instances of " { $link range } "." } ;

HELP: move-by
{ $values { "amount" real } { "range" range } }
{ $description "Adds a number to a range model's current value." }
{ $side-effects "range" } ;

HELP: move-by-page
{ $values { "amount" real } { "range" range } }
{ $description "Adds a multiple of the page size to a range model's current value." }
{ $side-effects "range" } ;

ARTICLE: "models" "Models"
"The Factor UI provides basic support for dataflow programming via " { $emphasis "models" } " and " { $emphasis "controls" } ". A model is an observable value. Changing a model's value notifies other objects which depend on the model automatically, and models may depend on each other's values."
$nl
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
"Special types of models:"
{ $subsection "models-filter" }
{ $subsection "models-compose" }
{ $subsection "models-history" }
{ $subsection "models-delay" }
{ $subsection "models-range" }
{ $subsection "models-impl" } ;

ARTICLE: "models-filter" "Filter models"
"Filter model values are computed by applying a quotation to the value of another model."
{ $subsection filter }
{ $subsection <filter> } ;

ARTICLE: "models-compose" "Composed models"
"Composed model values are computed by collecting the values from a sequence of underlying models into a new sequence."
{ $subsection compose }
{ $subsection <compose> } ;

ARTICLE: "models-history" "History models"
"History models record previous values."
{ $subsection history }
{ $subsection <history> }
"Recording history:"
{ $subsection add-history }
"Navigating the history:"
{ $subsection go-back }
{ $subsection go-forward } ;

ARTICLE: "models-delay" "Delay models"
"Delay models are used to implement delayed updating of gadgets in response to user input."
{ $subsection delay }
{ $subsection <delay> } ;

ARTICLE: "models-range" "Range models"
"Range models ensure their value is a real number within a fixed range."
{ $subsection range }
{ $subsection <range> }
"Range models conform to a protocol for getting and setting the current value, as well as the endpoints of the range."
{ $subsection "range-model-protocol" } ;

ARTICLE: "range-model-protocol" "Range model protocol"
"The range model protocol is implemented by the " { $link range } " and " { $link compose } " classes. User-defined models may implement it too."
{ $subsection range-value          }
{ $subsection range-page-value     } 
{ $subsection range-min-value      } 
{ $subsection range-max-value      } 
{ $subsection range-max-value*     } 
{ $subsection set-range-value      } 
{ $subsection set-range-page-value } 
{ $subsection set-range-min-value  } 
{ $subsection set-range-max-value  } ;

ARTICLE: "models-impl" "Implementing models"
"New types of models can be defined, along the lines of " { $link filter } " and such."
$nl
"Models can execute hooks when activated:"
{ $subsection model-activated }
"Models can override requests to change their value, for example to perform validation:"
{ $subsection set-model } ;

ABOUT: "models"
