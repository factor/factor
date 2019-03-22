USING: calendar crontab kernel math.order tools.test ;

{
    T{ timestamp
        { year 2018 }
        { month 3 }
        { day 9 }
        { hour 12 }
        { minute 23 }
        { gmt-offset T{ duration { hour -8 } } }
    }
} [
    "23 0-20/2 * * *" parse-cronentry
    T{ timestamp
        { year 2018 }
        { month 3 }
        { day 9 }
        { hour 12 }
        { minute 6 }
        { gmt-offset T{ duration { hour -8 } } }
    } next-time-after
] unit-test

{ +lt+ } [
    now "*/1 * * * *" parse-cronentry next-time <=>
] unit-test

{
    T{ timestamp
        { year 2019 }
        { month 8 }
        { day 1 }
        { minute 5 }
        { gmt-offset T{ duration { hour -7 } } }
    }
} [
    "5 0 * 8 *"  parse-cronentry
    T{ timestamp
        { year 2019 }
        { month 3 }
        { day 22 }
        { hour 15 }
        { minute 16 }
        { second 36+590901/1000000 }
        { gmt-offset T{ duration { hour -7 } } }
    } next-time-after
] unit-test
