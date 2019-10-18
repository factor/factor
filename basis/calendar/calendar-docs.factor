! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel math strings help.markup help.syntax
math.order ;
IN: calendar

HELP: duration
{ $description "A duration is a period of time years, months, days, hours, minutes, and seconds. All duration slots can store " { $link real } " numbers. Compare two durations with the " { $link <=> } " word." } ;

HELP: timestamp
{ $description "A timestamp is a date and a time with a timezone offset. Timestamp slots must store integers except for " { $snippet "seconds" } ", which stores reals, and " { $snippet "gmt-offset" } ", which stores a " { $link duration } ". Compare two durations with the " { $link <=> } " word." } ;

{ timestamp duration } related-words

HELP: gmt-offset-duration
{ $values { "duration" duration } }
{ $description "Returns a " { $link duration } " object with the GMT offset returned by " { $link gmt-offset } "." } ;

HELP: <date>
{ $values { "year" integer } { "month" integer } { "day" integer } { "timestamp" timestamp } }
{ $description "Returns a timestamp object representing the start of the specified day in your current timezone." }
{ $examples
    { $example "USING: accessors calendar prettyprint ;"
               "2010 12 25 <date> instant >>gmt-offset ."
               "T{ timestamp { year 2010 } { month 12 } { day 25 } }"
    }
} ;

HELP: average-month
{ $values { "value" ratio } }
{ $description "The length of an average month averaged over 400 years. Used internally for adding an arbitrary real number of months to a timestamp." } ;

HELP: months-per-year
{ $values { "value" integer } }
{ $description "Returns the number of months in a year." } ;

HELP: days-per-year
{ $values { "value" ratio } }
{ $description "Returns the number of days in a year averaged over 400 years. Used internally for adding an arbitrary real number of days to a timestamp." } ;

HELP: hours-per-year
{ $values { "value" ratio } }
{ $description "Returns the number of hours in a year averaged over 400 years. Used internally for adding an arbitrary real number of hours to a timestamp." } ;

HELP: minutes-per-year
{ $values { "value" ratio } }
{ $description "Returns the number of minutes in a year averaged over 400 years. Used internally for adding an arbitrary real number of minutes to a timestamp." } ;

HELP: seconds-per-year
{ $values { "value" integer } }
{ $description "Returns the number of seconds in a year averaged over 400 years. Used internally for adding an arbitrary real number of seconds to a timestamp." } ;

HELP: julian-day-number
{ $values { "year" integer } { "month" integer } { "day" integer } { "n" integer } }
{ $description "Calculates the Julian day number from a year, month, and day. The difference between two Julian day numbers is the number of days that have elapsed between the two corresponding dates." }
{ $warning "Not valid before year -4800 BCE." } ;

HELP: julian-day-number>date
{ $values { "n" integer } { "year" integer } { "month" integer } { "day" integer } }
{ $description "Converts from a Julian day number back to a year, month, and day." } ;
{ julian-day-number julian-day-number>date } related-words

HELP: >date<
{ $values { "timestamp" timestamp } { "year" integer } { "month" integer } { "day" integer } }
{ $description "Explodes a " { $snippet "timestamp" } " into its year, month, and day components." }
{ $examples { $example "USING: arrays calendar prettyprint ;"
                       "2010 8 24 <date> >date< 3array ."
                       "{ 2010 8 24 }"
                       }
} ;

HELP: >time<
{ $values { "timestamp" timestamp } { "hour" integer } { "minute" integer } { "second" integer } }
{ $description "Explodes a " { $snippet "timestamp" } " into its hour, minute, and second components." }
{ $examples { $example "USING: arrays calendar prettyprint ;"
                       "now noon >time< 3array ."
                       "{ 12 0 0 }"
                       }
} ;

{ >date< >time< } related-words

HELP: instant
{ $values { "duration" duration } }
{ $description "Pushes a " { $snippet "duration" } " of zero seconds." } ;

HELP: years
{ $values { "x" number } { "duration" duration } }
{ $description "Creates a duration object with the specified number of years." } ;

