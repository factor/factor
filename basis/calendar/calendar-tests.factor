USING: accessors grouping kernel math math.order ranges
math.vectors random sequences threads tools.test ;
IN: calendar

[ 2004 12 32 0   0  0 instant <timestamp> ] [ not-in-interval? ] must-fail-with
[ 2004  2 30 0   0  0 instant <timestamp> ] [ not-in-interval? ] must-fail-with
[ 2003  2 29 0   0  0 instant <timestamp> ] [ not-in-interval? ] must-fail-with
[ 2004 -2  9 0   0  0 instant <timestamp> ] [ not-in-interval? ] must-fail-with
[ 2004 12  0 0   0  0 instant <timestamp> ] [ not-in-interval? ] must-fail-with
[ 2004 12  1 24  0  0 instant <timestamp> ] [ not-in-interval? ] must-fail-with
[ 2004 12  1 23 60  0 instant <timestamp> ] [ not-in-interval? ] must-fail-with
[ 2004 12  1 23 59 60 instant <timestamp> ] [ not-in-interval? ] must-fail-with
{ } [
    2014 12 1 23 59 59+99/100 instant <timestamp> drop
] unit-test

{ f } [ 1900 leap-year? ] unit-test
{ t } [ 1904 leap-year? ] unit-test
{ t } [ 2000 leap-year? ] unit-test
{ f } [ 2001 leap-year? ] unit-test
{ f } [ 2006 leap-year? ] unit-test
{ t } [ 2020 leap-year? ] unit-test

{ t } [ 2006 10 10 0 0 0 instant <timestamp> 1 seconds time+
        2006 10 10 0 0 1 instant <timestamp> = ] unit-test
{ t } [ 2006 10 10 0 0 0 instant <timestamp> 100 seconds time+
        2006 10 10 0 1 40 instant <timestamp> = ] unit-test
{ t } [ 2006 10 10 0 0 0 instant <timestamp> -100 seconds time+
        2006 10 9 23 58 20 instant <timestamp> = ] unit-test
{ t } [ 2006 10 10 0 0 0 instant <timestamp> 86400 seconds time+
        2006 10 11 0 0 0 instant <timestamp> = ] unit-test

{ t } [ 2006 10 10 0 0 0 instant <timestamp> 10 minutes time+
        2006 10 10 0 10 0 instant <timestamp> = ] unit-test
{ +eq+ } [ 2006 10 10 0 0 0 instant <timestamp> 10.5 minutes time+
        2006 10 10 0 10 30 instant <timestamp> <=> ] unit-test
{ t } [ 2006 10 10 0 0 0 instant <timestamp> 3/4 minutes time+
        2006 10 10 0 0 45 instant <timestamp> = ] unit-test
{ t } [ 2006 10 10 0 0 0 instant <timestamp> -3/4 minutes time+
        2006 10 9 23 59 15 instant <timestamp> = ] unit-test

{ t } [ 2006 10 10 0 0 0 instant <timestamp> 7200 minutes time+
        2006 10 15 0 0 0 instant <timestamp> = ] unit-test
{ t } [ 2006 10 10 0 0 0 instant <timestamp> -10 minutes time+
        2006 10 9 23 50 0 instant <timestamp> = ] unit-test
{ t } [ 2006 10 10 0 0 0 instant <timestamp> -100 minutes time+
        2006 10 9 22 20 0 instant <timestamp> = ] unit-test

{ t } [ 2006 1 1 0 0 0 instant <timestamp> 1 hours time+
        2006 1 1 1 0 0 instant <timestamp> = ] unit-test
{ t } [ 2006 1 1 0 0 0 instant <timestamp> 24 hours time+
        2006 1 2 0 0 0 instant <timestamp> = ] unit-test
{ t } [ 2006 1 1 0 0 0 instant <timestamp> -24 hours time+
        2005 12 31 0 0 0 instant <timestamp> = ] unit-test
{ t } [ 2006 1 1 0 0 0 instant <timestamp> 12 hours time+
        2006 1 1 12 0 0 instant <timestamp> = ] unit-test
{ t } [ 2006 1 1 0 0 0 instant <timestamp> 72 hours time+
        2006 1 4 0 0 0 instant <timestamp> = ] unit-test

