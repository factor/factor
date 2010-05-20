USING: help.markup help.syntax calendar quotations system ;
IN: alarms

HELP: alarm
{ $class-description "An alarm. Can be passed to " { $link cancel-alarm } "." } ;

HELP: add-alarm
{ $values { "quot" quotation } { "start" duration } { "interval" { $maybe "duration/f" } } { "alarm" alarm } }
{ $description "Creates and registers an alarm to start at " { $snippet "start" } " offset from the current time. If " { $snippet "interval" } " is " { $link f } ", this will be a one-time alarm, otherwise it will fire with the given frequency, with scheduling happening before the quotation is called in order to ensure that the next event will happen on time. The quotation will be called from a new thread spawned by the alarm thread. If a repeated alarm's quotation throws an exception, the alarm will not be rescheduled." } ;

HELP: later
{ $values { "quot" quotation } { "duration" duration } { "alarm" alarm } }
{ $description "Creates and registers an alarm which calls the quotation once at " { $snippet "duration" } " offset from now." }
{ $examples
    { $unchecked-example
        "USING: alarms io calendar ;"
        """[ "Break's over!" print flush ] 15 minutes later drop"""
        ""
    }
} ;

HELP: later*
{ $values { "quot" quotation } { "duration" duration } { "alarm" alarm } }
{ $description "Creates and registers an alarm which calls the quotation once at " { $snippet "duration" } " offset from now. The alarm is passed to the quotation as an input." }
{ $examples
    { $unchecked-example
        "USING: alarms io calendar ;"
        """[ cancel-alarm "Break's over!" print flush ] 15 minutes later* drop"""
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
{ $description "Creates and registers an alarm which calls the quotation repeatedly, using " { $snippet "dt" } " as the frequency. If the quotation throws an exception that is not caught inside it, the alarm scheduler will cancel the alarm and will not reschedule it again." }
{ $examples
    { $unchecked-example
        "USING: alarms io calendar ;"
        """[ "Hi Buddy." print flush ] 10 seconds every drop"""
        ""
    }
} ;

HELP: every*
{ $values
     { "quot" quotation } { "duration" duration }
     { "alarm" alarm } }
{ $description "Creates and registers an alarm which calls the quotation repeatedly, using " { $snippet "dt" } " as the frequency. The alarm is passed as an input to the quotation. If the quotation throws an exception that is not caught inside it, the alarm scheduler will cancel the alarm and will not reschedule it again." }
{ $examples
    "Cancelling an alarm from within the alarm:"
    { $unchecked-example
        "USING: alarms io calendar inspector ;"
        """[ cancel-alarm "Hi Buddy." print flush ] 10 seconds every* drop"""
        ""
    }
} ;

ARTICLE: "alarms" "Alarms"
"The " { $vocab-link "alarms" } " vocabulary provides a lightweight way to schedule one-time and recurring tasks. Alarms use " { $link nano-count } " as the timing primitive, so they will continue to work across system clock changes. Alarms run in a single green thread per alarm. If a recurring alarm's quotation would be scheduled to run again before the previous quotation has finished processing, the alarm will be run again immediately afterwards. This may result in the alarm falling behind indefinitely, in which case the it will run as often as possible while still allowing other green threads to run. Finally, recurring alarms that execute 'on time' or 'catch up' will always be scheduled for an exact multiple of the interval from the original starting time, which prevents the alarm from drifting over time." $nl
"The alarm class:"
{ $subsections alarm }
"Register a recurring alarm:"
{ $subsections every every* }
"Register a one-time alarm:"
{ $subsections later later* }
"Low-level interface to add alarms:"
{ $subsections add-alarm }
"Cancelling an alarm:"
{ $subsections cancel-alarm }
"Alarms do not persist across image saves. Saving and restoring an image has the effect of calling " { $link cancel-alarm } " on all " { $link alarm } " instances." ;

ABOUT: "alarms"
