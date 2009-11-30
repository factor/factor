! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math ;
IN: monotonic-clock

HELP: monotonic-count
{ $values
    
    { "n" integer }
}
{ $description "Returns a monotonically increasing number of nanoseconds since an arbitrary time. This number can be compared against future calls to " { $link monotonic-count } "." } ;

ARTICLE: "monotonic-clock" "Monotonic clock"
"The " { $vocab-link "monotonic-clock" } " vocabulary implements a single word which can be used as a clock. A special property of this clock is that it is independent of the system time and time zones." $nl
"Get the number of nanoseconds since an arbitrary beginning:"
{ $subsections monotonic-count } ;

ABOUT: "monotonic-clock"