HELP: months
{ $values { "x" number } { "duration" duration } }
{ $description "Creates a duration object with the specified number of months." } ;

HELP: days
{ $values { "x" number } { "duration" duration } }
{ $description "Creates a duration object with the specified number of days." } ;

HELP: weeks
{ $values { "x" number } { "duration" duration } }
{ $description "Creates a duration object with the specified number of weeks." } ;

HELP: hours
{ $values { "x" number } { "duration" duration } }
{ $description "Creates a duration object with the specified number of hours." } ;

HELP: minutes
{ $values { "x" number } { "duration" duration } }
{ $description "Creates a duration object with the specified number of minutes." } ;

HELP: seconds
{ $values { "x" number } { "duration" duration } }
{ $description "Creates a duration object with the specified number of seconds." } ;

HELP: milliseconds
{ $values { "x" number } { "duration" duration } }
{ $description "Creates a duration object with the specified number of milliseconds." } ;

HELP: microseconds
{ $values { "x" number } { "duration" duration } }
{ $description "Creates a duration object with the specified number of microseconds." } ;

HELP: nanoseconds
{ $values { "x" number } { "duration" duration } }
{ $description "Creates a duration object with the specified number of nanoseconds." } ;

{ years months days hours minutes seconds milliseconds microseconds nanoseconds } related-words

HELP: leap-year?
{ $values { "obj" object } { "?" boolean } }
{ $description "Returns " { $link t } " if the object represents a leap year." }
{ $examples
    { $example "USING: calendar prettyprint ;"
               "2008 leap-year? ."
               "t"
    }
    { $example "USING: calendar prettyprint ;"
               "2010 1 1 <date> leap-year? ."
               "f"
    }
} ;

HELP: time+
{ $values { "time1" "timestamp or duration" } { "time2" "timestamp or duration" } { "time3" "timestamp or duration" } }
{ $description "Adds two durations to produce a duration or adds a timestamp and a duration to produce a timestamp. The calculation takes timezones into account." }
{ $examples
    { $example "USING: calendar math.order prettyprint ;"
               "10 months 2 months time+ 1 years <=> ."
               "+eq+"
    }
    { $example "USING: accessors calendar math.order prettyprint ;"
               "2010 1 1 <date> 3 days time+ day>> ."
               "4"
    }
} ;

HELP: duration>years
{ $values { "duration" duration } { "x" number } }
{ $description "Calculates the length of a duration in years." }
{ $examples
    { $example "USING: calendar prettyprint ;"
               "6 months duration>years ."
               "1/2"
    }
} ;

HELP: duration>months
{ $values { "duration" duration } { "x" number } }
{ $description "Calculates the length of a duration in months." }
{ $examples
    { $example "USING: calendar prettyprint ;"
               "30 days duration>months ."
               "16000/16233"
    }
} ;

HELP: duration>days
{ $values { "duration" duration } { "x" number } }
{ $description "Calculates the length of a duration in days." }
{ $examples
    { $example "USING: calendar prettyprint ;"
               "6 hours duration>days ."
               "1/4"
    }
} ;

HELP: duration>hours
{ $values { "duration" duration } { "x" number } }
{ $description "Calculates the length of a duration in hours." }
{ $examples
    { $example "USING: calendar prettyprint ;"
               "3/4 days duration>hours ."
               "18"
    }
} ;
HELP: duration>minutes
{ $values { "duration" duration } { "x" number } }
{ $description "Calculates the length of a duration in minutes." }
{ $examples
    { $example "USING: calendar prettyprint ;"
               "6 hours duration>minutes ."
               "360"
    }
} ;
HELP: duration>seconds
{ $values { "duration" duration } { "x" number } }
{ $description "Calculates the length of a duration in seconds." }
{ $examples
    { $example "USING: calendar prettyprint ;"
               "6 minutes duration>seconds ."
               "360"
    }
} ;

HELP: duration>milliseconds
{ $values { "duration" duration } { "x" number } }
{ $description "Calculates the length of a duration in milliseconds." }
{ $examples
    { $example "USING: calendar prettyprint ;"
               "6 seconds duration>milliseconds ."
               "6000"
    }
} ;

