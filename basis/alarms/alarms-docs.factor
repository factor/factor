USING: help.markup help.syntax calendar quotations system ;
IN: alarms

HELP: alarm
{ $class-description "An alarm. Can be passed to " { $link stop-alarm } "." } ;

HELP: start-alarm
{ $values { "alarm" alarm } }
{ $description "Starts an alarm." } ;

HELP: restart-alarm
{ $values { "alarm" alarm } }
{ $description "Starts or restarts an alarm. Restarting an alarm causes the a sleep of initial delay nanoseconds before looping. An alarm's parameters may be modified and restarted with this word." } ;

HELP: stop-alarm
{ $values { "alarm" alarm } }
{ $description "Prevents an alarm from calling its quotation again. Has no effect on alarms that are not currently running." } ;

HELP: every
{ $values
     { "quot" quotation } { "interval-duration" duration }
     { "alarm" alarm } }
{ $description "Creates an alarm that calls the quotation repeatedly, using " { $snippet "duration" } " as the frequency. The first call of " { $snippet "quot" } " will happen immediately. If the quotation throws an exception, the alarm will stop." }
{ $examples
    { $unchecked-example
        "USING: alarms io calendar ;"
        """[ "Hi Buddy." print flush ] 10 seconds every drop"""
        ""
    }
} ;

HELP: later
{ $values { "quot" quotation } { "delay-duration" duration } { "alarm" alarm } }
{ $description "Sleeps for " { $snippet "duration" } " and then calls a " { $snippet "quot" } ". The user may cancel the alarm before " { $snippet "quot" } " runs. This alarm is not repeated." }
{ $examples
    { $unchecked-example
        "USING: alarms io calendar ;"
        """[ "Break's over!" print flush ] 15 minutes later drop"""
        ""
    }
} ;

HELP: delayed-every
{ $values
     { "quot" quotation } { "duration" duration }
     { "alarm" alarm } }
{ $description "Creates an alarm that calls " { $snippet "quot" } " repeatedly, waiting " { $snippet "duration" } " before calling " { $snippet "quot" } " the first time and then waiting " { $snippet "duration" } " between further calls. If the quotation throws an exception, the alarm will stop." }
{ $examples
    { $unchecked-example
        "USING: alarms io calendar ;"
        """[ "Hi Buddy." print flush ] 10 seconds every drop"""
        ""
    }
} ;

ARTICLE: "alarms" "Alarms"
"The " { $vocab-link "alarms" } " vocabulary provides a lightweight way to schedule one-time and recurring tasks. Alarms run in a single green thread per alarm and consist of a quotation, a delay duration, and an interval duration. After starting an alarm, the alarm thread sleeps for the delay duration and calls the quotation. Then it waits out the interval duration and calls the quotation again until something stops the alarm. If a recurring alarm's quotation would be scheduled to run again before the previous quotation has finished processing, the alarm will be run again immediately afterwards. This may result in the alarm falling behind indefinitely, in which case the it will run as often as possible while still allowing other green threads to run. Recurring alarms that execute 'on time' or 'catch up' will always be scheduled for an exact multiple of the interval from the original starting time to prevent the alarm from drifting over time. Alarms use " { $link nano-count } " as the timing primitive, so they will continue to work across system clock changes." $nl
"The alarm class:"
{ $subsections alarm }
"Create an alarm before starting it:"
{ $subsections <alarm> }
"Starting an alarm:"
{ $subsections start-alarm restart-alarm }
"Stopping an alarm:"
{ $subsections stop-alarm }

"A recurring alarm without an initial delay:"
{ $subsections every }
"A one-time alarm with an initial delay:"
{ $subsections later }
"A recurring alarm with an initial delay:"
{ $subsections delayed-every } ;

ABOUT: "alarms"