{ t } [ 2006 1 1 0 0 0 instant <timestamp> 1 days time+
        2006 1 2 0 0 0 instant <timestamp> = ] unit-test
{ t } [ 2006 1 1 0 0 0 instant <timestamp> -1 days time+
        2005 12 31 0 0 0 instant <timestamp> = ] unit-test
{ t } [ 2006 1 1 0 0 0 instant <timestamp> 365 days time+
        2007 1 1 0 0 0 instant <timestamp> = ] unit-test
{ t } [ 2006 1 1 0 0 0 instant <timestamp> -365 days time+
        2005 1 1 0 0 0 instant <timestamp> = ] unit-test
{ t } [ 2004 1 1 0 0 0 instant <timestamp> 365 days time+
        2004 12 31 0 0 0 instant <timestamp> = ] unit-test
{ t } [ 2004 1 1 0 0 0 instant <timestamp> 366 days time+
        2005 1 1 0 0 0 instant <timestamp> = ] unit-test

{ t } [ 2006 1 1 0 0 0 instant <timestamp> 11 months time+
        2006 12 1 0 0 0 instant <timestamp> = ] unit-test
{ t } [ 2006 1 1 0 0 0 instant <timestamp> 12 months time+
        2007 1 1 0 0 0 instant <timestamp> = ] unit-test
{ t } [ 2006 1 1 0 0 0 instant <timestamp> 24 months time+
        2008 1 1 0 0 0 instant <timestamp> = ] unit-test
{ t } [ 2006 1 1 0 0 0 instant <timestamp> 13 months time+
        2007 2 1 0 0 0 instant <timestamp> = ] unit-test
{ t } [ 2006 1 1 0 0 0 instant <timestamp> 1 months time+
        2006 2 1 0 0 0 instant <timestamp> = ] unit-test
{ t } [ 2006 1 1 0 0 0 instant <timestamp> 0 months time+
        2006 1 1 0 0 0 instant <timestamp> = ] unit-test
{ t } [ 2006 1 1 0 0 0 instant <timestamp> -1 months time+
        2005 12 1 0 0 0 instant <timestamp> = ] unit-test
{ t } [ 2006 1 1 0 0 0 instant <timestamp> -2 months time+
        2005 11 1 0 0 0 instant <timestamp> = ] unit-test
{ t } [ 2006 1 1 0 0 0 instant <timestamp> -13 months time+
        2004 12 1 0 0 0 instant <timestamp> = ] unit-test
{ t } [ 2006 1 1 0 0 0 instant <timestamp> -24 months time+
        2004 1 1 0 0 0 instant <timestamp> = ] unit-test
{ t } [ 2004 2 29 0 0 0 instant <timestamp> 12 months time+
        2005 3 1 0 0 0 instant <timestamp> = ] unit-test
{ t } [ 2004 2 29 0 0 0 instant <timestamp> -12 months time+
        2003 3 1 0 0 0 instant <timestamp> = ] unit-test

{ t } [ 2006 1 1 0 0 0 instant <timestamp> 0 years time+
        2006 1 1 0 0 0 instant <timestamp> = ] unit-test
{ t } [ 2006 1 1 0 0 0 instant <timestamp> 1 years time+
        2007 1 1 0 0 0 instant <timestamp> = ] unit-test
{ t } [ 2006 1 1 0 0 0 instant <timestamp> -1 years time+
        2005 1 1 0 0 0 instant <timestamp> = ] unit-test
{ t } [ 2006 1 1 0 0 0 instant <timestamp> -100 years time+
        1906 1 1 0 0 0 instant <timestamp> = ] unit-test
! [ t ] [ 2004 2 29 0 0 0 instant <timestamp> -1 years time+
!         2003 2 28 0 0 0 instant <timestamp> = ] unit-test

{ 5 } [ 2006 7 14 0 0 0 instant <timestamp> day-of-week ] unit-test

{ t } [ 2006 7 14 [ julian-day-number julian-day-number>date 0 0 0 instant <timestamp> ] 3keep 0 0 0 instant <timestamp> = ] unit-test

{ 1 } [ 2006 1 1 0 0 0 instant <timestamp> day-of-year ] unit-test
{ 60 } [ 2004 2 29 0 0 0 instant <timestamp> day-of-year ] unit-test
{ 61 } [ 2004 3 1 0 0 0 instant <timestamp> day-of-year ] unit-test
{ 366 } [ 2004 12 31 0 0 0 instant <timestamp> day-of-year ] unit-test
{ 365 } [ 2003 12 31 0 0 0 instant <timestamp> day-of-year ] unit-test
{ 60 } [ 2003 3 1 0 0 0 instant <timestamp> day-of-year ] unit-test

