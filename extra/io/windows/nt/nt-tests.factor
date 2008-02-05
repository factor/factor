USING: io.files kernel tools.test io.backend splitting ;
IN: temporary

[ "c:\\foo\\" ] [ "c:\\foo\\bar" parent-directory ] unit-test
[ "c:\\" ] [ "c:\\foo\\" parent-directory ] unit-test
[ "c:\\" ] [ "c:\\foo" parent-directory ] unit-test
! { "c:" "c:\\" "c:/" } [ directory ] each -- all do the same thing
[ "c:" ] [ "c:\\" parent-directory ] unit-test
[ "Z:" ] [ "Z:\\" parent-directory ] unit-test
[ "c:" ] [ "c:" parent-directory ] unit-test
[ "Z:" ] [ "Z:" parent-directory ] unit-test
[ t ] [ "c:\\" trim-path-separators root-directory? ] unit-test
[ t ] [ "Z:\\" trim-path-separators root-directory? ] unit-test
[ f ] [ "c:\\foo" root-directory? ] unit-test
[ f ] [ "." root-directory? ] unit-test
[ f ] [ ".." root-directory? ] unit-test

[ ] [ "" resource-path cd ] unit-test

[ "\\foo\\bar" ] [ "/foo/bar" normalize-pathname ":" split1 nip ] unit-test
