USING: help.syntax help.markup kernel math classes classes.tuple
calendar models ;
IN: models.delay

HELP: delay
{ $class-description "Delay models have the same value as their underlying model, however the value only changes after a timer expires. If the underlying model's value changes again before the timer expires, the timer restarts. Delay models are constructed by " { $link <delay> } "." }
{ $examples
    "The following code displays a sliders and a label which is updated half a second after the slider stops changing:"
    { $code
        "USING: models models.delay models.arrow models.range"
        "ui ui.gadgets ui.gadgets.labels ui.gadgets.sliders"
        "ui.gadgets.panes math.parser calendar ;"
        ""
        "<pile>"
        "0 10 0 100 1 <range>"
        "[ horizontal <slider> add-gadget ]"
        "["
        "    1/2 seconds <delay>"
        "    [ unparse ] <arrow>"
        "    <label-control> add-gadget"
        "] bi"
        "\"Test\" open-window"
    }
} ;

HELP: <delay>
{ $values { "model" model } { "timeout" duration } { "delay" delay } }
{ $description "Creates a new instance of " { $link delay } ". The timeout must elapse from the time the underlying model last changed to when the delay model value is changed and its connections are notified." }
{ $examples "See the example in the documentation for " { $link delay } "." } ;

ARTICLE: "models.delay" "Delay models"
"Delay models are used to implement delayed updating of gadgets in response to user input."
{ $subsections
    delay
    <delay>
} ;

ABOUT: "models.delay"
