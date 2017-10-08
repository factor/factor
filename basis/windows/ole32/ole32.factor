USING: alien alien.syntax alien.c-types alien.data alien.strings
math kernel sequences windows.errors windows.types io accessors
math.order namespaces make math.parser windows.kernel32
combinators locals specialized-arrays literals splitting
grouping classes.struct combinators.smart ;
SPECIALIZED-ARRAY: uchar
IN: windows.ole32

LIBRARY: ole32

TYPEDEF: GUID* REFGUID
TYPEDEF: void* LPUNKNOWN
TYPEDEF: LPWSTR LPOLESTR
TYPEDEF: LPWSTR LPCOLESTR

TYPEDEF: GUID IID
TYPEDEF: GUID CLSID

TYPEDEF: REFGUID LPGUID
TYPEDEF: REFGUID LPCGUID
TYPEDEF: REFGUID REFIID
TYPEDEF: REFGUID REFCLSID

FUNCTION: HRESULT CoCreateInstance ( REFGUID rclsid, LPUNKNOWN pUnkOuter, DWORD dwClsContext, REFGUID riid, LPUNKNOWN out_ppv )
FUNCTION: HRESULT CoCreateGuid ( GUID* pguid )
FUNCTION: BOOL IsEqualGUID ( REFGUID rguid1, REFGUID rguid2 )
FUNCTION: int StringFromGUID2 ( REFGUID rguid, LPOLESTR lpsz, int cchMax )
FUNCTION: HRESULT CLSIDFromString ( LPOLESTR lpsz, REFGUID out_rguid )

CONSTANT: S_OK 0
CONSTANT: S_FALSE 1
CONSTANT: E_NOINTERFACE 0x80004002
CONSTANT: E_FAIL 0x80004005
CONSTANT: E_INVALIDARG 0x80070057

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

CONSTANT: CF_TEXT             1
CONSTANT: CF_BITMAP           2
CONSTANT: CF_METAFILEPICT     3
CONSTANT: CF_SYLK             4
CONSTANT: CF_DIF              5
CONSTANT: CF_TIFF             6
CONSTANT: CF_OEMTEXT          7
CONSTANT: CF_DIB              8
CONSTANT: CF_PALETTE          9
CONSTANT: CF_PENDATA          10
CONSTANT: CF_RIFF             11
CONSTANT: CF_WAVE             12
CONSTANT: CF_UNICODETEXT      13
CONSTANT: CF_ENHMETAFILE      14
CONSTANT: CF_HDROP            15
CONSTANT: CF_LOCALE           16
CONSTANT: CF_MAX              17

CONSTANT: CF_OWNERDISPLAY     0x0080
CONSTANT: CF_DSPTEXT          0x0081
CONSTANT: CF_DSPBITMAP        0x0082
CONSTANT: CF_DSPMETAFILEPICT  0x0083
CONSTANT: CF_DSPENHMETAFILE   0x008E

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
    GUID <struct> dup CoCreateGuid check-ole32-error ;

: string>guid ( string -- guid )
    "{-}" split harvest
    [ first3 [ hex> ] tri@ ]
    [ 3 tail concat 2 group [ hex> ] B{ } map-as ] bi
    GUID <struct-boa> ;

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
