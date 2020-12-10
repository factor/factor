USING: accessors calendar calendar.format kernel sequences tools.test ;
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

{ "01:31:29" } [ 1.525 hours duration>hms ] unit-test

[ -1 elapsed-time ] [ "negative seconds" = ] must-fail-with

{ "0s" } [ 0 elapsed-time ] unit-test
{ "59s" } [ 59 elapsed-time ] unit-test
{ "1m" } [ 60 elapsed-time ] unit-test
{ "1m 1s" } [ 61 elapsed-time ] unit-test
{ "2y 1w 6d 2h 59m 23s" } [ 64033163 elapsed-time ] unit-test

{ "just now" } [ 0 relative-time ] unit-test
{ "less than a minute ago" } [ 10 relative-time ] unit-test
{ "about a minute ago" } [ 60 relative-time ] unit-test
{ "about a minute ago" } [ 90 relative-time ] unit-test
{ "4 minutes ago" } [ 270 relative-time ] unit-test
