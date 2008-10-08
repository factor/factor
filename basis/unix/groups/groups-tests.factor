! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test unix.groups kernel strings math ;
IN: unix.groups.tests


[ ] [ all-groups drop ] unit-test

\ all-groups must-infer

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
