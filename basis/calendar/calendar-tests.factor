USING: arrays calendar kernel math sequences tools.test
continuations system math.order threads accessors ;
IN: calendar.tests

[ f ] [ 2004 12 32 0   0  0 instant <timestamp> valid-timestamp? ] unit-test
[ f ] [ 2004  2 30 0   0  0 instant <timestamp> valid-timestamp? ] unit-test
[ f ] [ 2003  2 29 0   0  0 instant <timestamp> valid-timestamp? ] unit-test
[ f ] [ 2004 -2  9 0   0  0 instant <timestamp> valid-timestamp? ] unit-test
[ f ] [ 2004 12  0 0   0  0 instant <timestamp> valid-timestamp? ] unit-test
[ f ] [ 2004 12  1 24  0  0 instant <timestamp> valid-timestamp? ] unit-test
[ f ] [ 2004 12  1 23 60  0 instant <timestamp> valid-timestamp? ] unit-test
[ f ] [ 2004 12  1 23 59 60 instant <timestamp> valid-timestamp? ] unit-test
[ t ] [ now valid-timestamp? ] unit-test

[ f ] [ 1900 leap-year? ] unit-test
[ t ] [ 1904 leap-year? ] unit-test
[ t ] [ 2000 leap-year? ] unit-test
[ f ] [ 2001 leap-year? ] unit-test
[ f ] [ 2006 leap-year? ] unit-test

[ t ] [ 2006 10 10 0 0 0 instant <timestamp> 1 seconds time+
        2006 10 10 0 0 1 instant <timestamp> = ] unit-test
[ t ] [ 2006 10 10 0 0 0 instant <timestamp> 100 seconds time+
        2006 10 10 0 1 40 instant <timestamp> = ] unit-test
[ t ] [ 2006 10 10 0 0 0 instant <timestamp> -100 seconds time+
        2006 10 9 23 58 20 instant <timestamp> = ] unit-test
[ t ] [ 2006 10 10 0 0 0 instant <timestamp> 86400 seconds time+
        2006 10 11 0 0 0 instant <timestamp> = ] unit-test

[ t ] [ 2006 10 10 0 0 0 instant <timestamp> 10 minutes time+
        2006 10 10 0 10 0 instant <timestamp> = ] unit-test
[ +eq+ ] [ 2006 10 10 0 0 0 instant <timestamp> 10.5 minutes time+
        2006 10 10 0 10 30 instant <timestamp> <=> ] unit-test
[ t ] [ 2006 10 10 0 0 0 instant <timestamp> 3/4 minutes time+
        2006 10 10 0 0 45 instant <timestamp> = ] unit-test
[ t ] [ 2006 10 10 0 0 0 instant <timestamp> -3/4 minutes time+
        2006 10 9 23 59 15 instant <timestamp> = ] unit-test

[ t ] [ 2006 10 10 0 0 0 instant <timestamp> 7200 minutes time+
        2006 10 15 0 0 0 instant <timestamp> = ] unit-test
[ t ] [ 2006 10 10 0 0 0 instant <timestamp> -10 minutes time+
        2006 10 9 23 50 0 instant <timestamp> = ] unit-test
[ t ] [ 2006 10 10 0 0 0 instant <timestamp> -100 minutes time+
        2006 10 9 22 20 0 instant <timestamp> = ] unit-test

[ t ] [ 2006 1 1 0 0 0 instant <timestamp> 1 hours time+
        2006 1 1 1 0 0 instant <timestamp> = ] unit-test
[ t ] [ 2006 1 1 0 0 0 instant <timestamp> 24 hours time+
        2006 1 2 0 0 0 instant <timestamp> = ] unit-test
[ t ] [ 2006 1 1 0 0 0 instant <timestamp> -24 hours time+
        2005 12 31 0 0 0 instant <timestamp> = ] unit-test
[ t ] [ 2006 1 1 0 0 0 instant <timestamp> 12 hours time+
        2006 1 1 12 0 0 instant <timestamp> = ] unit-test
