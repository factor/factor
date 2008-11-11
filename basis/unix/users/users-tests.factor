! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test unix.users kernel strings math ;
IN: unix.users.tests


[ ] [ all-users drop ] unit-test

\ all-users must-infer

[ t ] [ real-username string? ] unit-test
[ t ] [ effective-username string? ] unit-test

[ t ] [ real-user-id integer? ] unit-test
[ t ] [ effective-user-id integer? ] unit-test

[ ] [ real-user-id set-real-user ] unit-test
[ ] [ effective-user-id set-effective-user ] unit-test

[ ] [ real-username [ ] with-real-user ] unit-test
[ ] [ real-user-id [ ] with-real-user ] unit-test

[ ] [ effective-username [ ] with-effective-user ] unit-test
[ ] [ effective-user-id [ ] with-effective-user ] unit-test

[ ] [ [ ] with-user-cache ] unit-test