{ t } [ 2004 12 31 0 0 0 instant <timestamp> dup = ] unit-test
{ t } [ 2004 1 1 0 0 0 instant <timestamp> 10 seconds 5 years time+ time+
        2009 1 1 0 0 10 instant <timestamp> = ] unit-test
{ t } [ 2004 1 1 0 0 0 instant <timestamp> -10 seconds -5 years time+ time+
        1998 12 31 23 59 50 instant <timestamp> = ] unit-test

{ t } [ 2004 1 1 23 0 0 12 hours <timestamp> >gmt
        2004 1 1 11 0 0 instant <timestamp> = ] unit-test
{ t } [ 2004 1 1 5 0 0 -11 hours <timestamp> >gmt
        2004 1 1 16 0 0 instant <timestamp> = ] unit-test
{ t } [ 2004 1 1 23 0 0 9+1/2 hours <timestamp> >gmt
        2004 1 1 13 30 0 instant <timestamp> = ] unit-test

{ t } [
    2004 1 1 3 0 0 instant <timestamp>
    2004 1 1 1 0 0 instant <timestamp> 3 am =
] unit-test

{ t } [
    2004 1 1 0 0 0 instant <timestamp>
    2004 1 1 1 0 0 instant <timestamp> 12 am =
] unit-test

{ t } [
    2004 1 1 12 0 0 instant <timestamp>
    2004 1 1 1 0 0 instant <timestamp> 12 pm =
] unit-test

{ t } [
    2004 1 1 23 0 0 instant <timestamp>
    2004 1 1 1 0 0 instant <timestamp> 11 pm =
] unit-test

{ +eq+ } [ 2004 1 1 13 30 0 instant <timestamp>
        2004 1 1 12 30 0 -1 hours <timestamp> <=> ] unit-test

{ +gt+ } [ 2004 1 1 13 30 0 instant <timestamp>
        2004 1 1 12 30 0 instant <timestamp> <=> ] unit-test

{ +lt+ } [ 2004 1 1 12 30 0 instant <timestamp>
        2004 1 1 13 30 0 instant <timestamp> <=> ] unit-test

{ +gt+ } [ 2005 1 1 12 30 0 instant <timestamp>
        2004 1 1 13 30 0 instant <timestamp> <=> ] unit-test

{ t } [ 0 micros>timestamp unix-1970 = ] unit-test
{ t } [ 123456789000000 [ micros>timestamp timestamp>micros ] keep = ] unit-test
{ t } [ 123456789123456000 [ micros>timestamp timestamp>micros ] keep = ] unit-test

: checktime+ ( duration -- ? ) now dup clone [ rot time+ drop ] keep = ;

{ t } [ 5 seconds checktime+ ] unit-test

{ t } [ 5 minutes checktime+ ] unit-test

{ t } [ 5 hours checktime+ ] unit-test

{ t } [ 5 days checktime+ ] unit-test

{ t } [ 5 weeks checktime+ ] unit-test

{ t } [ 5 months checktime+ ] unit-test

{ t } [ 5 years checktime+ ] unit-test

{ t } [ now 50 milliseconds sleep now before? ] unit-test
{ t } [ now 50 milliseconds sleep now swap after? ] unit-test
{ t } [ now 50 milliseconds sleep now 50 milliseconds sleep now swapd between? ] unit-test

{ 4 12 } [ 2009 easter [ month>> ] [ day>> ] bi ] unit-test
{ 4 2 } [ 1961 easter [ month>> ] [ day>> ] bi ] unit-test

{ t } [ 1325376000 unix-time>timestamp 2012 <year-gmt> = ] unit-test
{ t } [ 1356998399 unix-time>timestamp 2013 <year-gmt> 1 seconds time- = ] unit-test

{ t } [ now now-gmt time- duration>seconds 1/5 < ] unit-test
{ t } [ now-gmt now time- duration>seconds 1/5 < ] unit-test

{ t } [ 1500000000 random [ unix-time>timestamp timestamp>unix-time ] keep = ] unit-test

{ t } [
    2009 1 29 <date> 1 months time+
    2009 2 28 <date> =
] unit-test

{ t } [
    2008 1 29 <date> 1 months time+
    2008 2 29 <date> =
] unit-test

{ { 1 1 1 2 2 2 3 3 3 4 4 4 } } [
    12 [1..b] [ 2020 swap 1 <date> quarter ] map
] unit-test

