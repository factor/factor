! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test math kernel sets generic
ui.baseline-alignment ui.baseline-alignment.private ;

! Test baseline calculations
{ 10 0 } [ 0 10 0 10 combine-metrics ] unit-test
{ 10 5 } [ 0 10 5 10 combine-metrics ] unit-test
{ 15 15 } [ 30 0 0 0 combine-metrics ] unit-test
{ 5 30 } [ 10 0 30 0 combine-metrics ] unit-test
{ 10 10 } [ 5 10 10 10 combine-metrics ] unit-test
{ 15 5 } [ 20 10 0 10 combine-metrics ] unit-test
{ 15 40 } [ 20 10 40 10 combine-metrics ] unit-test
{ 12 3 } [ 0 12 3 9 combine-metrics ] unit-test

{ t } [ \ baseline \ cap-height [ dispatch-order ] bi@ set= ] unit-test
