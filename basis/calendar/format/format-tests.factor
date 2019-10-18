USING: accessors calendar calendar.format sequences tools.test ;
IN: calendar.format.tests

CONSTANT: testtime T{ timestamp
    { year 2018 }
    { month 2 }
    { day 15 }
    { hour 8 }
    { minute 51 }
    { second 44+423303/500000 }
    { gmt-offset T{ duration { hour -8 } } }
}

{ "2018-02-15T08:51:44.846606-08:00" } [ testtime timestamp>rfc3339 ] unit-test

{ "Thu, 15 Feb 2018 08:51:44 -0800" } [ testtime timestamp>rfc822 ] unit-test

{ }
[ { 2008 2009 } [ year. ] each ] unit-test

{ "03:01:59" } [
    3 hours 1 >>minute 59 >>second duration>hms
] unit-test
