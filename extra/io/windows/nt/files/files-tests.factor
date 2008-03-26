USING: kernel tools.test ;
IN: io.windows.nt.files.tests

[ f ] [ "" root-directory? ] unit-test
[ t ] [ "\\" root-directory? ] unit-test
[ t ] [ "\\\\" root-directory? ] unit-test
[ t ] [ "\\\\\\\\\\\\" root-directory? ] unit-test
[ t ] [ "/" root-directory? ] unit-test
[ t ] [ "//" root-directory? ] unit-test
[ t ] [ "//////////////" root-directory? ] unit-test
[ t ] [ "\\foo" absolute-path? ] unit-test
[ t ] [ "\\\\?\\foo" absolute-path? ] unit-test
[ t ] [ "c:\\foo" absolute-path? ] unit-test
[ t ] [ "c:" absolute-path? ] unit-test

