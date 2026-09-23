! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test math kernel sets generic ui.test
ui.baseline-alignment ui.baseline-alignment.private ;
IN: ui.baseline-alignment.tests

! These expectations use unscaled pixels, independently of the display DPI.
f [
{ 10.0 0.0 } [ 0 10 0 10 combine-metrics ] unscaled-ui-test unit-test
{ 10.0 5.0 } [ 0 10 5 10 combine-metrics ] unscaled-ui-test unit-test
{ 15.0 15.0 } [ 30 0 0 0 combine-metrics ] unscaled-ui-test unit-test
{ 5.0 30.0 } [ 10 0 30 0 combine-metrics ] unscaled-ui-test unit-test
{ 10.0 10.0 } [ 5 10 10 10 combine-metrics ] unscaled-ui-test unit-test
{ 15.0 5.0 } [ 20 10 0 10 combine-metrics ] unscaled-ui-test unit-test
{ 15.0 40.0 } [ 20 10 40 10 combine-metrics ] unscaled-ui-test unit-test
{ 12.0 3.0 } [ 0 12 3 9 combine-metrics ] unscaled-ui-test unit-test
] with-ui-test-scale

! Fractional display scales round in physical pixels, then return logical units.
{ 10.0 5.333333333333333 } [
    1.5 [ 0 10 5 10 combine-metrics ] with-ui-test-scale
] unit-test

{ 9.6 5.6 } [
    1.25 [ 0 10 5 10 combine-metrics ] with-ui-test-scale
] unit-test

{ 10.0 5.0 } [
    2.0 [ 0 10 5 10 combine-metrics ] with-ui-test-scale
] unit-test

{ t } [ \ baseline \ cap-height [ dispatch-order ] bi@ set= ] unit-test
