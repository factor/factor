USING: alien alien.c-types alien.destructors windows.com.syntax
windows.ole32 windows.types continuations kernel alien.syntax
libc destructors accessors alien.data classes.struct windows.kernel32 ;
IN: windows.com

LIBRARY: ole32

COM-INTERFACE: IUnknown f {00000000-0000-0000-C000-000000000046}
    HRESULT QueryInterface ( REFGUID iid, void** ppvObject )
    ULONG AddRef ( )
    ULONG Release ( ) ;

C-TYPE: IAdviseSink
C-TYPE: IEnumFORMATETC
C-TYPE: IEnumSTATDATA

COM-INTERFACE: IDataObject IUnknown {0000010E-0000-0000-C000-000000000046}
    HRESULT GetData ( FORMATETC* pFormatetc, STGMEDIUM* pmedium )
    HRESULT GetDataHere ( FORMATETC* pFormatetc, STGMEDIUM* pmedium )
    HRESULT QueryGetData ( FORMATETC* pFormatetc )
    HRESULT GetCanonicalFormatEtc ( FORMATETC* pFormatetcIn, FORMATETC* pFormatetcOut )
    HRESULT SetData ( FORMATETC* pFormatetc, STGMEDIUM* pmedium, BOOL fRelease )
    HRESULT EnumFormatEtc ( DWORD dwDirection, IEnumFORMATETC** ppenumFormatetc )
    HRESULT DAdvise ( FORMATETC* pFormatetc, DWORD advf, IAdviseSink* pAdvSink, DWORD* pdwConnection )
    HRESULT DUnadvise ( DWORD pdwConnection )
    HRESULT EnumDAdvise ( IEnumSTATDATA** ppenumAdvise ) ;

COM-INTERFACE: IDropTarget IUnknown {00000122-0000-0000-C000-000000000046}
    HRESULT DragEnter ( IDataObject* pDataObject, DWORD grfKeyState, POINTL pt, DWORD* pdwEffect )
    HRESULT DragOver ( DWORD grfKeyState, POINTL pt, DWORD* pdwEffect )
    HRESULT DragLeave ( )
    HRESULT Drop ( IDataObject* pDataObject, DWORD grfKeyState, POINTL pt, DWORD* pdwEffect ) ;

COM-INTERFACE: ISequentialStream IUnknown {0C733A30-2A1C-11CE-ADE5-00AA0044773D}
    HRESULT Read ( void* pv, ULONG cb, ULONG* pcbRead )
    HRESULT Write ( void* pv, ULONG cb, ULONG* pcbWritten ) ;

STRUCT: STATSTG
    { pwcsName LPOLESTR }
    { type DWORD }
    { cbSize ULARGE_INTEGER }
    { mtime FILETIME }
    { ctime FILETIME }
    { atime FILETIME }
    { grfMode DWORD }
    { grfLocksSupported DWORD }
    { clsid CLSID }
    { grfStateBits DWORD }
    { reserved DWORD } ;

CONSTANT: STGM_READ 0
CONSTANT: STGM_WRITE 1
CONSTANT: STGM_READWRITE 2

CONSTANT: STG_E_INVALIDFUNCTION 0x80030001

CONSTANT: STGTY_STORAGE   1
CONSTANT: STGTY_STREAM    2
CONSTANT: STGTY_LOCKBYTES 3
CONSTANT: STGTY_PROPERTY  4

CONSTANT: STREAM_SEEK_SET 0
CONSTANT: STREAM_SEEK_CUR 1
CONSTANT: STREAM_SEEK_END 2

CONSTANT: LOCK_WRITE     1
CONSTANT: LOCK_EXCLUSIVE 2
CONSTANT: LOCK_ONLYONCE  4

CONSTANT: GUID_NULL GUID: {00000000-0000-0000-0000-000000000000}

COM-INTERFACE: IStream ISequentialStream {0000000C-0000-0000-C000-000000000046}
    HRESULT Seek ( LARGE_INTEGER dlibMove, DWORD dwOrigin, ULARGE_INTEGER* plibNewPosition )
    HRESULT SetSize ( ULARGE_INTEGER* libNewSize )
    HRESULT CopyTo ( IStream* pstm, ULARGE_INTEGER cb, ULARGE_INTEGER* pcbRead, ULARGE_INTEGER* pcbWritten )
    HRESULT Commit ( DWORD grfCommitFlags )
    HRESULT Revert ( )
    HRESULT LockRegion ( ULARGE_INTEGER libOffset, ULARGE_INTEGER cb, DWORD dwLockType )
    HRESULT UnlockRegion ( ULARGE_INTEGER libOffset, ULARGE_INTEGER cb, DWORD dwLockType )
    HRESULT Stat ( STATSTG* pstatstg, DWORD grfStatFlag )
    HRESULT Clone ( IStream** ppstm ) ;

FUNCTION: HRESULT RegisterDragDrop ( HWND hWnd, IDropTarget* pDropTarget )
FUNCTION: HRESULT RevokeDragDrop ( HWND hWnd )
FUNCTION: void ReleaseStgMedium ( LPSTGMEDIUM pmedium )

: com-query-interface ( interface iid -- interface' )
    { void* }
    [ IUnknown::QueryInterface check-ole32-error ]
    with-out-parameters ;

: com-add-ref ( interface -- interface )
     [ IUnknown::AddRef drop ] keep ; inline

ERROR: null-com-release ;
: com-release ( interface -- )
    [ IUnknown::Release drop ] [ null-com-release ] if* ; inline

: with-com-interface ( interface quot -- )
    over [ com-release ] curry [ ] cleanup ; inline

DESTRUCTOR: com-release
