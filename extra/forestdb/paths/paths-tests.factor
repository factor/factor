! Copyright (C) 2014 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: forestdb.paths kernel tools.test ;
IN: forestdb.paths.tests

{ "1.fq.0" } [ "0.fq.0" next-vnode-name ] unit-test
{ "1.fq.0" } [ "0.fq.1" next-vnode-name ] unit-test
{ "100.fq.0" } [ "99.fq.0" next-vnode-name ] unit-test
{ "100.fq.0" } [ "99.fq.1" next-vnode-name ] unit-test
{ "100.fq.0" } [ "99.fq.20" next-vnode-name ] unit-test
{ "100.fq.0" } [ "099.fq.20" next-vnode-name ] unit-test
{ "0100.fq.0" } [ "0099.fq.20" next-vnode-name ] unit-test

{ "00001.fq.0" } [ "00000.fq.0" next-vnode-name ] unit-test
{ "001.fq.0" } [ "000.fq.1" next-vnode-name ] unit-test
{ "000100.fq.0" } [ "000099.fq.0" next-vnode-name ] unit-test
{ "00100.fq.0" } [ "00099.fq.1" next-vnode-name ] unit-test
{ "00000000100.fq.0" } [ "00000000099.fq.20" next-vnode-name ] unit-test

{ "0.fq.0" } [ "00.fq.00" canonical-fdb-name ] unit-test
{ "1.fq.0" } [ "01.fq.00" canonical-fdb-name ] unit-test
{ "0.fq.1" } [ "00.fq.01" canonical-fdb-name ] unit-test
{ "100.fq.10" } [ "000100.fq.010" canonical-fdb-name ] unit-test

{ "0.fq.1" } [ "0.fq.0" next-vnode-version-name ] unit-test
{ "0.fq.2" } [ "0.fq.1" next-vnode-version-name ] unit-test
{ "99.fq.1" } [ "99.fq.0" next-vnode-version-name ] unit-test
{ "99.fq.2" } [ "99.fq.1" next-vnode-version-name ] unit-test
{ "99.fq.21" } [ "99.fq.20" next-vnode-version-name ] unit-test

[ "fq" ensure-fdb-filename drop ] [ not-an-fdb-filename? ] must-fail-with
[ "0.fq" ensure-fdb-filename drop ] [ not-an-fdb-filename? ] must-fail-with
[ "0.fq." ensure-fdb-filename drop ] [ not-an-fdb-filename? ] must-fail-with
[ ".fq.0" ensure-fdb-filename drop ] [ not-an-fdb-filename? ] must-fail-with
[ "1fq.0" ensure-fdb-filename drop ] [ not-an-fdb-filename? ] must-fail-with
[ "1fq0" ensure-fdb-filename drop ] [ not-an-fdb-filename? ] must-fail-with
[ "1.fq0" ensure-fdb-filename drop ] [ not-an-fdb-filename? ] must-fail-with
[ "1.fq.0.0" ensure-fdb-filename drop ] [ not-an-fdb-filename? ] must-fail-with
[ "1.fq.00." ensure-fdb-filename drop ] [ not-an-fdb-filename? ] must-fail-with
