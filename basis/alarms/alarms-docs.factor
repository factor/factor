IN: alarms
USING: help.markup help.syntax calendar quotations ;

HELP: alarm
{ $class-description "An alarm. Can be passed to " { $link cancel-alarm } "." } ;

HELP: add-alarm
{ $values { "quot" quotation } { "time" timestamp } { "frequency" { $maybe duration } } { "alarm" alarm } }
{ $description "Creates and registers an alarm. If " { $snippet "frequency" } " is " { $link f } ", this will be a one-time alarm, otherwise it will fire with the given frequency. The quotation will be called from the alarm thread." } ;

HELP: later
{ $values { "quot" quotation } { "duration" duration } { "alarm" alarm } }
{ $description "Creates and registers an alarm which calls the quotation once at " { $snippet "time" } " from now." } ;

HELP: cancel-alarm
{ $values { "alarm" alarm } }
{ $description "Cancels an alarm. Does nothing if the alarm is not active." } ;

HELP: every
{ $values
     { "quot" quotation } { "duration" duration }
     { "alarm" alarm } }
{ $description "Creates and registers an alarm which calls the quotation repeatedly, using " { $snippet "dt" } " as the frequency." } ;

ARTICLE: "alarms" "Alarms"
"The " { $vocab-link "alarms" } " vocabulary provides a lightweight way to schedule one-time and recurring tasks without spawning a new thread."
{ $subsections
    alarm
    add-alarm
    later
    cancel-alarm
}
"Alarms do not persist across image saves. Saving and restoring an image has the effect of calling " { $link cancel-alarm } " on all " { $link alarm } " instances." ;

ABOUT: "alarms"
