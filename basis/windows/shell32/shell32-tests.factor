USING: accessors alien.c-types arrays classes.struct kernel sequences strings
system tools.test windows.shell32 ;
IN: windows.shell32.tests

{ t t } [
    NOTIFYICONDATA heap-size cpu x86.32? 956 976 ? =
    "dwState" NOTIFYICONDATA offset-of cpu x86.32? 280 296 ? =
] unit-test

{ { 65 937 55357 56832 0 } } [
    "AΩ😀" NOTIFYICONDATA new set-notify-icon-tip szTip>> 5 head >array
] unit-test

! Truncation must not leave half a surrogate pair or lose the terminator.
{ 65 0 0 } [
    126 CHAR: A <string> "😀" append
    NOTIFYICONDATA new set-notify-icon-tip szTip>>
    [ 125 swap nth ] [ 126 swap nth ] [ 127 swap nth ] tri
] unit-test
