! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test math kernel sets generic
ui.baseline-alignment ui.baseline-alignment.private ;

! Test baseline calculations
{ 10.0 0.0 } [ 0 10 0 10 combine-metrics ] unit-test
{ 10.0 5.0 } [ 0 10 5 10 combine-metrics ] unit-test
{ 15.0 15.0 } [ 30 0 0 0 combine-metrics ] unit-test
{ 5.0 30.0 } [ 10 0 30 0 combine-metrics ] unit-test
{ 10.0 10.0 } [ 5 10 10 10 combine-metrics ] unit-test
{ 15.0 5.0 } [ 20 10 0 10 combine-metrics ] unit-test
{ 15.0 40.0 } [ 20 10 40 10 combine-metrics ] unit-test
{ 12.0 3.0 } [ 0 12 3 9 combine-metrics ] unit-test

{ t } [ \ baseline \ cap-height [ dispatch-order ] bi@ set= ] unit-test
