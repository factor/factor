! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test unix.groups kernel strings math ;
IN: unix.groups.tests

[ ] [ all-groups drop ] unit-test

[ t ] [ real-group-name string? ] unit-test
[ t ] [ effective-group-name string? ] unit-test

[ t ] [ real-group-id integer? ] unit-test
[ t ] [ effective-group-id integer? ] unit-test

[ ] [ real-group-id set-real-group ] unit-test
[ ] [ effective-group-id set-effective-group ] unit-test

[ ] [ real-group-name [ ] with-real-group ] unit-test
[ ] [ real-group-id [ ] with-real-group ] unit-test

[ ] [ effective-group-name [ ] with-effective-group ] unit-test
[ ] [ effective-group-id [ ] with-effective-group ] unit-test

[ ] [ [ ] with-group-cache ] unit-test

[ ] [ real-group-id group-name drop ] unit-test

[ "888888888888888" ] [ 888888888888888 group-name ] unit-test
[ f ]
[ "please-oh-please-don't-have-a-group-named-this123lalala" group-struct ] unit-test
