! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: windows.kernel32 windows.ole32 prettyprint.custom
prettyprint.sections sequences ;

M: GUID pprint* guid>string "GUID: " prepend text ;
