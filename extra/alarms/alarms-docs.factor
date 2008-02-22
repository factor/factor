IN: alarms
USING: help.markup help.syntax calendar ;

HELP: alarm
{ $class-description "An alarm. Cancel passed to " { $link cancel-alarm } "." } ;

HELP: add-alarm
{ $values { "time" timestamp } { "frequency" "a " { $link dt } " or " { $link f } } { "quot" quotation } { "alarm" alarm } }
{ $description "Creates and registers an alarm. If " { $snippet "frequency" } " is " { $link f } ", this will be a one-time alarm, otherwise it will fire with the given frequency. The quotation will be called from the alarm thread." } ;

HELP: cancel-alarm
{ $values { "alarm" alarm } }
{ $description "Cancels an alarm." }
{ $errors "Throws an error if the alarm is not active." } ;

ARTICLE: "alarms" "Alarms"
"Alarms provide a lightweight way to schedule one-time and recurring tasks without spawning a new thread."
{ $subsection alarm }
{ $subsection add-alarm }
{ $subsection cancel-alarm } ;

ABOUT: "alarms"
