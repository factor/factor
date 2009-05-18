USING: alien alien.c-types alien.destructors windows.com.syntax
windows.ole32 windows.types continuations kernel alien.syntax
libc destructors accessors ;
IN: windows.com

LIBRARY: ole32

COM-INTERFACE: IUnknown f {00000000-0000-0000-C000-000000000046}
    HRESULT QueryInterface ( REFGUID iid, void** ppvObject )
    ULONG AddRef ( )
    ULONG Release ( ) ;

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

: com-query-interface ( interface iid -- interface' )
    [
        "void*" malloc-object &free
        [ IUnknown::QueryInterface ole32-error ] keep *void*
    ] with-destructors ;

: com-add-ref ( interface -- interface )
     [ IUnknown::AddRef drop ] keep ; inline

: com-release ( interface -- )
    IUnknown::Release drop ; inline

: with-com-interface ( interface quot -- )
    over [ com-release ] curry [ ] cleanup ; inline

DESTRUCTOR: com-release
