! Copyright (C) 2013 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences tools.test zoneinfo ;

{ t } [ "PST8PDT" find-zone-rules and >boolean ] unit-test

{ 13 } [ zoneinfo-paths length ] unit-test

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
