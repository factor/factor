USING: io.files kernel tools.test io.backend
io.windows.nt.files splitting ;
IN: io.windows.nt.files.tests

[ t ] [ "\\foo" absolute-path? ] unit-test
[ t ] [ "\\\\?\\foo" absolute-path? ] unit-test
[ t ] [ "c:\\foo" absolute-path? ] unit-test
[ t ] [ "c:" absolute-path? ] unit-test

[ "c:\\foo\\" ] [ "c:\\foo\\bar" parent-directory ] unit-test
[ "c:\\" ] [ "c:\\foo\\" parent-directory ] unit-test
[ "c:\\" ] [ "c:\\foo" parent-directory ] unit-test
! { "c:" "c:\\" "c:/" } [ directory ] each -- all do the same thing
[ "c:\\" ] [ "c:\\" parent-directory ] unit-test
[ "Z:\\" ] [ "Z:\\" parent-directory ] unit-test
[ "c:" ] [ "c:" parent-directory ] unit-test
[ "Z:" ] [ "Z:" parent-directory ] unit-test

[ f ] [ "" root-directory? ] unit-test
[ t ] [ "\\" root-directory? ] unit-test
[ t ] [ "\\\\" root-directory? ] unit-test
[ t ] [ "/" root-directory? ] unit-test
[ t ] [ "//" root-directory? ] unit-test
[ t ] [ "c:\\" right-trim-separators root-directory? ] unit-test
[ t ] [ "Z:\\" right-trim-separators root-directory? ] unit-test
[ f ] [ "c:\\foo" root-directory? ] unit-test
[ f ] [ "." root-directory? ] unit-test
[ f ] [ ".." root-directory? ] unit-test

[ ] [ "" resource-path cd ] unit-test

[ "\\foo\\bar" ] [ "/foo/bar" normalize-pathname ":" split1 nip ] unit-test

[ "\\\\?\\C:\\builds\\factor\\log.txt" ] [
    "C:\\builds\\factor\\12345\\"
    "..\\log.txt" append-path normalize-pathname
] unit-test

[ "\\\\?\\C:\\builds\\" ] [
    "C:\\builds\\factor\\12345\\"
    "..\\.." append-path normalize-pathname
] unit-test

[ "\\\\?\\C:\\builds\\" ] [
    "C:\\builds\\factor\\12345\\"
    "..\\.." append-path normalize-pathname
] unit-test