{ 0 }
[ now-gmt gmt-offset>> duration>seconds ] unit-test

! am
[ now 30 am ] [ not-in-interval? ] must-fail-with

! pm
[ now 30 pm ] [ not-in-interval? ] must-fail-with

{ 1 } [ 2018 12 31 <date> week-number ] unit-test

{ 16 } [ 2019 4 17 <date> week-number ] unit-test

{ 53 } [ 2021 1 1 <date> week-number ] unit-test

{ 53 } [ 2004 weeks-in-week-year ] unit-test
{ 52 } [ 2013 weeks-in-week-year ] unit-test

{
    T{ timestamp { year 2019 } { month 11 } { day 4 } }
} [ 2019 308 year-ordinal>timestamp ] unit-test

{
    T{ timestamp { year 2020 } { month 11 } { day 3 } }
} [ 2020 308 year-ordinal>timestamp ] unit-test

{
    T{ timestamp { year 2019 } { month 12 } { day 31 } }
} [ 2019 365 year-ordinal>timestamp ] unit-test

{
    T{ timestamp { year 2020 } { month 12 } { day 31 } }
} [ 2020 366 year-ordinal>timestamp ] unit-test

{ t } [
    2020 <year> timestamp>year-dates-gmt
    [ >date< ymd>ordinal ] map [ < ] monotonic?
] unit-test

{ t } [
    1999 2025 [a..b] [
        <year> timestamp>year-dates-gmt
        [ >date< ymd>ordinal ] map [ < ] monotonic?
    ] map [ ] all?
] unit-test

{ t } [
    1999 2025 [a..b] [
        <year-gmt> timestamp>year-dates-gmt
        [ >date< ymd>ordinal ] map [ < ] monotonic?
    ] map [ ] all?
] unit-test

{ 136 } [ 2014 1 10 <date>  2014 7 20 <date>  weekdays-between ] unit-test
{ 137 } [ 2014 1 10 <date>  2014 7 21 <date>  weekdays-between ] unit-test
{ 138 } [ 2014 1 10 <date>  2014 7 22 <date>  weekdays-between ] unit-test
{ 139 } [ 2014 1 10 <date>  2014 7 23 <date>  weekdays-between ] unit-test
{ 140 } [ 2014 1 10 <date>  2014 7 24 <date>  weekdays-between ] unit-test
{ 141 } [ 2014 1 10 <date>  2014 7 25 <date>  weekdays-between ] unit-test
{ 141 } [ 2014 1 10 <date>  2014 7 26 <date>  weekdays-between ] unit-test
{ 141 } [ 2014 1 10 <date>  2014 7 27 <date>  weekdays-between ] unit-test
{ 142 } [ 2014 1 10 <date>  2014 7 28 <date>  weekdays-between ] unit-test
{ 143 } [ 2014 1 10 <date>  2014 7 29 <date>  weekdays-between ] unit-test
{ 144 } [ 2014 1 10 <date>  2014 7 30 <date>  weekdays-between ] unit-test
{ 145 } [ 2014 1 10 <date>  2014 7 31 <date>  weekdays-between ] unit-test
{ 146 } [ 2014 1 10 <date>  2014 8 1 <date>  weekdays-between ] unit-test
{ 146 } [ 2014 1 10 <date>  2014 8 2 <date>  weekdays-between ] unit-test
{ 146 } [ 2014 1 10 <date>  2014 8 3 <date>  weekdays-between ] unit-test
{ 147 } [ 2014 1 10 <date>  2014 8 4 <date>  weekdays-between ] unit-test
{ 148 } [ 2014 1 10 <date>  2014 8 5 <date>  weekdays-between ] unit-test
{ 149 } [ 2014 1 10 <date>  2014 8 6 <date>  weekdays-between ] unit-test
{ 150 } [ 2014 1 10 <date>  2014 8 7 <date>  weekdays-between ] unit-test
{ 151 } [ 2014 1 10 <date>  2014 8 8 <date>  weekdays-between ] unit-test
{ 151 } [ 2014 1 10 <date>  2014 8 9 <date>  weekdays-between ] unit-test
{ 151 } [ 2014 1 10 <date>  2014 8 10 <date>  weekdays-between ] unit-test


{ t } [
    2014 1 1 <date-gmt>
    2014 <year-gmt> timestamp>year-dates-gmt
    [ weekdays-between ] with map [ <= ] monotonic?
] unit-test

