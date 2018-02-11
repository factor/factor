! Copyright (C) 2018 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test factor-shell ;
IN: factor-shell.tests

! Absolute paths
{ "/" } [ "/" canonicalize-path ] unit-test
{ "/" } [ "/." canonicalize-path ] unit-test
{ "/" } [ "/.." canonicalize-path ] unit-test
{ "/" } [ "/Users/.." canonicalize-path ] unit-test
{ "/" } [ "/Users/../" canonicalize-path ] unit-test
{ "/" } [ "/Users/../." canonicalize-path ] unit-test
{ "/" } [ "/Users/.././" canonicalize-path ] unit-test
{ "/" } [ "/Users/.././././././" canonicalize-path ] unit-test
{ "/" } [ "/Users/../././/////./././/././././//././././././." canonicalize-path ] unit-test
{ "/" } [ "/Users/../../../..////.././././././/../" canonicalize-path ] unit-test
{ "/Users" } [ "/Users/../../../Users" canonicalize-path ] unit-test

{ "/Users" } [ "/Users" canonicalize-path ] unit-test
{ "/Users" } [ "/Users/." canonicalize-path ] unit-test
{ "/Users/foo/bar" } [ "/Users/foo/bar" canonicalize-path ] unit-test


! Relative paths
{ "." } [ f canonicalize-path ] unit-test
{ "." } [ "" canonicalize-path ] unit-test
{ "." } [ "." canonicalize-path ] unit-test
{ "." } [ "./" canonicalize-path ] unit-test
{ "." } [ "./." canonicalize-path ] unit-test
{ ".." } [ ".." canonicalize-path ] unit-test
{ ".." } [ "../" canonicalize-path ] unit-test
{ ".." } [ "../." canonicalize-path ] unit-test
{ ".." } [ ".././././././//." canonicalize-path ] unit-test

{ "../.." } [ "../.." canonicalize-path ] unit-test
{ "../.." } [ "../../" canonicalize-path ] unit-test
{ "../.." } [ "../.././././/./././" canonicalize-path ] unit-test


! Root paths
{ "/" } [ "/" root-path ] unit-test
{ "/" } [ "/Users" root-path ] unit-test
{ "/" } [ "//" root-path ] unit-test
{ "/" } [ "//Users" root-path ] unit-test
{ "/" } [ "/Users/foo/bar////././." root-path ] unit-test
{ "/" } [ "/Users/////" root-path ] unit-test
