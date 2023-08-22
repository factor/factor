USING: arrays calendar calendar.ranges kernel tools.test ;

! from>to (empty)
{ { } } [
    now-utc dup 10 minutes time- 1 seconds <timestamp-range> >array
] unit-test

! from=to (length=1)
{ t } [
    now-utc
    [ 1array ] [ dup 1 seconds <timestamp-range> >array ] bi
    =
] unit-test

! forwards
{
    {
        T{ timestamp { year 2023 } { month 6 } { day 21 } }
        T{ timestamp { year 2023 } { month 6 } { day 22 } }
        T{ timestamp { year 2023 } { month 6 } { day 23 } }
        T{ timestamp { year 2023 } { month 6 } { day 24 } }
        T{ timestamp { year 2023 } { month 6 } { day 25 } }
        T{ timestamp { year 2023 } { month 6 } { day 26 } }
        T{ timestamp { year 2023 } { month 6 } { day 27 } }
        T{ timestamp { year 2023 } { month 6 } { day 28 } }
    }
} [
    2023 06 21 <date-utc> dup 1 weeks time+
    1 days <timestamp-range> >array
] unit-test

! backwards
{
    {
        T{ timestamp { year 2023 } { month 6 } { day 21 } }
        T{ timestamp { year 2023 } { month 6 } { day 20 } }
        T{ timestamp { year 2023 } { month 6 } { day 19 } }
        T{ timestamp { year 2023 } { month 6 } { day 18 } }
        T{ timestamp { year 2023 } { month 6 } { day 17 } }
        T{ timestamp { year 2023 } { month 6 } { day 16 } }
        T{ timestamp { year 2023 } { month 6 } { day 15 } }
        T{ timestamp { year 2023 } { month 6 } { day 14 } }
    }
} [
    2023 06 21 <date-utc> dup 1 weeks time-
    -1 days <timestamp-range> >array
] unit-test

! duration to
{
    {
        T{ timestamp { year 2023 } { month 6 } { day 21 } }
        T{ timestamp { year 2023 } { month 6 } { day 24 } }
        T{ timestamp { year 2023 } { month 6 } { day 27 } }
        T{ timestamp { year 2023 } { month 6 } { day 30 } }
    }
} [
    2023 06 21 <date-utc> 10 days
    3 days <timestamp-range> >array
] unit-test
