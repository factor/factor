! Copyright (C) 2013 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs calendar kernel math sequences sets
tools.test zoneinfo ;

{ t } [ "PST8PDT" find-zone-rules and >boolean ] unit-test

{
    T{ raw-zone
        { name "EST" }
        { gmt-offset "-5:00" }
        { rules/save "-" }
        { format "EST" }
        { until { } }
    }
} [
    "EST" find-zone
] unit-test

{
    T{ raw-zone
        { name "Pacific/Kiritimati" }
        { gmt-offset "14:00" }
        { rules/save "-" }
        { format "%z" }
        { until { } }
    }
} [
    "Pacific/Kiritimati" timezone>rules last
] unit-test

! First and last timezones + 24 hours = length of day
{ 50 } [
    now midnight "Etc/GMT+12" find-zone gmt-offset>> hms>duration >>gmt-offset
    now midnight "Etc/GMT-14" find-zone gmt-offset>> hms>duration >>gmt-offset
    time- duration>hours 24 +
] unit-test

! Make sure we handle # in weird places, like in "Europe/Athens"
{ } [
    raw-zone-map values
    [ [ gmt-offset>> ] map ] map concat members
    [ hms>duration ] map
    drop
] unit-test

