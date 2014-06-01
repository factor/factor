USING: calendar.format calendar kernel math tools.test
io.streams.string accessors io math.order sequences ;
IN: calendar.format.tests

[ 0 ] [
    "Z" [ read1 read-rfc3339-gmt-offset ] with-string-reader duration>hours
] unit-test

[ 1 ] [
    "+01" [ read1 read-rfc3339-gmt-offset ] with-string-reader duration>hours
] unit-test

[ -1 ] [
    "-01" [ read1 read-rfc3339-gmt-offset ] with-string-reader duration>hours
] unit-test

[ -1-1/2 ] [
    "-01:30" [ read1 read-rfc3339-gmt-offset ] with-string-reader duration>hours
] unit-test

[ 1+1/2 ] [
    "+01:30" [ read1 read-rfc3339-gmt-offset ] with-string-reader duration>hours
] unit-test

[ ] [ now timestamp>rfc3339 drop ] unit-test
[ ] [ now timestamp>rfc822 drop ] unit-test

[ 8/1000 -4 ] [
    "2008-04-19T04:56:00.008-04:00" rfc3339>timestamp
    [ second>> ] [ gmt-offset>> hour>> ] bi
] unit-test

[ T{ duration f 0 0 0 0 0 0 } ] [
    "GMT" parse-rfc822-gmt-offset
] unit-test

[ T{ duration f 0 0 0 -5 0 0 } ] [
    "-0500" parse-rfc822-gmt-offset
] unit-test

[ T{ timestamp f 2008 4 22 14 36 12 T{ duration f 0 0 0 0 0 0 } } ] [
    "Tue, 22 Apr 2008 14:36:12 GMT" rfc822>timestamp
] unit-test

[ t ] [ now dup timestamp>rfc822 rfc822>timestamp time- 1 seconds before? ] unit-test

[ t ] [ now dup timestamp>cookie-string cookie-string>timestamp time- 1 seconds before? ] unit-test

[ "Sun, 4 May 2008 07:00:00" ] [
    "Sun May 04 07:00:00 2008 GMT" cookie-string>timestamp
    timestamp>string
] unit-test

[ "20080504070000" ] [
    "Sun May 04 07:00:00 2008 GMT" cookie-string>timestamp
    timestamp>mdtm
] unit-test

[
    T{ timestamp f
        2008
        5
        26
        0
        37
        42+2469/20000
        T{ duration f 0 0 0 -5 0 0 }
    }
] [ "2008-05-26T00:37:42.12345-05:00" rfc3339>timestamp ] unit-test

[
    T{ timestamp
        { year 2008 }
        { month 10 }
        { day 2 }
        { hour 23 }
        { minute 59 }
        { second 59 }
        { gmt-offset T{ duration f 0 0 0 0 0 0 } }
    }
] [ "Thursday, 02-Oct-2008 23:59:59 GMT" cookie-string>timestamp ] unit-test


[ ]
[ { 2008 2009 } [ year. ] each ] unit-test

[
    T{ timestamp
        { year 2013 }
        { month 4 }
        { day 23 }
        { hour 13 }
        { minute 50 }
        { second 24 }
    }
] [ "2013-04-23T13:50:24" rfc3339>timestamp ] unit-test

[
    T{ timestamp
        { year 2001 }
        { month 12 }
        { day 15 }
        { hour 02 }
        { minute 59 }
        { second 43+1/10 }
    }
] [ "2001-12-15 02:59:43.1Z" rfc3339>timestamp ] unit-test

[
    T{ timestamp
        { year 2001 }
        { month 12 }
        { day 15 }
        { hour 02 }
        { minute 59 }
        { second 43+1/10 }
    }
] [ "2001-12-15	02:59:43.1Z" rfc3339>timestamp ] unit-test
