USING: calendar irc.logbot tools.test ;
IN: irc.logbot.tests

{ "[10:20:30] hello" } [
    "hello" 2016 2 3 10 20 30 instant <timestamp> add-timestamp
] unit-test

{ "resource:logs/irc/concatenative/2016-02-03.log" } [
    2016 2 3 10 20 30 instant <timestamp> timestamp-path
] unit-test