HELP: duration>microseconds
{ $values { "duration" duration } { "x" number } }
{ $description "Calculates the length of a duration in microseconds." }
{ $examples
    { $example "USING: calendar prettyprint ;"
               "6 seconds duration>microseconds ."
               "6000000"
    }
} ;

HELP: duration>nanoseconds
{ $values { "duration" duration } { "x" number } }
{ $description "Calculates the length of a duration in nanoseconds." }
{ $examples
    { $example "USING: calendar prettyprint ;"
               "6 seconds duration>nanoseconds ."
               "6000000000"
    }
} ;

{ duration>years duration>months duration>days duration>hours duration>minutes duration>seconds duration>milliseconds duration>microseconds duration>nanoseconds } related-words


HELP: time-
{ $values { "time1" "timestamp or duration" } { "time2" "timestamp or duration" } { "time3" "timestamp or duration" } }
{ $description "Subtracts two durations to produce a duration or subtracts a duration from a timestamp to produce a timestamp. The calculation takes timezones into account." }
{ $examples
    { $example "USING: calendar math.order prettyprint ;"
               "10 months 2 months time- 8 months <=> ."
               "+eq+"
    }
    { $example "USING: accessors calendar math.order prettyprint ;"
               "2010 1 1 <date> 3 days time- day>> ."
               "29"
    }
} ;

HELP: convert-timezone
{ $values { "timestamp" timestamp } { "duration" duration } { "timestamp'" timestamp } }
{ $description "Converts the " { $snippet "timestamp" } "'s " { $snippet "gmt-offset" } " to the GMT offset represented by the " { $snippet "duration" } "." }
{ $examples
    { $example "USING: accessors calendar prettyprint ;"
               "gmt noon instant -5 >>hour convert-timezone gmt-offset>> hour>> ."
               "-5"
    }
} ;

HELP: >local-time
{ $values { "timestamp" timestamp } { "timestamp'" timestamp } }
{ $description "Converts the " { $snippet "timestamp" } " to the timezone of your computer." }
{ $examples
    { $example "USING: accessors calendar kernel prettyprint ;"
               "now gmt >local-time [ gmt-offset>> ] same? ."
               "t"
    }
} ;

HELP: >gmt
{ $values { "timestamp" timestamp } { "timestamp'" timestamp } }
{ $description "Converts the " { $snippet "timestamp" } " to the GMT timezone." }
{ $examples
    { $example "USING: accessors calendar kernel prettyprint ;"
               "now >gmt gmt-offset>> hour>> ."
               "0"
    }
} ;

HELP: time*
{ $values { "obj1" object } { "obj2" object } { "obj3" object } }
{ $description "Multiplies each time slot of a timestamp or duration by a number and make a new duration from the result. Used in the implementation of " { $link before } "." } ;
{ time+ time- time* } related-words

HELP: before
{ $values { "duration" duration } { "-duration" duration } }
{ $description "Negates a duration." }
{ $examples
    { $example "USING: accessors calendar prettyprint ;"
               "3 hours before now noon time+ hour>> ."
               "9"
    }
} ;

HELP: unix-1970
{ $values { "timestamp" timestamp } }
{ $description "Returns the beginning of UNIX time, or midnight, January 1, 1970." } ;

HELP: micros>timestamp
{ $values { "x" number } { "timestamp" timestamp } }
{ $description "Converts a number of microseconds into a timestamp value in GMT time." }
{ $examples
    { $example "USING: accessors calendar prettyprint ;"
               "1000 micros>timestamp year>> ."
               "1970"
    }
} ;

HELP: gmt
{ $values { "timestamp" timestamp } }
{ $description "Returns the time right now, but in the GMT timezone." } ;

{ gmt now } related-words

HELP: now
{ $values { "timestamp" timestamp } }
{ $description "Returns the time right now in your computer's timezone." }
{ $examples
    { $unchecked-example "USING: calendar prettyprint ;"
        "now ."
         "T{ timestamp f 2008 9 1 16 38 24+801/1000 T{ duration f 0 0 0 -5 0 0 } }"
    }
} ;

