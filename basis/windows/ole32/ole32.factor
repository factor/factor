USING: accessors alien.c-types alien.data alien.syntax
classes.struct combinators combinators.smart grouping kernel
literals math.order math.parser parser sequences
specialized-arrays splitting windows.errors windows.kernel32
windows.types words.constant ;
SPECIALIZED-ARRAY: uchar
IN: windows.ole32

LIBRARY: ole32

TYPEDEF: GUID* REFGUID
TYPEDEF: void* LPUNKNOWN
TYPEDEF: LPWSTR OLESTR
TYPEDEF: LPWSTR LPOLESTR
TYPEDEF: LPWSTR LPCOLESTR
TYPEDEF: wchar_t* OLECHAR
TYPEDEF: OLESTR** SNB

TYPEDEF: GUID IID
TYPEDEF: GUID CLSID

TYPEDEF: REFGUID LPGUID
TYPEDEF: REFGUID LPCGUID
TYPEDEF: REFGUID REFIID
TYPEDEF: REFGUID REFCLSID

FUNCTION: HRESULT CoInitialize ( LPVOID pvReserved )
FUNCTION: void CoUninitialize ( )

FUNCTION: HRESULT CoCreateInstance ( REFGUID rclsid, LPUNKNOWN pUnkOuter, DWORD dwClsContext, REFGUID riid, LPUNKNOWN out_ppv )
FUNCTION: HRESULT CoCreateGuid ( GUID* pguid )
FUNCTION: BOOL IsEqualGUID ( REFGUID rguid1, REFGUID rguid2 )
FUNCTION: int StringFromGUID2 ( REFGUID rguid, LPOLESTR lpsz, int cchMax )
FUNCTION: HRESULT CLSIDFromString ( LPOLESTR lpsz, REFGUID out_rguid )

FUNCTION: LPVOID CoTaskMemAlloc ( SIZE_T cb )
FUNCTION: LPVOID CoTaskMemRealloc ( LPVOID pv, SIZE_T cb )
FUNCTION: void CoTaskMemFree ( LPVOID pv )
FUNCTION: HRESULT CreateStreamOnHGlobal ( HGLOBAL hGlobal, BOOL fDeleteOnRelease, LPVOID* ppstm )
FUNCTION: HRESULT CoGetClassObject ( REFCLSID rclsid, DWORD dwClsContext, LPVOID pvReserved, REFIID riid, LPVOID *ppv )

CONSTANT: S_OK 0
CONSTANT: S_FALSE 1
CONSTANT: DRAGDROP_S_DROP 0x00040100
CONSTANT: DRAGDROP_S_CANCEL 0x00040101
CONSTANT: DRAGDROP_S_USEDEFAULTCURSORS 0x00040102

ERROR: hresult-error n ;

: check-hresult ( n -- )
    dup S_OK = [ drop ] [ hresult-error ] if ;

<<
: >long ( integer -- long )
    long <ref> long deref ; inline
>>
<<
SYNTAX: LONG: scan-new-word scan-object >long define-constant ;
>>

LONG: E_NOTIMPL 0x80004001
LONG: E_NOINTERFACE 0x80004002
LONG: E_FAIL 0x80004005
LONG: E_UNEXPECTED 0x8000FFFF
LONG: E_OUTOFMEMORY 0x8007000E
LONG: E_INVALIDARG 0x80070057

LONG: OLE_E_OLEVERB 0x80040000
LONG: OLE_E_ADVF 0x80040001
LONG: OLE_E_ENUM_NOMORE 0x80040002
LONG: OLE_E_ADVISENOTSUPPORTED 0x80040003
LONG: OLE_E_NOCONNECTION 0x80040004
LONG: OLE_E_NOTRUNNING 0x80040005
LONG: OLE_E_NOCACHE 0x80040006
LONG: OLE_E_BLANK 0x80040007
LONG: OLE_E_CLASSDIFF 0x80040008
LONG: OLE_E_CANT_GETMONIKER 0x80040009
LONG: OLE_E_CANT_BINDTOSOURCE 0x8004000A
LONG: OLE_E_STATIC 0x8004000B
LONG: OLE_E_PROMPTSAVECANCELLED 0x8004000C
LONG: OLE_E_INVALIDRECT 0x8004000D
LONG: OLE_E_WRONGCOMPOBJ 0x8004000E
LONG: OLE_E_INVALIDHWND 0x8004000F
LONG: OLE_E_NOT_INPLACEACTIVE 0x80040010
LONG: OLE_E_CANTCONVERT 0x80040011
LONG: OLE_E_NOSTORAGE 0x80040012

