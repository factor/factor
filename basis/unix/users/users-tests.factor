! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test unix.users kernel strings math sequences ;
IN: unix.users.tests

{ } [ all-users drop ] unit-test

{ t } [ real-user-name string? ] unit-test
{ t } [ effective-user-name string? ] unit-test

{ t } [ real-user-id integer? ] unit-test
{ t } [ effective-user-id integer? ] unit-test

{ } [ real-user-id set-real-user ] unit-test
{ } [ effective-user-id set-effective-user ] unit-test

{ } [ real-user-name [ ] with-real-user ] unit-test
{ } [ real-user-id [ ] with-real-user ] unit-test

{ } [ effective-user-name [ ] with-effective-user ] unit-test
{ } [ effective-user-id [ ] with-effective-user ] unit-test

{ } [ [ ] with-user-cache ] unit-test

{ "9999999999999999999" } [ 9999999999999999999 user-name ] unit-test

{ f } [ 89898989898989898989898989898 user-passwd ] unit-test

{ f } [ "thisusershouldnotexistabcdefg12345asdfasdfasdfasdfasdfasdfasdf" user-id ] unit-test
{ f } [ "thisusershouldnotexistabcdefg12345asdfasdfasdfasdfasdfasdfasdf" user-exists? ] unit-test
[ "thisusershouldnotexistabcdefg12345asdfasdfasdfasdfasdfasdfasdf" ?user-id ] must-fail

{ 3 } [ f [ 3 ] with-effective-user ] unit-test
{ 3 } [ f [ 3 ] with-real-user ] unit-test

{ f }
[ all-users drop all-users empty? ] unit-test

{ f }
[ all-user-names drop all-user-names empty? ] unit-test
