USING: help.syntax help.markup classes kernel ;
IN: timers

HELP: init-timers
{ $description "Initializes the timer code." }
{ $notes "This word is automatically called when the UI is initialized, and it should only be called manually if timers are being used outside of the UI." } ;

HELP: tick
{ $values { "object" object } }
{ $description "Called to notify an object registered with a timer that the timer has fired." } ;

HELP: add-timer
{ $values { "object" object } { "delay" "a positive integer" } { "initial" "a positive integer" } }
{ $description "Registers a timer. Every " { $snippet "delay" } " milliseconds, " { $link tick } " will be called on the object. The initial delay from the time " { $link add-timer } " is called to when " { $link tick } " is first called is " { $snippet "initial" } " milliseconds." } ;

HELP: remove-timer
{ $values { "object" object } }
{ $description "Unregisters a timer." } ;

HELP: do-timers
{ $description "Fires all registered timers which are due to fire." }
{ $notes "This word is automatically called from the UI event loop, and it should only be called manually if timers are being used outside of the UI." } ;

{ init-timers add-timer remove-timer tick do-timers } related-words

ARTICLE: "timers" "Timers"
"Timers can be added and removed:"
{ $subsection add-timer }
{ $subsection remove-timer }
"Classes must implement a generic word so that their instances can handle timer ticks:"
{ $subsection tick }
"Timers can be used outside of the UI, however they must be initialized with an explicit call, and fired manually:"
{ $subsection init-timers }
{ $subsection do-timers } ;

ABOUT: "timers"
