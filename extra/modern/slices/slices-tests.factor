! Copyright (C) 2019 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: ascii modern.slices sequences tools.test ;
IN: modern.slices.tests

{ "foo:" f f f } [
    "foo:" f slice-til-not-whitespace
] unit-test

{ "foo:" f f f } [
    "foo:" f slice-til-whitespace
] unit-test

{ "foo:" 0 T{ slice f 0 0 "foo:" } 102 } [
    "foo:" 0 slice-til-not-whitespace
] unit-test

{ "foo:" 3 T{ slice f 3 3 "foo:" } 58 } [
    "foo:" 3 slice-til-not-whitespace
] unit-test

{ "foo:" f T{ slice f 0 4 "foo:" } f } [
    "foo:" 0 slice-til-whitespace
] unit-test

{ "foo:" f T{ slice f 3 4 "foo:" } f } [
    "foo:" 3 slice-til-whitespace
] unit-test

{ "foo " f T{ slice f 0 4 "foo " } f } [
    "foo " 0 [ blank? ] slice-until-include
] unit-test

{ "foo " 3 T{ slice f 0 3 "foo " } 32 } [
    "foo " 0 [ blank? ] slice-until-exclude
] unit-test
