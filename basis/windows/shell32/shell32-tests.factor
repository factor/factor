USING: accessors alien.c-types arrays classes.struct kernel sequences strings
system tools.test windows.shell32 ;
IN: windows.shell32.tests

{ t t } [
    NOTIFYICONDATA heap-size cpu x86.32? 956 976 ? =
    "dwState" NOTIFYICONDATA offset-of cpu x86.32? 280 296 ? =
] unit-test

! All three inline text fields use UTF-16, with room for a terminator.
{ t t } [
    254 CHAR: A <string> "\u01f600" append
    NOTIFYICONDATA new set-notify-icon-info szInfo>>
    [ 253 swap nth CHAR: A = ] [ 254 tail { 0 0 } sequence= ] bi
] unit-test

{ t t } [
    62 CHAR: A <string> "\u01f600" append
    NOTIFYICONDATA new set-notify-icon-info-title szInfoTitle>>
    [ 61 swap nth CHAR: A = ] [ 62 tail { 0 0 } sequence= ] bi
] unit-test

{ { 65 0 0 0 0 } } [
    "longer text" NOTIFYICONDATA new set-notify-icon-info
    "A" swap set-notify-icon-info szInfo>> 5 head >array
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
