USING: alien alien.syntax alien.c-types alien.strings math
kernel sequences windows windows.types debugger io accessors
math.order namespaces make math.parser windows.kernel32
combinators locals specialized-arrays.direct.uchar ;
IN: windows.ole32

LIBRARY: ole32

TYPEDEF: GUID* REFGUID
TYPEDEF: void* LPUNKNOWN
TYPEDEF: wchar_t* LPOLESTR
TYPEDEF: wchar_t* LPCOLESTR

TYPEDEF: REFGUID LPGUID
TYPEDEF: REFGUID REFIID
TYPEDEF: REFGUID REFCLSID

FUNCTION: HRESULT CoCreateInstance ( REFGUID rclsid, LPUNKNOWN pUnkOuter, DWORD dwClsContext, REFGUID riid, LPUNKNOWN out_ppv ) ;
FUNCTION: BOOL IsEqualGUID ( REFGUID rguid1, REFGUID rguid2 ) ;
FUNCTION: int StringFromGUID2 ( REFGUID rguid, LPOLESTR lpsz, int cchMax ) ;
FUNCTION: HRESULT CLSIDFromString ( LPOLESTR lpsz, REFGUID out_rguid ) ;

: S_OK 0 ; inline
: S_FALSE 1 ; inline
: E_NOINTERFACE HEX: 80004002 ; inline
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

: CF_TEXT             1 ; inline
: CF_BITMAP           2 ; inline
: CF_METAFILEPICT     3 ; inline
: CF_SYLK             4 ; inline
: CF_DIF              5 ; inline
: CF_TIFF             6 ; inline
: CF_OEMTEXT          7 ; inline
: CF_DIB              8 ; inline
: CF_PALETTE          9 ; inline
: CF_PENDATA          10 ; inline
: CF_RIFF             11 ; inline
: CF_WAVE             12 ; inline
: CF_UNICODETEXT      13 ; inline
: CF_ENHMETAFILE      14 ; inline
: CF_HDROP            15 ; inline
: CF_LOCALE           16 ; inline
: CF_MAX              17 ; inline

: CF_OWNERDISPLAY     HEX: 0080 ; inline
: CF_DSPTEXT          HEX: 0081 ; inline
: CF_DSPBITMAP        HEX: 0082 ; inline
: CF_DSPMETAFILEPICT  HEX: 0083 ; inline
: CF_DSPENHMETAFILE   HEX: 008E ; inline

: DVASPECT_CONTENT    1 ; inline
: DVASPECT_THUMBNAIL  2 ; inline
: DVASPECT_ICON       4 ; inline
: DVASPECT_DOCPRINT   8 ; inline

: TYMED_HGLOBAL  1 ; inline
: TYMED_FILE     2 ; inline
: TYMED_ISTREAM  4 ; inline
: TYMED_ISTORAGE 8 ; inline
: TYMED_GDI      16 ; inline
: TYMED_MFPICT   32 ; inline
: TYMED_ENHMF    64 ; inline
: TYMED_NULL     0 ; inline

C-STRUCT: DVTARGETDEVICE
    { "DWORD" "tdSize" }
    { "WORD" "tdDriverNameOffset" }
    { "WORD" "tdDeviceNameOffset" }
    { "WORD" "tdPortNameOffset" }
    { "WORD" "tdExtDevmodeOffset" }
    { "BYTE[1]" "tdData" } ;

TYPEDEF: WORD CLIPFORMAT
TYPEDEF: POINT POINTL

C-STRUCT: FORMATETC
    { "CLIPFORMAT" "cfFormat" }
    { "DVTARGETDEVICE*" "ptd" }
    { "DWORD" "dwAspect" }
    { "LONG" "lindex" }
    { "DWORD" "tymed" } ;
TYPEDEF: FORMATETC* LPFORMATETC

C-STRUCT: STGMEDIUM
    { "DWORD" "tymed" }
    { "void*" "data" }
    { "LPUNKNOWN" "punkForRelease" } ;
TYPEDEF: STGMEDIUM* LPSTGMEDIUM

: COINIT_MULTITHREADED     0 ; inline
: COINIT_APARTMENTTHREADED 2 ; inline
: COINIT_DISABLE_OLE1DDE   4 ; inline
: COINIT_SPEED_OVER_MEMORY 8 ; inline

FUNCTION: HRESULT OleInitialize ( void* reserved ) ;
FUNCTION: HRESULT CoInitializeEx ( void* reserved, DWORD dwCoInit ) ;

FUNCTION: HRESULT RegisterDragDrop ( HWND hWnd, IDropTarget* pDropTarget ) ;
FUNCTION: HRESULT RevokeDragDrop ( HWND hWnd ) ;
FUNCTION: void ReleaseStgMedium ( LPSTGMEDIUM pmedium ) ;

: succeeded? ( hresult -- ? )
    0 HEX: 7FFFFFFF between? ;

TUPLE: ole32-error error-code ;
C: <ole32-error> ole32-error

M: ole32-error error.
    "COM method failed: " print error-code>> (win32-error-string) print ;

: ole32-error ( hresult -- )
    dup succeeded? [ drop ] [ <ole32-error> throw ] if ;

: ole-initialize ( -- )
    f OleInitialize ole32-error ;

: guid= ( a b -- ? )
    [ 16 memory>byte-array ] bi@ = ;

: GUID-STRING-LENGTH ( -- n )
    "{01234567-89ab-cdef-0123-456789abcdef}" length ; inline

:: (guid-section>guid) ( string guid start end quot -- )
    start end string subseq hex> guid quot call ; inline

:: (guid-byte>guid) ( string guid start end byte -- )
    start end string subseq hex> byte guid set-nth ; inline

: string>guid ( string -- guid )
    "GUID" <c-object> [
        {
            [  1  9 [ set-GUID-Data1 ] (guid-section>guid) ]
            [ 10 14 [ set-GUID-Data2 ] (guid-section>guid) ]
            [ 15 19 [ set-GUID-Data3 ] (guid-section>guid) ]
            [ ]
        } 2cleave

        GUID-Data4 8 <direct-uchar-array> {
            [ 20 22 0 (guid-byte>guid) ]
            [ 22 24 1 (guid-byte>guid) ]

            [ 25 27 2 (guid-byte>guid) ]
            [ 27 29 3 (guid-byte>guid) ]
            [ 29 31 4 (guid-byte>guid) ]
            [ 31 33 5 (guid-byte>guid) ]
            [ 33 35 6 (guid-byte>guid) ]
            [ 35 37 7 (guid-byte>guid) ]
        } 2cleave
    ] keep ;

: (guid-section%) ( guid quot len -- )
    [ call >hex ] dip CHAR: 0 pad-head % ; inline

: (guid-byte%) ( guid byte -- )
    swap nth >hex 2 CHAR: 0 pad-head % ; inline

: guid>string ( guid -- string )
    [
        "{" % {
            [ [ GUID-Data1 ] 8 (guid-section%) "-" % ]
            [ [ GUID-Data2 ] 4 (guid-section%) "-" % ]
            [ [ GUID-Data3 ] 4 (guid-section%) "-" % ]
            [ ]
        } cleave
        GUID-Data4 8 <direct-uchar-array> {
            [ 0 (guid-byte%) ]
            [ 1 (guid-byte%) "-" % ]
            [ 2 (guid-byte%) ]
            [ 3 (guid-byte%) ]
            [ 4 (guid-byte%) ]
            [ 5 (guid-byte%) ]
            [ 6 (guid-byte%) ]
            [ 7 (guid-byte%) "}" % ]
        } cleave
    ] "" make ;

