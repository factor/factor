USING: calendar calendar.format crontab kernel math.order
sequences tools.test ;

IN: crontab.tests

{ +lt+ } [
    now "*/1 * * * *" parse-cronentry next-time <=>
] unit-test

[ "0 0 30 2 *" parse-cronentry ] [ invalid-cronentry? ] must-fail-with
[ "0 0 31 4 *" parse-cronentry ] [ invalid-cronentry? ] must-fail-with

CONSTANT: start-timestamp T{ timestamp
    { year 2019 }
    { month 3 }
    { day 23 }
    { hour 14 }
    { second 16+4353/8000 }
    { gmt-offset T{ duration { hour -7 } } }
}

: next-few-times ( pattern -- timestamps )
    parse-cronentry 5 start-timestamp next-times-after
    [ timestamp>rfc822 ] map ;

! At 04:05.
{
    {
        "Sun, 24 Mar 2019 04:05:00 -0700"
        "Mon, 25 Mar 2019 04:05:00 -0700"
        "Tue, 26 Mar 2019 04:05:00 -0700"
        "Wed, 27 Mar 2019 04:05:00 -0700"
        "Thu, 28 Mar 2019 04:05:00 -0700"
    }
} [ "5 4 * * *" next-few-times ] unit-test

! At 00:05 in August.
{
    {
        "Thu, 1 Aug 2019 00:05:00 -0700"
        "Fri, 2 Aug 2019 00:05:00 -0700"
        "Sat, 3 Aug 2019 00:05:00 -0700"
        "Sun, 4 Aug 2019 00:05:00 -0700"
        "Mon, 5 Aug 2019 00:05:00 -0700"
    }
} [ "5 0 * 8 *" next-few-times ] unit-test

! At 14:15 on day-of-month 1.
{
    {
        "Mon, 1 Apr 2019 14:15:00 -0700"
        "Wed, 1 May 2019 14:15:00 -0700"
        "Sat, 1 Jun 2019 14:15:00 -0700"
        "Mon, 1 Jul 2019 14:15:00 -0700"
        "Thu, 1 Aug 2019 14:15:00 -0700"
    }
} [ "15 14 1 * *" next-few-times ] unit-test

! At 22:00 on every day-of-week from Monday through Friday.
{
    {
        "Mon, 25 Mar 2019 22:00:00 -0700"
        "Tue, 26 Mar 2019 22:00:00 -0700"
        "Wed, 27 Mar 2019 22:00:00 -0700"
        "Thu, 28 Mar 2019 22:00:00 -0700"
        "Fri, 29 Mar 2019 22:00:00 -0700"
    }
} [ "0 22 * * 1-5" next-few-times ] unit-test

! At minute 23 past every 2nd hour from 0 through 20.
{
    {
        "Sat, 23 Mar 2019 14:23:00 -0700"
        "Sat, 23 Mar 2019 16:23:00 -0700"
        "Sat, 23 Mar 2019 18:23:00 -0700"
        "Sat, 23 Mar 2019 20:23:00 -0700"
        "Sun, 24 Mar 2019 00:23:00 -0700"
    }
} [ "23 0-20/2 * * *" next-few-times ] unit-test

! At 04:05 on Sunday.
{
    {
        "Sun, 24 Mar 2019 04:05:00 -0700"
        "Sun, 31 Mar 2019 04:05:00 -0700"
        "Sun, 7 Apr 2019 04:05:00 -0700"
        "Sun, 14 Apr 2019 04:05:00 -0700"
        "Sun, 21 Apr 2019 04:05:00 -0700"
    }
} [ "5 4 * * sun" next-few-times ] unit-test

! At minute 0 past hour 0 and 12 on day-of-month 1 in every 2nd month.
{
    {
        "Wed, 1 May 2019 00:00:00 -0700"
        "Wed, 1 May 2019 12:00:00 -0700"
        "Mon, 1 Jul 2019 00:00:00 -0700"
        "Mon, 1 Jul 2019 12:00:00 -0700"
        "Sun, 1 Sep 2019 00:00:00 -0700"
    }
} [ "0 0,12 1 */2 *" next-few-times ] unit-test

