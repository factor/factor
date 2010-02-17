! (c)2010 Joe Groff bsd license
USING: alien.strings byte-arrays io.encodings.utf16n kernel
specialized-arrays system tools.deploy.libraries windows.kernel32
windows.types ;
FROM: alien.c-types => ushort ;
SPECIALIZED-ARRAY: ushort
IN: tools.deploy.libraries.windows

M: windows find-library-file
    f DONT_RESOLVE_DLL_REFERENCES LoadLibraryEx [
        [
            32768 (ushort-array) [ 32768 GetModuleFileName drop ] keep
            utf16n alien>string
        ] [ FreeLibrary drop ] bi
    ] [ f ] if* ;

