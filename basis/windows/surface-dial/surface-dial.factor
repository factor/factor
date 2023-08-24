! Copyright (C) 2018 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.syntax
classes.struct kernel multiline namespaces ui windows.com
windows.com.syntax windows.com.wrapper windows.ole32
windows.types ;
IN: windows.surface-dial

STRUCT: HSTRING__
    { unused int } ;
TYPEDEF: HSTRING__* HSTRING

ENUM: TrustLevel
    { BaseTrust 0 }
    { PartialTrust 1 }
    { FullTrust 2 } ;

COM-INTERFACE: IInspectable IUnknown {AF86E2E0-B12D-4c6a-9C5A-D7AA65101E90}
    HRESULT GetIids ( ULONG* iidCount, IID** iids )
    HRESULT GetRuntimeClassName ( HSTRING* className )
    HRESULT GetTrustLevel ( TrustLevel* trustLevel )
;

! IInspectable
COM-INTERFACE: IRadialControllerConfigurationInterop IInspectable {787cdaac-3186-476d-87e4-b9374a7b9970}
    HRESULT GetForWindow ( HWND hwnd, REFIID riid, void** ppv )
;

COM-INTERFACE: IRadialControllerInterop IInspectable {1B0535C9-57AD-45C1-9D79-AD5C34360513}
    HRESULT CreateForWindow ( HWND hwnd, REFIID riid, void** ppv )
;

<<
SYMBOL: +radial-controller-configuration-wrapper+
SYMBOL: +radial-controller-wrapper+
>>

<<
{
    {
        IRadialControllerConfigurationInterop
        {
            ! HRESULT GetIids ( this, ULONG* iidCount, IID** iids )
            [ 3drop S_OK ]

            ! HRESULT GetRuntimeClassName ( this, HSTRING* className )
            [ 2drop S_OK ]

            ! HRESULT GetTrustLevel ( this, TrustLevel* trustLevel )
            [ 2drop S_OK ]

            ! HRESULT GetForWindow ( this, HWND hwnd, REFIID riid, void** ppv )
            [
                4drop S_OK
            ]
        }
    }
} <com-wrapper> +radial-controller-configuration-wrapper+ set-global
>>

<<
{
    {
        IRadialControllerInterop
        {
            ! HRESULT GetIids ( this, ULONG* iidCount, IID** iids )
            [ 3drop S_OK ]

            ! HRESULT GetRuntimeClassName ( this, HSTRING* className )
            [ 2drop S_OK ]

            ! HRESULT GetTrustLevel ( this, TrustLevel* trustLevel )
            [ 2drop S_OK ]

            ! HRESULT CreateForWindow ( this, HWND hwnd, REFIID riid, void** ppv )
            [
                4drop S_OK
            ]
        }
    }
} <com-wrapper> +radial-controller-wrapper+ set-global
>>

! Does nothing yet
TUPLE: surface-dial ;
C: <surface-dial> surface-dial

: make-radial-controller-configuration ( -- obj )
    <surface-dial> +radial-controller-configuration-wrapper+ get com-wrap
    IRadialControllerConfigurationInterop-iid com-query-interface [
        topmost-window handle>> hWnd>>
        IRadialControllerConfigurationInterop-iid
        { void* } [
            IRadialControllerConfigurationInterop::GetForWindow check-ole32-error
        ] with-out-parameters
    ] with-com-interface ;

: make-radial-controller ( -- obj )
    <surface-dial> +radial-controller-wrapper+ get com-wrap
    IRadialControllerInterop-iid com-query-interface [
        topmost-window handle>> hWnd>>
        IRadialControllerInterop-iid
        { void* } [
            IRadialControllerInterop::CreateForWindow check-ole32-error
        ] with-out-parameters
    ] with-com-interface ;
