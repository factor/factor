USING: help.markup help.syntax calendar quotations ;
IN: alarms

HELP: alarm
{ $class-description "An alarm. Can be passed to " { $link cancel-alarm } "." } ;

HELP: add-alarm
{ $values { "quot" quotation } { "time" timestamp } { "frequency" { $maybe duration } } { "alarm" alarm } }
{ $description "Creates and registers an alarm to start at " { $snippet "time" } ". If " { $snippet "frequency" } " is " { $link f } ", this will be a one-time alarm, otherwise it will fire with the given frequency. The quotation will be called from the alarm thread." } ;

HELP: later
{ $values { "quot" quotation } { "duration" duration } { "alarm" alarm } }
{ $description "Creates and registers an alarm which calls the quotation once at " { $snippet "time" } " from now." }
{ $examples
    { $unchecked-example
        "USING: alarms io calendar ;"
        """[ "GET BACK TO WORK, Guy." print flush ] 10 minutes later drop"""
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
"The " { $vocab-link "alarms" } " vocabulary provides a lightweight way to schedule one-time and recurring tasks without spawning a new thread." $nl
"The alarm class:"
{ $subsections
    alarm
}
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
