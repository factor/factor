! Copyright (C) 2010 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.data alien.strings byte-arrays
kernel specialized-arrays system tools.deploy.libraries
windows.kernel32 windows.types ;
FROM: alien.c-types => ushort ;
SPECIALIZED-ARRAY: ushort
IN: tools.deploy.libraries.windows

M: windows find-library-file
    f DONT_RESOLVE_DLL_REFERENCES LoadLibraryEx [
        [
            32768 ushort (c-array) [ 32768 GetModuleFileName drop ] keep
            alien>native-string
        ] [ FreeLibrary drop ] bi
    ] [ f ] if* ;
