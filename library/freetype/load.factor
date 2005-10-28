USING: alien io kernel parser sequences ;

"freetype" @{
    @{ [ os "macosx" = ] [ "libfreetype.dylib" ] }@
    @{ [ os "win32" = ] [ "freetype6.dll" ] }@
    @{ [ t ] [ "libfreetype.so" ] }@
}@ cond "cdecl" add-library
    
[
    "/library/freetype/freetype.factor"
    "/library/freetype/freetype-gl.factor"
] [
    dup print run-resource
] each
