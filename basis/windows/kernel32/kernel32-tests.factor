USING: accessors alien.c-types alien.data byte-arrays classes.struct
kernel locals math tools.test windows.errors windows.kernel32 windows.types ;
USE: continuations
IN: windows.kernel32.tests

! A throwing body must still release the lock on movable global memory.
{ 0 158 } [| |
    GMEM_MOVEABLE 16 GlobalAlloc :> handle
    [
        [ handle [ drop "test-global-lock" throw ] with-global-lock ] [ drop ] recover
        handle GlobalUnlock GetLastError
    ] [ handle GlobalFree drop ] finally
] unit-test

{ 16 4 600 } [
    TOKEN_PRIVILEGES heap-size
    "Privileges" TOKEN_PRIVILEGES offset-of
    WIN32_FIND_STREAM_DATA heap-size
] unit-test

! Read an owned buffer in this process and check the native SIZE_T output.
{ B{ 1 2 3 4 } 4 } [
    B{ 1 2 3 4 } 4 <byte-array> 0 SIZE_T <ref>
    [| source destination count |
        GetCurrentProcess source destination 4 count
        ReadProcessMemory win32-error=0/f
        destination count SIZE_T deref
    ] call
] unit-test

{ B{ 4 3 2 1 } 4 } [
    4 <byte-array> B{ 4 3 2 1 } 0 SIZE_T <ref>
    [| destination source count |
        GetCurrentProcess destination source 4 count
        WriteProcessMemory win32-error=0/f
        destination count SIZE_T deref
    ] call
] unit-test

! The SDK CopyMemory macro must resolve to a callable implementation.
{ B{ 1 2 3 4 } } [
    4 <byte-array> [ B{ 1 2 3 4 } 4 CopyMemory ] keep
] unit-test

! The attribute-list size query deliberately reports insufficient buffer.
{ t t } [
    0 SIZE_T <ref> [| size |
        f 1 0 size InitializeProcThreadAttributeList 0 =
        size SIZE_T deref 0 >
    ] call
] unit-test
