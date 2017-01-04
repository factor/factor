USING: accessors calendar calendar.format io io.streams.string
kernel math.order sequences tools.test ;
IN: calendar.format.tests

{ } [ now timestamp>rfc3339 drop ] unit-test
{ } [ now timestamp>rfc822 drop ] unit-test

{ }
[ { 2008 2009 } [ year. ] each ] unit-test
