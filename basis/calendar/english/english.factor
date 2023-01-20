! Copyright (C) 2007 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs calendar kernel math sequences summary ;
IN: calendar.english

CONSTANT: month-names
    {
        "January" "February" "March" "April" "May" "June"
        "July" "August" "September" "October" "November" "December"
    }

ERROR: not-a-month ;
M: not-a-month summary
    drop "Months are indexed starting at 1" ;

: check-month ( n -- n )
    [ not-a-month ] when-zero ;

GENERIC: month-name ( obj -- string )

M: integer month-name check-month 1 - month-names nth ;
M: timestamp month-name month>> 1 - month-names nth ;

ERROR: not-a-month-abbreviation string ;

CONSTANT: month-abbreviations
    {
        "Jan" "Feb" "Mar" "Apr" "May" "Jun"
        "Jul" "Aug" "Sep" "Oct" "Nov" "Dec"
    }

CONSTANT: month-abbreviations-hash
    H{
        { "Jan" 1 } { "Feb" 2 } { "Mar" 3 }
        { "Apr" 4 } { "May" 5 } { "Jun" 6 }
        { "Jul" 7 } { "Aug" 8 } { "Sep" 9 }
        { "Oct" 10 } { "Nov" 11 } { "Dec" 12 }
    }

: month-abbreviation ( n -- string )
    check-month 1 - month-abbreviations nth ;

: month-abbreviation-index ( string -- n )
    month-abbreviations-hash ?at
    [ not-a-month-abbreviation ] unless ;

CONSTANT: day-names
    { "Sunday" "Monday" "Tuesday" "Wednesday" "Thursday" "Friday" "Saturday" }

CONSTANT: day-abbreviations2
    { "Su" "Mo" "Tu" "We" "Th" "Fr" "Sa" }

: day-abbreviation2 ( n -- string )
    day-abbreviations2 nth ; inline

CONSTANT: day-abbreviations3
    { "Sun" "Mon" "Tue" "Wed" "Thu" "Fri" "Sat" }

CONSTANT: day-abbreviations3-hash
    H{
        { "Sun" 0 } { "Mon" 1 } { "Tue" 2 } { "Wed" 3 }
        { "Thu" 4 } { "Fri" 5 } { "Sat" 6 }
    }

CONSTANT: day-predicates
    { sunday? monday? tuesday? wednesday? thursday? friday? saturday? }

: day-predicate ( string -- predicate )
    day-predicates nth ;

: day-abbreviation3 ( n -- string )
    day-abbreviations3 nth ; inline

ERROR: not-a-day-abbreviation string ;

: day-abbreviation3-index ( string -- n )
    day-abbreviations3-hash ?at [ not-a-day-abbreviation ] unless ; inline

: day-abbreviation3-predicate ( string -- predicate )
    day-abbreviation3-index day-predicates nth ;

GENERIC: day-name ( obj -- string )
M: integer day-name day-names nth ;
M: timestamp day-name day-of-week day-names nth ;
