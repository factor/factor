! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: calendar calendar.elapsed kernel tools.test ;

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