{ t } [
    2020 1 1 <date-gmt>
    2020 <year-gmt> timestamp>year-dates-gmt
    [ weekdays-between ] with map [ <= ] monotonic?
] unit-test

{ t } [
    2014 1 1 <date-gmt>
    2014 <year-gmt> timestamp>year-dates-gmt
    [ weekdays-between ] with map
    dup 1 tail swap v- [ 1 <= ] all?
] unit-test

{ t } [
    2020 1 1 <date-gmt>
    2020 <year-gmt> timestamp>year-dates-gmt
    [ weekdays-between ] with map
    dup 1 tail swap v- [ 1 <= ] all?
] unit-test

{
    {
        T{ timestamp { year 2020 } { month 3 } { day 1 } }
        T{ timestamp { year 2020 } { month 3 } { day 8 } }
        T{ timestamp { year 2020 } { month 3 } { day 15 } }
        T{ timestamp { year 2020 } { month 3 } { day 22 } }
        T{ timestamp { year 2020 } { month 3 } { day 29 } }
    }
} [
    2020 march gmt 5 <iota> [ sunday-of-month ] with map
] unit-test


{
    {
        T{ timestamp { year 2020 } { month 2 } { day 1 } }
        T{ timestamp { year 2020 } { month 2 } { day 8 } }
        T{ timestamp { year 2020 } { month 2 } { day 15 } }
        T{ timestamp { year 2020 } { month 2 } { day 22 } }
        T{ timestamp { year 2020 } { month 2 } { day 29 } }
    }
} [
    2020 february gmt 5 <iota> [ saturday-of-month ] with map
] unit-test


! 5th monday of dec 2020 is in january, why not
{
    {
        T{ timestamp { year 2020 } { month 12 } { day 7 } }
        T{ timestamp { year 2020 } { month 12 } { day 14 } }
        T{ timestamp { year 2020 } { month 12 } { day 21 } }
        T{ timestamp { year 2020 } { month 12 } { day 28 } }
        T{ timestamp { year 2021 } { month 1 } { day 4 } }
    }
} [
    2020 december gmt 5 <iota> [ monday-of-month ] with map
] unit-test

{ t } [
    now [ start-of-year ] [ end-of-year ] bi same-year?
] unit-test

{ t } [
    now [ start-of-month ] [ end-of-month ] bi same-month?
] unit-test

{ t } [
    now [ first-day-of-month ] [ last-day-of-month ] bi same-month?
] unit-test

! XXX: Different algorithm for start/end of week and week number
! { t } [
!     now [ start-of-week ] [ end-of-week ] bi same-week?
! ] unit-test

{ t } [
    now [ start-of-day ] [ end-of-day ] bi same-day?
] unit-test

{ t } [
    now [ start-of-hour ] [ end-of-hour ] bi same-hour?
] unit-test

{ t } [
    now [ start-of-minute ] [ end-of-minute ] bi same-minute?
] unit-test

{ t } [
    now [ start-of-second ] [ end-of-second ] bi same-second?
] unit-test

! Clone things by default
{ f }
[
    now [ start-of-year ] [ end-of-year ] bi
    [ month>> ] bi@ =
] unit-test

{ f } [
    now [ first-day-of-month ] [ last-day-of-month ] bi
    [ day>> ] bi@ =
] unit-test


{ f } [
    now [ first-day-of-decade ] [ last-day-of-decade ] bi
    [ year>> ] bi@ =
] unit-test


{ f } [
    now [ start-of-millennium ] [ end-of-millennium ] bi
    [ year>> ] bi@ =
] unit-test

{ f } [
    now [ start-of-year ] [ end-of-year ] bi same-day?
] unit-test

{ f } [
    now [ start-of-year ] [ end-of-year ] bi same-day-of-year?
] unit-test


{ t } [ 1999 1 1 <date> 2000 1 1 <date> same-day-of-year? ] unit-test
{ f } [ 1999 1 1 <date> 2000 1 1 <date> same-day? ] unit-test
{ t } [
    2000 1 1 <date> 4 >>hour
    2000 1 1 <date> same-day?
] unit-test

{
    T{ timestamp { year 2023 } { month 4 } { day 9 } }
    T{ timestamp
        { year 2023 }
        { month 4 }
        { day 15 }
        { hour 23 }
        { minute 59 }
        { second 59+999/1000 }
    }
} [ 2023 4 13 <date-gmt> start-of-week dup end-of-week ] unit-test
