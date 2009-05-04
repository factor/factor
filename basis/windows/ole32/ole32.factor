USING: alien alien.syntax alien.c-types alien.strings math
kernel sequences windows.errors windows.types debugger io
accessors math.order namespaces make math.parser windows.kernel32
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

CONSTANT: S_OK 0
CONSTANT: S_FALSE 1
CONSTANT: E_NOINTERFACE HEX: 80004002
CONSTANT: E_FAIL HEX: 80004005
CONSTANT: E_INVALIDARG HEX: 80070057

CONSTANT: MK_ALT HEX: 20
CONSTANT: DROPEFFECT_NONE 0
CONSTANT: DROPEFFECT_COPY 1
CONSTANT: DROPEFFECT_MOVE 2
CONSTANT: DROPEFFECT_LINK 4
CONSTANT: DROPEFFECT_SCROLL HEX: 80000000
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

CONSTANT: CF_OWNERDISPLAY     HEX: 0080
CONSTANT: CF_DSPTEXT          HEX: 0081
CONSTANT: CF_DSPBITMAP        HEX: 0082
CONSTANT: CF_DSPMETAFILEPICT  HEX: 0083
CONSTANT: CF_DSPENHMETAFILE   HEX: 008E

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

CONSTANT: COINIT_MULTITHREADED     0
CONSTANT: COINIT_APARTMENTTHREADED 2
CONSTANT: COINIT_DISABLE_OLE1DDE   4
CONSTANT: COINIT_SPEED_OVER_MEMORY 8

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
    "COM method failed: " print error-code>> n>win32-error-string print ;

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

