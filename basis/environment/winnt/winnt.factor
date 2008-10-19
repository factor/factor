! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.strings fry io.encodings.utf16 kernel
splitting windows windows.kernel32 ;
IN: environment.winnt

M: winnt os-env ( key -- value )
    MAX_UNICODE_PATH "TCHAR" <c-array>
    [ GetEnvironmentVariable ] keep over 0 = [
        2drop f
    ] [
        nip utf16 alien>string
    ] if ;

M: winnt set-os-env ( value key -- )
    swap SetEnvironmentVariable win32-error=0/f ;

M: winnt unset-os-env ( key -- )
    f SetEnvironmentVariable 0 = [
        GetLastError ERROR_ENVVAR_NOT_FOUND =
        [ win32-error ] unless
    ] when ;

M: winnt (os-envs) ( -- seq )
    GetEnvironmentStrings [ "\0" split ] [ FreeEnvironmentStrings ] bi ;
