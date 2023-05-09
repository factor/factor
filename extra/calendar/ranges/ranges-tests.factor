USING: arrays calendar calendar.ranges kernel tools.test ;

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
        T{ timestamp { year 2023 } { month 6 } { day 29 } }
        T{ timestamp { year 2023 } { month 6 } { day 30 } }
        T{ timestamp { year 2023 } { month 7 } { day 1 } }
        T{ timestamp { year 2023 } { month 7 } { day 2 } }
        T{ timestamp { year 2023 } { month 7 } { day 3 } }
        T{ timestamp { year 2023 } { month 7 } { day 4 } }
    }
} [
    2023 06 21 <date-utc> dup 2 weeks time+
    1 days <timestamp-range> >array
] unit-test
