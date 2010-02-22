USING: io.files io.pathnames kernel tools.test io.backend
io.files.windows.nt splitting sequences io.pathnames.private ;
IN: io.files.windows.nt.tests

[ f ] [ "\\foo" absolute-path? ] unit-test
[ t ] [ "\\\\?\\c:\\foo" absolute-path? ] unit-test
[ t ] [ "\\\\?\\c:\\" absolute-path? ] unit-test
[ t ] [ "\\\\?\\c:" absolute-path? ] unit-test
[ t ] [ "c:\\foo" absolute-path? ] unit-test
[ t ] [ "c:" absolute-path? ] unit-test
[ t ] [ "c:\\" absolute-path? ] unit-test
[ f ] [ "/cygdrive/c/builds" absolute-path? ] unit-test

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
[ t ] [ "c:\\" trim-tail-separators root-directory? ] unit-test
[ t ] [ "Z:\\" trim-tail-separators root-directory? ] unit-test
[ f ] [ "c:\\foo" root-directory? ] unit-test
[ f ] [ "." root-directory? ] unit-test
[ f ] [ ".." root-directory? ] unit-test
[ t ] [ "\\\\?\\c:\\" root-directory? ] unit-test
[ t ] [ "\\\\?\\c:" root-directory? ] unit-test
[ f ] [ "\\\\?\\c:\\bar" root-directory? ] unit-test

[ "\\foo\\bar" ] [ "/foo/bar" normalize-path ":" split1 nip ] unit-test

[ "\\\\?\\C:\\builds\\factor\\log.txt" ] [
    "C:\\builds\\factor\\12345\\"
    "..\\log.txt" append-path normalize-path
] unit-test

[ "\\\\?\\C:\\builds\\" ] [
    "C:\\builds\\factor\\12345\\"
    "..\\.." append-path normalize-path
] unit-test

[ "\\\\?\\C:\\builds\\" ] [
    "C:\\builds\\factor\\12345\\"
    "..\\.." append-path normalize-path
] unit-test

[ "c:\\blah" ] [ "c:\\foo\\bar" "\\blah" append-path ] unit-test
[ t ] [ "" resource-path 2 tail exists? ] unit-test
