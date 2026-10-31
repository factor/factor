USING: file-picker file-picker.freebsd generic kernel system tools.test ;
IN: file-picker.freebsd.tests

! Verify dispatch without opening a native dialog.
{ t } [
    freebsd \ open-file-dialog method-for-class
    unix \ open-file-dialog method-for-class eq?
] unit-test

{ t } [
    freebsd \ save-file-dialog method-for-class
    unix \ save-file-dialog method-for-class eq?
] unit-test