HELP: hence
{ $values { "duration" duration } { "timestamp" timestamp } }
{ $description "Computes a time in the future that is the " { $snippet "duration" } " added to the result of " { $link now } "." }
{ $examples
    { $unchecked-example
       "USING: calendar prettyprint ;"
       "10 hours hence ."
       "T{ timestamp f 2008 9 2 2 47 45+943/1000 T{ duration f 0 0 0 -5 0 0 } }"
    }
} ;

HELP: ago
{ $values { "duration" duration } { "timestamp" timestamp } }
{ $description "Computes a time in the past that is the " { $snippet "duration" } " subtracted from the result of " { $link now } "." }
{ $examples
    { $unchecked-example
       "USING: calendar prettyprint ;"
       "3 weeks ago ."
       "T{ timestamp f 2008 8 11 16 49 52+99/500 T{ duration f 0 0 0 -5 0 0 } }"
    }
} ;

HELP: zeller-congruence
{ $values { "year" integer } { "month" integer } { "day" integer } { "n" integer } }
{ $description "An implementation of an algorithm that computes the day of the week given a date. Days are indexed starting from Sunday, which is index 0." }
{ $notes "User code should use the " { $link day-of-week } " word, which takes a " { $snippet "timestamp" } " instead of integers." } ;

HELP: days-in-year
{ $values { "obj" "a timestamp or an integer" } { "n" integer } }
{ $description "Calculates the number of days in a given year." }
{ $examples
    { $example "USING: calendar prettyprint ;"
               "2004 days-in-year ."
               "366"
    }
} ;

HELP: days-in-month
{ $values { "timestamp" timestamp } { "n" integer } }
{ $description "Calculates the number of days in a given month." }
{ $examples
    { $example "USING: calendar prettyprint ;"
               "2008 8 24 <date> days-in-month ."
               "31"
    }
} ;

HELP: day-of-week
{ $values { "timestamp" timestamp } { "n" integer } }
{ $description "Calculates the index of the day of the week. Sunday will result in an index of 0." }
{ $examples
    { $example "USING: calendar prettyprint ;"
               "now sunday day-of-week ."
               "0"
    }
} ;

HELP: day-of-year
{ $values { "timestamp" timestamp } { "n" integer } }
{ $description "Calculates the day of the year, resulting in a number from 1 to 366 (leap years)." }
{ $examples
    { $example "USING: calendar prettyprint ;"
               "2008 1 4 <date> day-of-year ."
               "4"
    }
} ;

HELP: sunday
{ $values { "timestamp" timestamp } { "new-timestamp" timestamp } }
{ $description "Returns the Sunday from the current week, which starts on a Sunday." } ;

HELP: monday
{ $values { "timestamp" timestamp } { "new-timestamp" timestamp } }
{ $description "Returns the Monday from the current week, which starts on a Sunday." } ;

HELP: tuesday
{ $values { "timestamp" timestamp } { "new-timestamp" timestamp } }
{ $description "Returns the Tuesday from the current week, which starts on a Sunday." } ;

HELP: wednesday
{ $values { "timestamp" timestamp } { "new-timestamp" timestamp } }
{ $description "Returns the Wednesday from the current week, which starts on a Sunday." } ;

HELP: thursday
{ $values { "timestamp" timestamp } { "new-timestamp" timestamp } }
{ $description "Returns the Thursday from the current week, which starts on a Sunday." } ;

HELP: friday
{ $values { "timestamp" timestamp } { "new-timestamp" timestamp } }
{ $description "Returns the Friday from the current week, which starts on a Sunday." } ;

HELP: saturday
{ $values { "timestamp" timestamp } { "new-timestamp" timestamp } }
{ $description "Returns the Saturday from the current week, which starts on a Sunday." } ;

{ sunday monday tuesday wednesday thursday friday saturday } related-words

HELP: midnight
{ $values { "timestamp" timestamp } { "new-timestamp" timestamp } }
{ $description "Returns a new timestamp that represents the day at midnight, or the beginning of the day." } ;

