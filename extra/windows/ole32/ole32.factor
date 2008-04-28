USING: alien alien.syntax alien.c-types alien.strings math
kernel sequences windows windows.types combinators.lib ;
IN: windows.ole32

LIBRARY: ole32

C-STRUCT: GUID
    { "DWORD" "part1" }
    { "DWORD" "part2" }
    { "DWORD" "part3" }
    { "DWORD" "part4" } ;

TYPEDEF: void* REFGUID
TYPEDEF: void* LPUNKNOWN
TYPEDEF: wchar_t* LPOLESTR
TYPEDEF: wchar_t* LPCOLESTR

TYPEDEF: REFGUID REFIID
TYPEDEF: REFGUID REFCLSID

FUNCTION: HRESULT CoCreateInstance ( REFGUID rclsid, LPUNKNOWN pUnkOuter, DWORD dwClsContext, REFGUID riid, LPUNKNOWN out_ppv ) ;
FUNCTION: BOOL IsEqualGUID ( REFGUID rguid1, REFGUID rguid2 ) ;
FUNCTION: int StringFromGUID2 ( REFGUID rguid, LPOLESTR lpsz, int cchMax ) ;
FUNCTION: HRESULT CLSIDFromString ( LPOLESTR lpsz, REFGUID out_rguid ) ;

: S_OK 0 ; inline
: S_FALSE 1 ; inline
: E_FAIL HEX: 80004005 ; inline
: E_INVALIDARG HEX: 80070057 ; inline

: MK_ALT HEX: 20 ; inline
: DROPEFFECT_NONE 0 ; inline
: DROPEFFECT_COPY 1 ; inline
: DROPEFFECT_MOVE 2 ; inline
: DROPEFFECT_LINK 4 ; inline
: DROPEFFECT_SCROLL HEX: 80000000 ; inline
: DD_DEFSCROLLINSET 11 ; inline
: DD_DEFSCROLLDELAY 50 ; inline
: DD_DEFSCROLLINTERVAL 50 ; inline
: DD_DEFDRAGDELAY 200 ; inline
: DD_DEFDRAGMINDIST 2 ; inline

: ole32-error ( n -- )
    dup S_OK = [
        drop
    ] [ (win32-error-string) throw ] if ;

: guid= ( a b -- ? )
    IsEqualGUID c-bool> ;

: GUID-STRING-LENGTH
    "{01234567-89ab-cdef-0123-456789abcdef}" length ; inline

: string>guid ( string -- guid )
    utf16n string>alien "GUID" <c-object> [ CLSIDFromString ole32-error ] keep ;
: guid>string ( guid -- string )
    GUID-STRING-LENGTH 1+ [ "ushort" <c-array> ] keep
    [ StringFromGUID2 drop ] { 2 } multikeep utf16n alien>string ;

