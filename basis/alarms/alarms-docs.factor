USING: help.markup help.syntax calendar quotations system ;
IN: alarms

HELP: alarm
{ $class-description "An alarm. Can be passed to " { $link cancel-alarm } "." } ;

HELP: current-alarm
{ $description "A symbol that contains the currently executing alarm, availble only to the alarm quotation. One use for this symbol is if a repeated alarm wishes to cancel itself from executing in the future."
}
{ $examples
    { $unchecked-example
        """USING: alarms calendar io threads ;"""
        """["""
        """    "Hi, this should only get printed once..." print flush"""
        """    current-alarm get cancel-alarm"""
        """] 1 seconds every"""
        ""
    }
} ;

HELP: add-alarm
{ $values { "quot" quotation } { "start" duration } { "interval" { $maybe "duration/f" } } { "alarm" alarm } }
{ $description "Creates and registers an alarm to start at " { $snippet "start" } " offset from the current time. If " { $snippet "interval" } " is " { $link f } ", this will be a one-time alarm, otherwise it will fire with the given frequency, with scheduling happening before the quotation is called in order to ensure that the next event will happen on time. The quotation will be called from a new thread spawned by the alarm thread. If a repeated alarm's quotation throws an exception, the alarm will not be rescheduled." } ;

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
{ $description "Creates and registers an alarm which calls the quotation repeatedly, using " { $snippet "dt" } " as the frequency. If the quotation throws an exception that is not caught inside it, the alarm scheduler will cancel the alarm and will not reschedule it again." }
{ $examples
    { $unchecked-example
        "USING: alarms io calendar ;"
        """[ "Hi Buddy." print flush ] 10 seconds every drop"""
        ""
    }
} ;

ARTICLE: "alarms" "Alarms"
"The " { $vocab-link "alarms" } " vocabulary provides a lightweight way to schedule one-time and recurring tasks without spawning a new thread. Alarms use " { $link nano-count } ", so they continue to work across system clock changes." $nl
"The alarm class:"
{ $subsections alarm }
"Register a recurring alarm:"
{ $subsections every }
"Register a one-time alarm:"
{ $subsections later }
"The currently executing alarm:"
{ $subsections current-alarm }
"Low-level interface to add alarms:"
{ $subsections add-alarm }
"Cancelling an alarm:"
{ $subsections cancel-alarm }
"Alarms do not persist across image saves. Saving and restoring an image has the effect of calling " { $link cancel-alarm } " on all " { $link alarm } " instances." ;

ABOUT: "alarms"
