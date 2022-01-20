USING: help.markup help.syntax kernel models ;
IN: models.history

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

ARTICLE: "models.history" "History models"
"History models record previous values."
{ $subsections
    history
    <history>
}
"Recording history:"
{ $subsections add-history }
"Navigating the history:"
{ $subsections
    go-back
    go-forward
} ;

ABOUT: "models.history"
