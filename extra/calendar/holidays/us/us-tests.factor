! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: calendar calendar.holidays calendar.holidays.us kernel
sequences tools.test ;

{ 11 } [ 2022 us-federal holidays length ] unit-test

{
    {
        T{ timestamp { year 2022 } { month 1 } { day 1 } }
        T{ timestamp { year 2022 } { month 1 } { day 17 } }
        T{ timestamp { year 2022 } { month 2 } { day 21 } }
        T{ timestamp { year 2022 } { month 5 } { day 30 } }
        T{ timestamp { year 2022 } { month 6 } { day 20 } }
        T{ timestamp { year 2022 } { month 7 } { day 4 } }
        T{ timestamp { year 2022 } { month 9 } { day 5 } }
        T{ timestamp { year 2022 } { month 10 } { day 10 } }
        T{ timestamp { year 2022 } { month 11 } { day 11 } }
        T{ timestamp { year 2022 } { month 11 } { day 24 } }
        T{ timestamp { year 2022 } { month 12 } { day 26 } }
    }
} [
    2022 <year-gmt> timestamp>year-dates-gmt [ us-federal holiday? ] filter
] unit-test

