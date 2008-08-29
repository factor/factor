! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel math strings help.markup help.syntax
calendar.backend ;
IN: calendar

HELP: duration
{ $description "A duration is a period of time years, months, days, hours, minutes, and seconds.  All duration slots can store " { $link real } " numbers." } ;

HELP: timestamp
{ $description "A timestamp is a date and a time with a timezone offset.  Timestamp slots must store integers except for " { $snippet "seconds" } ", which stores reals, and " { $snippet "gmt-offset" } ", which stores a " { $link duration } "." } ;

{ timestamp duration } related-words

HELP: gmt-offset-duration
{ $values { "duration" duration } }
{ $description "Returns a " { $link duration } " object with the GMT offset returned by " { $link gmt-offset } "." } ;

HELP: <date>
{ $values { "year" integer } { "month" integer } { "day" integer } { "timestamp" timestamp } }
{ $description "Returns a timestamp object representing the start of the specified day in your current timezone." }
{ $examples
    { $example "USING: calendar prettyprint ;"
               "12 25 2010 <date> ."
                "T{ timestamp f 12 25 2010 0 0 0 T{ duration f 0 0 0 -5 0 0 } }"
    }
} ;

HELP: month-names
{ $values { "array" array } }
{ $description "Returns an array with the English names of all the months. January has a index of 1 instead of 0." } ;
