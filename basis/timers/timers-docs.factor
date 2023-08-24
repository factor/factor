USING: help.markup help.syntax calendar quotations system ;
IN: timers

HELP: timer
{ $class-description "A timer. Can be passed to " { $link start-timer } ", " { $link stop-timer } " and " { $link restart-timer } "." } ;

HELP: start-timer
{ $values { "timer" timer } }
{ $description "Starts a timer." } ;

HELP: restart-timer
{ $values { "timer" timer } }
{ $description "Starts or restarts a timer. Restarting a timer causes the a sleep of initial delay nanoseconds before looping. An timer's parameters may be modified and restarted with this word." } ;

HELP: stop-timer
{ $values { "timer" timer } }
{ $description "Prevents a timer from calling its quotation again. Has no effect on timers that are not currently running." } ;

HELP: every
{ $values
    { "quot" quotation } { "interval-duration" duration }
    { "timer" timer } }
{ $description "Creates a timer that calls the quotation repeatedly, using " { $snippet "duration" } " as the frequency. The first call of " { $snippet "quot" } " will happen immediately. If the quotation throws an exception, the timer will stop." }
{ $examples
    { $code
        "USING: timers io calendar ;"
        "[ \"Hi Buddy.\" print flush ] 10 seconds every drop"
    }
} ;

HELP: later
{ $values { "quot" quotation } { "delay-duration" duration } { "timer" timer } }
{ $description "Sleeps for " { $snippet "duration" } " and then calls a " { $snippet "quot" } ". The user may cancel the timer before " { $snippet "quot" } " runs. This timer is not repeated." }
{ $examples
    { $code
        "USING: timers io calendar ;"
        "[ \"Break's over!\" print flush ] 15 minutes later drop"
    }
} ;

HELP: delayed-every
{ $values
    { "quot" quotation } { "duration" duration }
    { "timer" timer } }
{ $description "Creates a timer that calls " { $snippet "quot" } " repeatedly, waiting " { $snippet "duration" } " before calling " { $snippet "quot" } " the first time and then waiting " { $snippet "duration" } " between further calls. If the quotation throws an exception, the timer will stop." }
{ $examples
    { $code
        "USING: timers io calendar ;"
        "[ \"Hi Buddy.\" print flush ] 10 seconds every drop"
    }
} ;

ARTICLE: "timers" "Timers"
"The " { $vocab-link "timers" } " vocabulary provides a lightweight way to schedule one-time and recurring tasks. Timers run in a single green thread per timer and consist of a quotation, a delay duration, and an interval duration. After starting a timer, the timer thread sleeps for the delay duration and calls the quotation. Then it waits out the interval duration and calls the quotation again until something stops the timer. If a recurring timer's quotation would be scheduled to run again before the previous quotation has finished processing, the timer will be run again immediately afterwards. This may result in the timer falling behind indefinitely, in which case it will run as often as possible while still allowing other green threads to run. Recurring timers that execute 'on time' or 'catch up' will always be scheduled for an exact multiple of the interval from the original starting time to prevent the timer from drifting over time. Timers use " { $link nano-count } " as the timing primitive, so they will continue to work across system clock changes." $nl
"The timer class:"
{ $subsections timer }
"Create a timer before starting it:"
{ $subsections <timer> }
"Starting a timer:"
{ $subsections start-timer restart-timer }
"Stopping a timer:"
{ $subsections stop-timer }

"A recurring timer without an initial delay:"
{ $subsections every }
"A one-time timer with an initial delay:"
{ $subsections later }
"A recurring timer with an initial delay:"
{ $subsections delayed-every } ;

ABOUT: "timers"
