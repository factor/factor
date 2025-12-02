USING: accessors calendar calendar.format io.streams.string kernel
sequences tools.test ;

{
    "2018-02-15T08:51:44.846606-08:00"
    "Thu, 15 Feb 2018 08:51:44 -0800"
} [
    T{ timestamp
        { year 2018 }
        { month 2 }
        { day 15 }
        { hour 8 }
        { minute 51 }
        { second 44+423303/500000 }
        { gmt-offset T{ duration { hour -8 } } }
    } [ timestamp>rfc3339 ] [ timestamp>rfc822 ] bi
] unit-test

{
"      May 2008
Su Mo Tu We Th Fr Sa
             1  2  3
 4  5  6  7  8  9 10
11 12 13 14 15 16 17
18 19 20 21 22 23 24
25 26 27 28 29 30 31

" } [
    [ 2008 <year> 5 >>month month. ] with-string-writer
] unit-test

{
"                              2008

      January               February               March        
Su Mo Tu We Th Fr Sa  Su Mo Tu We Th Fr Sa  Su Mo Tu We Th Fr Sa
       1  2  3  4  5                  1  2                     1
 6  7  8  9 10 11 12   3  4  5  6  7  8  9   2  3  4  5  6  7  8
13 14 15 16 17 18 19  10 11 12 13 14 15 16   9 10 11 12 13 14 15
20 21 22 23 24 25 26  17 18 19 20 21 22 23  16 17 18 19 20 21 22
27 28 29 30 31        24 25 26 27 28 29     23 24 25 26 27 28 29
                                            30 31               
                                                                
       April                  May                   June        
Su Mo Tu We Th Fr Sa  Su Mo Tu We Th Fr Sa  Su Mo Tu We Th Fr Sa
       1  2  3  4  5               1  2  3   1  2  3  4  5  6  7
 6  7  8  9 10 11 12   4  5  6  7  8  9 10   8  9 10 11 12 13 14
13 14 15 16 17 18 19  11 12 13 14 15 16 17  15 16 17 18 19 20 21
20 21 22 23 24 25 26  18 19 20 21 22 23 24  22 23 24 25 26 27 28
27 28 29 30           25 26 27 28 29 30 31  29 30               
                                                                
                                                                
        July                 August              September      
Su Mo Tu We Th Fr Sa  Su Mo Tu We Th Fr Sa  Su Mo Tu We Th Fr Sa
       1  2  3  4  5                  1  2      1  2  3  4  5  6
 6  7  8  9 10 11 12   3  4  5  6  7  8  9   7  8  9 10 11 12 13
13 14 15 16 17 18 19  10 11 12 13 14 15 16  14 15 16 17 18 19 20
20 21 22 23 24 25 26  17 18 19 20 21 22 23  21 22 23 24 25 26 27
27 28 29 30 31        24 25 26 27 28 29 30  28 29 30            
                      31                                        
                                                                
      October               November              December      
Su Mo Tu We Th Fr Sa  Su Mo Tu We Th Fr Sa  Su Mo Tu We Th Fr Sa
          1  2  3  4                     1      1  2  3  4  5  6
 5  6  7  8  9 10 11   2  3  4  5  6  7  8   7  8  9 10 11 12 13
12 13 14 15 16 17 18   9 10 11 12 13 14 15  14 15 16 17 18 19 20
19 20 21 22 23 24 25  16 17 18 19 20 21 22  21 22 23 24 25 26 27
26 27 28 29 30 31     23 24 25 26 27 28 29  28 29 30 31         
                      30                                        
                                                                
"
} [ [ 2008 year. ] with-string-writer ] unit-test

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

[ "" parse-elapsed-time ] must-fail
[ "1" parse-elapsed-time ] must-fail
[ "1t" parse-elapsed-time ] must-fail
{ T{ duration f 0 0 0 0 0 0 } } [ "0s" parse-elapsed-time ] unit-test
{ T{ duration f 0 0 0 0 0 59 } } [ "59s" parse-elapsed-time ] unit-test
{ T{ duration f 0 0 0 0 1 0 } } [ "1m" parse-elapsed-time ] unit-test
{ T{ duration f 0 0 0 0 1 1 } } [ "1m 1s" parse-elapsed-time ] unit-test
{ T{ duration f 2 0 13 2 59 23 } } [ "2y 1w 6d 2h 59m 23s" parse-elapsed-time ] unit-test

{ "just now" } [ 0 relative-time ] unit-test
{ "less than a minute ago" } [ 10 relative-time ] unit-test
{ "about a minute ago" } [ 60 relative-time ] unit-test
{ "about a minute ago" } [ 90 relative-time ] unit-test
{ "4 minutes ago" } [ 270 relative-time ] unit-test

{ "1 minute" } [ 60 seconds duration>human-readable ] unit-test
{ "1 hour" } [ 1 hours duration>human-readable ] unit-test
{ "3 hours" } [ 3 hours duration>human-readable ] unit-test
{ "2 minutes and 3 seconds" } [ 123 seconds duration>human-readable ] unit-test
{ "20 minutes and 34 seconds" } [ 1234 seconds duration>human-readable ] unit-test
{ "3 hours, 25 minutes and 45 seconds" } [ 12345 seconds duration>human-readable ] unit-test
{ "1 year" } [ 31536000 seconds duration>human-readable ] unit-test

{ T{ duration f 0 0 0 0 1 0 } } [ "1 minute" human-readable>duration ] unit-test
{ T{ duration f 0 0 0 1 0 0 } } [ "1 hour" human-readable>duration ] unit-test
{ T{ duration f 0 0 0 3 0 0 } } [ "3 hours" human-readable>duration ] unit-test
{ T{ duration f 0 0 0 0 2 3 } } [ "2 minutes and 3 seconds" human-readable>duration ] unit-test
{ T{ duration f 0 0 0 0 20 34 } } [ "20 minutes and 34 seconds" human-readable>duration ] unit-test
{ T{ duration f 0 0 0 3 25 45 } } [ "3 hours, 25 minutes and 45 seconds" human-readable>duration ] unit-test
