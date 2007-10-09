USING: io.files kernel tools.test ;
IN: temporary

[ "c:\\foo\\" ] [ "c:\\foo\\bar" parent-dir ] unit-test
[ "c:\\" ] [ "c:\\foo\\" parent-dir ] unit-test
[ "c:\\" ] [ "c:\\foo" parent-dir ] unit-test
! { "c:" "c:\\" "c:/" } [ directory ] each -- all do the same thing
[ "c:\\" ] [ "c:\\" parent-dir ] unit-test
[ "Z:\\" ] [ "Z:\\" parent-dir ] unit-test
[ "c:" ] [ "c:" parent-dir ] unit-test
[ "Z:" ] [ "Z:" parent-dir ] unit-test
[ t ] [ "c:\\" root-directory? ] unit-test
[ t ] [ "Z:\\" root-directory? ] unit-test
[ f ] [ "c:\\foo" root-directory? ] unit-test
[ f ] [ "." root-directory? ] unit-test
[ f ] [ ".." root-directory? ] unit-test