! At 04:00 on every day-of-month from 8 through 14.
{
    {
        "Mon, 8 Apr 2019 04:00:00 -0700"
        "Tue, 9 Apr 2019 04:00:00 -0700"
        "Wed, 10 Apr 2019 04:00:00 -0700"
        "Thu, 11 Apr 2019 04:00:00 -0700"
        "Fri, 12 Apr 2019 04:00:00 -0700"
    }
} [ "0 4 8-14 * *" next-few-times ] unit-test

! At 00:00 on day-of-month 1 and 15 and on Wednesday.
{
    {
        "Wed, 27 Mar 2019 00:00:00 -0700"
        "Mon, 1 Apr 2019 00:00:00 -0700"
        "Wed, 3 Apr 2019 00:00:00 -0700"
        "Wed, 10 Apr 2019 00:00:00 -0700"
        "Mon, 15 Apr 2019 00:00:00 -0700"
    }
} [ "0 0 1,15 * 3" next-few-times ] unit-test

! At 00:00 on Sunday.
{
    {
        "Sun, 24 Mar 2019 00:00:00 -0700"
        "Sun, 31 Mar 2019 00:00:00 -0700"
        "Sun, 7 Apr 2019 00:00:00 -0700"
        "Sun, 14 Apr 2019 00:00:00 -0700"
        "Sun, 21 Apr 2019 00:00:00 -0700"
    }
} [ "@weekly" next-few-times ] unit-test

! At 00:00 on day-of-month 29 in February.
{
    {
        "Sat, 29 Feb 2020 00:00:00 -0700"
        "Thu, 29 Feb 2024 00:00:00 -0700"
        "Tue, 29 Feb 2028 00:00:00 -0700"
        "Sun, 29 Feb 2032 00:00:00 -0700"
        "Fri, 29 Feb 2036 00:00:00 -0700"
    }
} [ "0 0 29 2 *" next-few-times ] unit-test

! At every 26th minute from 2 through 59 past hour 4.
{
    {
        "Sun, 24 Mar 2019 04:02:00 -0700"
        "Sun, 24 Mar 2019 04:28:00 -0700"
        "Sun, 24 Mar 2019 04:54:00 -0700"
        "Mon, 25 Mar 2019 04:02:00 -0700"
        "Mon, 25 Mar 2019 04:28:00 -0700"
    }
} [ "2/26 4 * * *" next-few-times ] unit-test

! At every 3rd minute from 5 through 20 past hour 4.
{
    {
        "Sun, 24 Mar 2019 04:05:00 -0700"
        "Sun, 24 Mar 2019 04:08:00 -0700"
        "Sun, 24 Mar 2019 04:11:00 -0700"
        "Sun, 24 Mar 2019 04:14:00 -0700"
        "Sun, 24 Mar 2019 04:17:00 -0700"
    }
} [ "5-20/3 4 * * *" next-few-times ] unit-test

! At 04:05 on Sunday.
{
    {
        "Sun, 24 Mar 2019 04:05:00 -0700"
        "Sun, 31 Mar 2019 04:05:00 -0700"
        "Sun, 7 Apr 2019 04:05:00 -0700"
        "Sun, 14 Apr 2019 04:05:00 -0700"
        "Sun, 21 Apr 2019 04:05:00 -0700"
    }
} [ "5 4 * * 7" next-few-times ] unit-test

! At 04:05 on every 3rd day-of-week from Monday through Sunday.
{
    {
        "Sun, 24 Mar 2019 04:05:00 -0700"
        "Mon, 25 Mar 2019 04:05:00 -0700"
        "Thu, 28 Mar 2019 04:05:00 -0700"
        "Sun, 31 Mar 2019 04:05:00 -0700"
        "Mon, 1 Apr 2019 04:05:00 -0700"
    }
} [ "5 4 * * 1/3" next-few-times ] unit-test

! At 04:05 on every 2nd day-of-month from 1 through 5.
{
    {
        "Mon, 1 Apr 2019 04:05:00 -0700"
        "Wed, 3 Apr 2019 04:05:00 -0700"
        "Fri, 5 Apr 2019 04:05:00 -0700"
        "Wed, 1 May 2019 04:05:00 -0700"
        "Fri, 3 May 2019 04:05:00 -0700"
    }
} [ "5 4 1-5/2 * *" next-few-times ] unit-test