[ t ] [ 2006 1 1 0 0 0 instant <timestamp> 72 hours time+
        2006 1 4 0 0 0 instant <timestamp> = ] unit-test

[ t ] [ 2006 1 1 0 0 0 instant <timestamp> 1 days time+
        2006 1 2 0 0 0 instant <timestamp> = ] unit-test
[ t ] [ 2006 1 1 0 0 0 instant <timestamp> -1 days time+
        2005 12 31 0 0 0 instant <timestamp> = ] unit-test
[ t ] [ 2006 1 1 0 0 0 instant <timestamp> 365 days time+
        2007 1 1 0 0 0 instant <timestamp> = ] unit-test
[ t ] [ 2006 1 1 0 0 0 instant <timestamp> -365 days time+
        2005 1 1 0 0 0 instant <timestamp> = ] unit-test
[ t ] [ 2004 1 1 0 0 0 instant <timestamp> 365 days time+
        2004 12 31 0 0 0 instant <timestamp> = ] unit-test
[ t ] [ 2004 1 1 0 0 0 instant <timestamp> 366 days time+
        2005 1 1 0 0 0 instant <timestamp> = ] unit-test

[ t ] [ 2006 1 1 0 0 0 instant <timestamp> 11 months time+
        2006 12 1 0 0 0 instant <timestamp> = ] unit-test
[ t ] [ 2006 1 1 0 0 0 instant <timestamp> 12 months time+
        2007 1 1 0 0 0 instant <timestamp> = ] unit-test
[ t ] [ 2006 1 1 0 0 0 instant <timestamp> 24 months time+
        2008 1 1 0 0 0 instant <timestamp> = ] unit-test
[ t ] [ 2006 1 1 0 0 0 instant <timestamp> 13 months time+
        2007 2 1 0 0 0 instant <timestamp> = ] unit-test
[ t ] [ 2006 1 1 0 0 0 instant <timestamp> 1 months time+
        2006 2 1 0 0 0 instant <timestamp> = ] unit-test
[ t ] [ 2006 1 1 0 0 0 instant <timestamp> 0 months time+
        2006 1 1 0 0 0 instant <timestamp> = ] unit-test
[ t ] [ 2006 1 1 0 0 0 instant <timestamp> -1 months time+
        2005 12 1 0 0 0 instant <timestamp> = ] unit-test
[ t ] [ 2006 1 1 0 0 0 instant <timestamp> -2 months time+
        2005 11 1 0 0 0 instant <timestamp> = ] unit-test
[ t ] [ 2006 1 1 0 0 0 instant <timestamp> -13 months time+
        2004 12 1 0 0 0 instant <timestamp> = ] unit-test
[ t ] [ 2006 1 1 0 0 0 instant <timestamp> -24 months time+
        2004 1 1 0 0 0 instant <timestamp> = ] unit-test
[ t ] [ 2004 2 29 0 0 0 instant <timestamp> 12 months time+
        2005 3 1 0 0 0 instant <timestamp> = ] unit-test
[ t ] [ 2004 2 29 0 0 0 instant <timestamp> -12 months time+
        2003 3 1 0 0 0 instant <timestamp> = ] unit-test

[ t ] [ 2006 1 1 0 0 0 instant <timestamp> 0 years time+
        2006 1 1 0 0 0 instant <timestamp> = ] unit-test
[ t ] [ 2006 1 1 0 0 0 instant <timestamp> 1 years time+
        2007 1 1 0 0 0 instant <timestamp> = ] unit-test
[ t ] [ 2006 1 1 0 0 0 instant <timestamp> -1 years time+
        2005 1 1 0 0 0 instant <timestamp> = ] unit-test
[ t ] [ 2006 1 1 0 0 0 instant <timestamp> -100 years time+
        1906 1 1 0 0 0 instant <timestamp> = ] unit-test
! [ t ] [ 2004 2 29 0 0 0 instant <timestamp> -1 years time+
!         2003 2 28 0 0 0 instant <timestamp> = ] unit-test

[ 5 ] [ 2006 7 14 0 0 0 instant <timestamp> day-of-week ] unit-test

