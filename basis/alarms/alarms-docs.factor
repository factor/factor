USING: help.markup help.syntax calendar quotations ;
IN: alarms

HELP: alarm
{ $class-description "An alarm. Can be passed to " { $link cancel-alarm } "." } ;

HELP: add-alarm
{ $values { "quot" quotation } { "start" duration } { "interval" { $maybe "duration/f" } } { "alarm" alarm } }
{ $description "Creates and registers an alarm to start at " { $snippet "start" } " offset from the current time. If " { $snippet "interval" } " is " { $link f } ", this will be a one-time alarm, otherwise it will fire with the given frequency, with scheduling happening before the quotation is called in order to ensure that the next event will happen on time. The quotation will be called from the alarm thread." } ;

HELP: later
{ $values { "quot" quotation } { "duration" duration } { "alarm" alarm } }
{ $description "Creates and registers an alarm which calls the quotation once at " { $snippet "duration" } " offset from now." }
{ $examples
    { $unchecked-example
        "USING: alarms io calendar ;"
        """[ "Break's over!" print flush ] 15 minutes drop"""
        ""
    }
} ;

HELP: cancel-alarm
{ $values { "alarm" alarm } }
{ $description "Cancels an alarm. Does nothing if the alarm is not active." } ;

HELP: every
{ $values
     { "quot" quotation } { "duration" duration }
     { "alarm" alarm } }
{ $description "Creates and registers an alarm which calls the quotation repeatedly, using " { $snippet "dt" } " as the frequency." }
{ $examples
    { $unchecked-example
        "USING: alarms io calendar ;"
        """[ "Hi Buddy." print flush ] 10 seconds every drop"""
        ""
    }
} ;

ARTICLE: "alarms" "Alarms"
"The " { $vocab-link "alarms" } " vocabulary provides a lightweight way to schedule one-time and recurring tasks without spawning a new thread. Alarms use " { $vocab-link "monotonic-clock" } ", so they continue to work across system clock changes." $nl
"The alarm class:"
{ $subsections alarm }
"Register a recurring alarm:"
{ $subsections every }
"Register a one-time alarm:"
{ $subsections later }
"Low-level interface to add alarms:"
{ $subsections add-alarm }
"Cancelling an alarm:"
{ $subsections cancel-alarm }
"Alarms do not persist across image saves. Saving and restoring an image has the effect of calling " { $link cancel-alarm } " on all " { $link alarm } " instances." ;

ABOUT: "alarms"
