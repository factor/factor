! Copyright (C) 2013 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel tools.test zoneinfo ;
IN: zoneinfo.tests

{ t }
[ "PST8PDT" find-zone-rules and >boolean ] unit-test