[ t ] [ 2006 7 14 [ julian-day-number julian-day-number>date 0 0 0 instant <timestamp> ] 3keep 0 0 0 instant <timestamp> = ] unit-test

[ 1 ] [ 2006 1 1 0 0 0 instant <timestamp> day-of-year ] unit-test
[ 60 ] [ 2004 2 29 0 0 0 instant <timestamp> day-of-year ] unit-test
[ 61 ] [ 2004 3 1 0 0 0 instant <timestamp> day-of-year ] unit-test
[ 366 ] [ 2004 12 31 0 0 0 instant <timestamp> day-of-year ] unit-test
[ 365 ] [ 2003 12 31 0 0 0 instant <timestamp> day-of-year ] unit-test
[ 60 ] [ 2003 3 1 0 0 0 instant <timestamp> day-of-year ] unit-test

[ t ] [ 2004 12 31 0 0 0 instant <timestamp> dup = ] unit-test
[ t ] [ 2004 1 1 0 0 0 instant <timestamp> 10 seconds 5 years time+ time+
        2009 1 1 0 0 10 instant <timestamp> = ] unit-test
[ t ] [ 2004 1 1 0 0 0 instant <timestamp> -10 seconds -5 years time+ time+
        1998 12 31 23 59 50 instant <timestamp> = ] unit-test

[ t ] [ 2004 1 1 23 0 0 12 hours <timestamp> >gmt
        2004 1 1 11 0 0 instant <timestamp> = ] unit-test
[ t ] [ 2004 1 1 5 0 0 -11 hours <timestamp> >gmt
        2004 1 1 16 0 0 instant <timestamp> = ] unit-test
[ t ] [ 2004 1 1 23 0 0 9+1/2 hours <timestamp> >gmt
        2004 1 1 13 30 0 instant <timestamp> = ] unit-test

[ +eq+ ] [ 2004 1 1 13 30 0 instant <timestamp>
        2004 1 1 12 30 0 -1 hours <timestamp> <=> ] unit-test

[ +gt+ ] [ 2004 1 1 13 30 0 instant <timestamp>
        2004 1 1 12 30 0 instant <timestamp> <=> ] unit-test

[ +lt+ ] [ 2004 1 1 12 30 0 instant <timestamp>
        2004 1 1 13 30 0 instant <timestamp> <=> ] unit-test

[ +gt+ ] [ 2005 1 1 12 30 0 instant <timestamp>
        2004 1 1 13 30 0 instant <timestamp> <=> ] unit-test

[ t ] [ now timestamp>micros micros - 1000000 < ] unit-test
[ t ] [ 0 micros>timestamp unix-1970 = ] unit-test
[ t ] [ 123456789000000 [ micros>timestamp timestamp>micros ] keep = ] unit-test
[ t ] [ 123456789123456000 [ micros>timestamp timestamp>micros ] keep = ] unit-test

: checktime+ ( duration -- ? ) now dup clone [ rot time+ drop ] keep = ;

[ t ] [ 5 seconds checktime+ ] unit-test

[ t ] [ 5 minutes checktime+ ] unit-test

[ t ] [ 5 hours checktime+ ] unit-test

[ t ] [ 5 days checktime+ ] unit-test

[ t ] [ 5 weeks checktime+ ] unit-test

[ t ] [ 5 months checktime+ ] unit-test

[ t ] [ 5 years checktime+ ] unit-test

[ t ] [ now 50 milliseconds sleep now before? ] unit-test
[ t ] [ now 50 milliseconds sleep now swap after? ] unit-test
[ t ] [ now 50 milliseconds sleep now 50 milliseconds sleep now swapd between? ] unit-test

[ 4 12 ] [ 2009 easter [ month>> ] [ day>> ] bi ] unit-test
[ 4 2 ] [ 1961 easter [ month>> ] [ day>> ] bi ] unit-test

[ f ] [ now dup midnight eq? ] unit-test
[ f ] [ now dup easter eq? ] unit-test
[ f ] [ now dup beginning-of-year eq? ] unit-test