LONG: CO_E_NOTINITIALIZED 0x800401F0
LONG: CO_E_ALREADYINITIALIZED 0x800401F1
LONG: CO_E_CANTDETERMINECLASS 0x800401F2
LONG: CO_E_CLASSSTRING 0x800401F3
LONG: CO_E_IIDSTRING 0x800401F4
LONG: CO_E_APPNOTFOUND 0x800401F5
LONG: CO_E_APPSINGLEUSE 0x800401F6
LONG: CO_E_ERRORINAPP 0x800401F7
LONG: CO_E_DLLNOTFOUND 0x800401F8
LONG: CO_E_ERRORINDLL 0x800401F9
LONG: CO_E_WRONGOSFORAPP 0x800401FA
LONG: CO_E_OBJNOTREG 0x800401FB
LONG: CO_E_OBJISREG 0x800401FC
LONG: CO_E_OBJNOTCONNECTED 0x800401FD
LONG: CO_E_APPDIDNTREG 0x800401FE
LONG: CO_E_RELEASED 0x800401FF

CONSTANT: MK_ALT 0x20
CONSTANT: DROPEFFECT_NONE 0
CONSTANT: DROPEFFECT_COPY 1
CONSTANT: DROPEFFECT_MOVE 2
CONSTANT: DROPEFFECT_LINK 4
CONSTANT: DROPEFFECT_SCROLL 0x80000000
CONSTANT: DD_DEFSCROLLINSET 11
CONSTANT: DD_DEFSCROLLDELAY 50
CONSTANT: DD_DEFSCROLLINTERVAL 50
CONSTANT: DD_DEFDRAGDELAY 200
CONSTANT: DD_DEFDRAGMINDIST 2

CONSTANT: DVASPECT_CONTENT    1
CONSTANT: DVASPECT_THUMBNAIL  2
CONSTANT: DVASPECT_ICON       4
CONSTANT: DVASPECT_DOCPRINT   8

CONSTANT: TYMED_HGLOBAL  1
CONSTANT: TYMED_FILE     2
CONSTANT: TYMED_ISTREAM  4
CONSTANT: TYMED_ISTORAGE 8
CONSTANT: TYMED_GDI      16
CONSTANT: TYMED_MFPICT   32
CONSTANT: TYMED_ENHMF    64
CONSTANT: TYMED_NULL     0

STRUCT: DVTARGETDEVICE
    { tdSize DWORD }
    { tdDriverNameOffset WORD }
    { tdDeviceNameOffset WORD }
    { tdPortNameOffset WORD }
    { tdExtDevmodeOffset WORD }
    { tdData BYTE[1] } ;

TYPEDEF: WORD CLIPFORMAT
TYPEDEF: POINT POINTL

STRUCT: FORMATETC
    { cfFormat CLIPFORMAT }
    { ptd DVTARGETDEVICE* }
    { dwAspect DWORD }
    { lindex LONG }
    { tymed DWORD } ;
TYPEDEF: FORMATETC* LPFORMATETC

STRUCT: STGMEDIUM
    { tymed DWORD }
    { data void* }
    { punkForRelease LPUNKNOWN } ;
TYPEDEF: STGMEDIUM* LPSTGMEDIUM

CONSTANT: COINIT_MULTITHREADED     0
CONSTANT: COINIT_APARTMENTTHREADED 2
CONSTANT: COINIT_DISABLE_OLE1DDE   4
CONSTANT: COINIT_SPEED_OVER_MEMORY 8

FUNCTION: HRESULT OleInitialize ( void* reserved )
FUNCTION: HRESULT CoInitializeEx ( void* reserved, DWORD dwCoInit )

: succeeded? ( hresult -- ? )
    0 0x7FFFFFFF between? ;

TUPLE: ole32-error code message ;

: <ole32-error> ( code -- error )
    dup n>win32-error-string \ ole32-error boa ;

: check-ole32-error ( hresult -- )
    dup succeeded? [ drop ] [ <ole32-error> throw ] if ;

: ole-initialize ( -- )
    f OleInitialize check-ole32-error ;

: guid= ( a b -- ? )
    [ 16 memory>byte-array ] same? ;

CONSTANT: GUID-STRING-LENGTH
    $[ "{01234567-89ab-cdef-0123-456789abcdef}" length ]

: create-guid ( -- GUID )
    GUID new dup CoCreateGuid check-ole32-error ;

: string>guid ( string -- guid )
    "{-}" split harvest
    [ first3 [ hex> ] tri@ ]
    [ 3 tail concat 2 group [ hex> ] B{ } map-as ] bi
    GUID boa ;

: guid>string ( guid -- string )
    [
        [ "{" ] dip {
            [ Data1>> >hex 8 CHAR: 0 pad-head "-" ]
            [ Data2>> >hex 4 CHAR: 0 pad-head "-" ]
            [ Data3>> >hex 4 CHAR: 0 pad-head "-" ]
            [
                Data4>> [
                    {
                        [ >hex 2 CHAR: 0 pad-head ]
                        [ >hex 2 CHAR: 0 pad-head "-" ]
                        [ >hex 2 CHAR: 0 pad-head ]
                        [ >hex 2 CHAR: 0 pad-head ]
                        [ >hex 2 CHAR: 0 pad-head ]
                        [ >hex 2 CHAR: 0 pad-head ]
                        [ >hex 2 CHAR: 0 pad-head ]
                        [ >hex 2 CHAR: 0 pad-head ]
                    } spread
                ] input<sequence "}"
            ]
        } cleave
    ] "" append-outputs-as ;
