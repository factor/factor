! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.data alien.strings combinators.short-circuit
environment io io.encodings io.encodings.utf16 io.streams.memory
kernel sequences specialized-arrays system windows windows.errors
windows.kernel32 windows.types windows.user32 ;
SPECIALIZED-ARRAY: TCHAR
IN: environment.windows

M: windows os-env
    0 SetLastError MAX_UNICODE_PATH TCHAR <c-array>
    [ dup length GetEnvironmentVariable ] keep
    { [ over 0 = ] [ GetLastError ERROR_ENVVAR_NOT_FOUND = ] } 0&&
    [ 2drop f ] [ nip alien>native-string ] if ;

M: windows set-os-env
    swap SetEnvironmentVariable win32-error=0/f ;

M: windows unset-os-env
    f SetEnvironmentVariable 0 = [
        GetLastError ERROR_ENVVAR_NOT_FOUND =
        [ win32-error ] unless
    ] when ;

M: windows (os-envs)
    GetEnvironmentStrings [
        [
            utf16n decode-input
            [ "\0" read-until drop dup empty? not ] [ ] produce nip
        ] with-memory-reader
    ] [ FreeEnvironmentStrings win32-error=0/f ] bi ;
