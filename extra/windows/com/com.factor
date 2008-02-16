USING: alien alien.c-types windows.com.syntax windows.ole32
windows.types ;
IN: windows.com

COM-INTERFACE: IUnknown f
    HRESULT QueryInterface ( void* this, REFGUID iid, void** ppvObject )
    ULONG AddRef ( void* this )
    ULONG Release ( void* this ) ;
