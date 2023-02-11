! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math sequences strings tools.test unix.groups ;
IN: unix.groups.tests

[ all-groups ] must-not-fail

{ t } [ real-group-name string? ] unit-test
{ t } [ effective-group-name string? ] unit-test

{ t } [ real-group-id integer? ] unit-test
{ t } [ effective-group-id integer? ] unit-test

{ } [ real-group-id set-real-group ] unit-test
{ } [ effective-group-id set-effective-group ] unit-test

{ } [ real-group-name [ ] with-real-group ] unit-test
{ } [ real-group-id [ ] with-real-group ] unit-test

{ } [ effective-group-name [ ] with-effective-group ] unit-test
{ } [ effective-group-id [ ] with-effective-group ] unit-test

{ } [ [ ] with-group-cache ] unit-test

[ real-group-id group-name ] must-not-fail

{ "888888888888888" } [ 888888888888888 group-name ] unit-test
{ f } [ "please-oh-please-don't-have-a-group-named-this123lalala" group-struct ] unit-test
{ f } [ "please-oh-please-don't-have-a-group-named-this123lalala" group-exists? ] unit-test
[ "please-oh-please-don't-have-a-group-named-this123lalala" ?group-id ] must-fail

{ 3 } [ f [ 3 ] with-effective-group ] unit-test
{ 3 } [ f [ 3 ] with-real-group ] unit-test

{ f }
[ all-groups drop all-groups empty? ] unit-test

{ f }
[ all-group-names drop all-group-names empty? ] unit-test

{ f }
[ "root" user-groups empty? ] unit-test

{ t }
[ "29032039029302930290390329uafjklajsdfkasjflaskjflsadkjfroot" user-groups empty? ] unit-test
