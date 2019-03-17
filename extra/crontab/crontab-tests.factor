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
    } [ next-time-after ] keep
] unit-test

{ +lt+ } [
    now "*/1 * * * *" parse-cronentry next-time <=>
] unit-test
