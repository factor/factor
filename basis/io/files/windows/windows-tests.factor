! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators continuations io.backend io.directories io.files
io.files.temp io.files.windows io.pathnames kernel kernel.private libc
literals memory sequences splitting tools.test windows.kernel32
io.files.unique destructors ;

{ f } [ "\\foo" absolute-path? ] unit-test
{ t } [ "\\\\?\\c:\\foo" absolute-path? ] unit-test
{ t } [ "\\\\?\\c:\\" absolute-path? ] unit-test
{ t } [ "\\\\?\\c:" absolute-path? ] unit-test
{ t } [ "c:\\foo" absolute-path? ] unit-test
{ t } [ "c:" absolute-path? ] unit-test
{ t } [ "c:\\" absolute-path? ] unit-test
{ f } [ "/cygdrive/c/builds" absolute-path? ] unit-test

{ "c:\\foo\\" } [ "c:\\foo\\bar" parent-directory ] unit-test
{ "c:\\" } [ "c:\\foo\\" parent-directory ] unit-test
{ "c:\\" } [ "c:\\foo" parent-directory ] unit-test
! { "c:" "c:\\" "c:/" } [ directory ] each -- all do the same thing
{ "c:\\" } [ "c:\\" parent-directory ] unit-test
{ "Z:\\" } [ "Z:\\" parent-directory ] unit-test
{ "c:" } [ "c:" parent-directory ] unit-test
{ "Z:" } [ "Z:" parent-directory ] unit-test

{ f } [ "" root-directory? ] unit-test
{ t } [ "\\" root-directory? ] unit-test
{ t } [ "\\\\" root-directory? ] unit-test
{ t } [ "/" root-directory? ] unit-test
{ t } [ "//" root-directory? ] unit-test
{ t } [ "c:\\" trim-tail-separators root-directory? ] unit-test
{ t } [ "Z:\\" trim-tail-separators root-directory? ] unit-test
{ f } [ "c:\\foo" root-directory? ] unit-test
{ f } [ "." root-directory? ] unit-test
{ f } [ ".." root-directory? ] unit-test
{ t } [ "\\\\?\\c:\\" root-directory? ] unit-test
{ t } [ "\\\\?\\c:" root-directory? ] unit-test
{ f } [ "\\\\?\\c:\\bar" root-directory? ] unit-test

{ "\\\\a\\b\\c\\foo.xls" } [ "//a/b/c/foo.xls" normalize-path ] unit-test
{ "\\\\a\\b\\c\\foo.xls" } [ "\\\\a\\b\\c\\foo.xls" normalize-path ] unit-test

{ "\\foo\\bar" } [ "/foo/bar" normalize-path ":" split1 nip ] unit-test

{ "\\\\?\\C:\\builds\\factor\\log.txt" } [
    "C:\\builds\\factor\\12345\\"
    "..\\log.txt" append-path normalize-path
] unit-test

{ "\\\\?\\C:\\builds\\" } [
    "C:\\builds\\factor\\12345\\"
    "..\\.." append-path normalize-path
] unit-test

{ "\\\\?\\C:\\builds\\" } [
    "C:\\builds\\factor\\12345\\"
    "..\\.." append-path normalize-path
] unit-test

{ "c:\\blah" } [ "c:\\foo\\bar" "\\blah" append-path ] unit-test
{ t } [ "" resource-path 2 tail file-exists? ] unit-test

! win32-file-attributes
{
    { +read-only+ +hidden+ }
} [
    3 win32-file-attributes
] unit-test

! set-file-attributes & save-image
{ ${ KERNEL-ERROR ERROR-IO EIO f } } [
    [
        "read-only.image" temp-file {
            [ ?delete-file ]
            [ touch-file ]
            [ FILE_ATTRIBUTE_READONLY set-file-attributes ]
            [ save-image ]
        } cleave
    ] [ ] recover
] unit-test

! test that we can open a shared file
! https://github.com/factor/factor/pull/1636
{ } [
    "open-file-" "-test.txt" [
        [ open-write ] [ open-read ] bi [ dispose ] bi@
    ] cleanup-unique-file
] unit-test
