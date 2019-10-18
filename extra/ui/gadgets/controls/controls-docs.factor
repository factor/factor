USING: ui.gadgets help.markup help.syntax models kernel classes
tuples ;
IN: ui.gadgets.controls

HELP: control
{ $class-description "A control is a " { $link gadget } " linked to a " { $link model } " stored in the " { $link control-model } " slot. Changes to the model are reflected in the appearance and behavior of the control, and the control may in turn change the value of the model in response to user input."
$nl
"Controls are created by calling " { $link <control> } " and " { $link construct-control } "."
$nl
"Objects may delegate to " { $link control } " instances, in which case the " { $link control-self } " slot must be set to the frontmost object in the delegation chain. This ensures that the correct object receives notification of model changes." } ;

HELP: <control>
{ $values { "model" model } { "gadget" gadget } { "quot" "a quotation with stack effect " { $snippet "( value control -- )" } } }
{ $description "Creates a new control linked to the given model. The gadget parameter becomes the control's delegate. The quotation is called when the model value changes," }
{ $examples
    "The following example creates a gadget whose fill color is determined by the value of a model:"
    { $code
        "USING: ui.gadgets ui.gadgets.panes models ;"
        ": set-fill-color >r <solid> r> set-gadget-interior ;"
        "{ 1.0 0.0 0.5 1.0 } <model>"
        "<gadget> [ set-fill-color ] <control>"
        "{ 100 100 } over set-rect-dim"
        "gadget."
    }
    "The " { $vocab-link "color-picker" } " module extends this example into an elaborate color choose."
} ;

{ <control> construct-control control-value set-control-value } related-words

HELP: control-value
{ $values { "control" control } { "value" object } }
{ $description "Outputs the value of the control's model." } ;

HELP: set-control-value
{ $values { "value" object } { "control" control } }
{ $description "Sets the value of the control's model." } ;

ARTICLE: "ui-control-impl" "Implementing controls"
"A control is a gadget which is linked to an underlying " { $link model } "."
{ $subsection control }
"There are two ways to implement a new control. First, an existing gadget can be wrapped in a control:"
{ $subsection <control> }
"Second, a new tuple class can be defined, whose instances delegate to controls:"
{ $subsection construct-control }
"Some utility words useful in control implementations:"
{ $subsection control-model }
{ $subsection control-value }
{ $subsection set-control-value }
{ $see-also "models" } ;

ABOUT: "ui-control-impl"
