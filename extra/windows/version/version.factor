USING:
    alien alien.data alien.libraries alien.syntax
    destructors endian formatting kernel libc
    math math.bitwise
    sequences windows.types
;

IN: windows.version

<< "version" "version.dll" stdcall add-library >>

LIBRARY: version

FUNCTION: DWORD GetFileVersionInfoSizeA (
    LPCSTR  lptstrFilename,
    LPDWORD lpdwHandle )
FUNCTION: DWORD GetFileVersionInfoSizeW (
    LPCWSTR lptstrFilename,
    LPDWORD lpdwHandle )
ALIAS: GetFileVersionInfoSize GetFileVersionInfoSizeW

FUNCTION: BOOL GetFileVersionInfoA (
    LPCSTR lptstrFilename,
    DWORD  dwHandle,
    DWORD  dwLen,
    LPVOID lpData )
FUNCTION: BOOL GetFileVersionInfoW (
    LPCWSTR lptstrFilename,
    DWORD  dwHandle,
    DWORD  dwLen,
    LPVOID lpData )
ALIAS: GetFileVersionInfo GetFileVersionInfoW

FUNCTION: BOOL VerQueryValueA (
    LPCVOID pBlock,
    LPCSTR  lpSubBlock,
    LPVOID  *lplpBuffer,
    PUINT   puLen )
FUNCTION: BOOL VerQueryValueW (
    LPCVOID pBlock,
    LPCSTR  lpSubBlock,
    LPVOID  *lplpBuffer,
    PUINT   puLen )
ALIAS: VerQueryValue VerQueryValueW

: high-low ( integer -- high low )
    [ -16 shift ] [ 16 bits ] [ compose ] keep bi ;

: translation-prefix ( integer -- string )
    high-low swap "\\StringFileInfo\\%04x%04x\\" sprintf ;

: version-query ( integer -- string )
    translation-prefix "FileVersion" append ;

:: query-dword ( data query -- integer/f )
    f LPDWORD <ref> :> result
    data query result f VerQueryValue [
        result LPDWORD deref 4 memory>byte-array le>
    ] [ f ] if ;

:: query-str ( data query -- string/f )
    f LPCSTR <ref> :> result
    data query result f VerQueryValue [ result LPCSTR deref ] [ f ] if ;

: first-translation ( data -- integer/f )
    "\\VarFileInfo\\Translation" query-dword ;

:: (file-version) ( path data-size -- string/f )
    f :> res! [
        data-size malloc &free :> data
        path 0 data-size data GetFileVersionInfo [
            data first-translation [
                data swap version-query query-str res!
            ] when*
        ] when
    ] with-destructors res ;

: file-version ( path -- string/f )
    dup f GetFileVersionInfoSize dup 0 > [ (file-version) ] [ 2drop f ] if ;
