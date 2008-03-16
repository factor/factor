USING: alien alien.c-types windows.com.syntax windows.ole32
windows.types continuations ;
IN: windows.com

COM-INTERFACE: IUnknown f {00000000-0000-0000-C000-000000000046}
    HRESULT QueryInterface ( REFGUID iid, void** ppvObject )
    ULONG AddRef ( )
    ULONG Release ( ) ;

: com-query-interface ( interface iid -- interface' )
    f <void*> [ IUnknown::QueryInterface ] keep *void* ;

: com-add-ref ( interface -- )
    IUnknown::AddRef drop ; inline

: com-release ( interface -- )
    IUnknown::Release drop ; inline