HELP: noon
{ $values { "timestamp" timestamp } { "new-timestamp" timestamp } }
{ $description "Returns a new timestamp that represents the day at noon, or the middle of the day." } ;

HELP: today
{ $values { "timestamp" timestamp } }
{ $description "Returns a timestamp that represents today at midnight." } ;

HELP: beginning-of-month
{ $values { "timestamp" timestamp } { "new-timestamp" timestamp } }
{ $description "Returns a new timestamp with the day set to one." } ;

HELP: beginning-of-week
{ $values { "timestamp" timestamp } { "new-timestamp" timestamp } }
{ $description "Returns a new timestamp where the day of the week is Sunday." } ;

HELP: beginning-of-year
{ $values { "object" object } { "new-timestamp" timestamp } }
{ $description "Returns a new timestamp with the month and day set to one, or January 1 of the input timestamp, given a year or a timestamp." } ;

HELP: time-since-midnight
{ $values { "timestamp" timestamp } { "duration" duration } }
{ $description "Calculates a " { $snippet "duration" } " that represents the elapsed time since midnight of the input " { $snippet "timestamp" } "." } ;

HELP: since-1970
{ $values
     { "duration" duration }
     { "timestamp" timestamp } }
{ $description "Adds the duration to the beginning of Unix time and returns the result as a timestamp." } ;

ARTICLE: "calendar" "Calendar"
"The " { $vocab-link "calendar" } " vocabulary defines two data types and a set of operations on them:"
{ $subsections
    timestamp
    duration
}
"Durations represent spans of time:"
{ $subsections "using-durations" }
"Arithmetic on timestamps and durations:"
{ $subsections "timestamp-arithmetic" }
"Getting the current timestamp:"
{ $subsections
    now
    gmt
}
"Time zones:"
{ $subsections
    >local-time
    >gmt
    convert-timezone
}
"Timestamps relative to each other:"
{ $subsections "relative-timestamps" }
"Operations on units of time:"
{ $subsections
    "years"
    "months"
    "days"
}
"Both " { $link timestamp } "s and " { $link duration } "s implement the " { $link "math.order" } "."
$nl
"Meta-data about the calendar:"
{ $subsections "calendar-facts" } ;

ARTICLE: "timestamp-arithmetic" "Timestamp arithmetic"
"Adding timestamps and durations, or durations and durations:"
{ $subsections time+ }
"Subtracting:"
{ $subsections time- }
"Element-wise multiplication:"
{ $subsections time* } ;

ARTICLE: "using-durations" "Using durations"
"Creating a duration object:"
{ $subsections
    years
    months
    weeks
    days
    hours
    minutes
    seconds
    milliseconds
    microseconds
    nanoseconds
    instant
}
"Converting a duration to a number:"
{ $subsections
    duration>years
    duration>months
    duration>days
    duration>hours
    duration>minutes
    duration>seconds
    duration>milliseconds
    duration>microseconds
    duration>nanoseconds
} ;

ARTICLE: "relative-timestamps" "Relative timestamps"
"In the future:"
{ $subsections hence }
"In the past:"
{ $subsections ago }
"Invert a duration:"
{ $subsections before }
"Days of the week relative to " { $link now } ":"
{ $subsections
    sunday
    monday
    tuesday
    wednesday
    thursday
    friday
    saturday
}
"New timestamps relative to calendar events:"
{ $subsections
    beginning-of-year
    beginning-of-month
    beginning-of-week
    midnight
    noon
} ;

ARTICLE: "calendar-facts" "Calendar facts"
"Calendar facts:"
{ $subsections
    average-month
    months-per-year
    days-per-year
    hours-per-year
    minutes-per-year
    seconds-per-year
    days-in-month
    day-of-year
    day-of-week
}
"Calculating a Julian day number:"
{ $subsections julian-day-number }
"Calculate a timestamp:"
{ $subsections julian-day-number>date } ;

ARTICLE: "years" "Year operations"
"Leap year predicate:"
{ $subsections leap-year? }
"Find the number of days in a year:"
{ $subsections days-in-year } ;

ABOUT: "calendar"
