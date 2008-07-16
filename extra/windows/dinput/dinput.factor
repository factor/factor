USING: windows.kernel32 windows.ole32 windows.com windows.com.syntax
alien alien.c-types alien.syntax kernel system namespaces math ;
IN: windows.dinput

<< os windows?
    [ "dinput" "dinput8.dll" "stdcall" add-library ]
    [ "DirectInput only supported on Windows" throw ] if
>>

LIBRARY: dinput

TYPEDEF: void* LPDIENUMDEVICESCALLBACKW
: LPDIENUMDEVICESCALLBACKW ( quot -- alien )
    [ "BOOL" { "LPCDIDEVICEINSTANCEW" "LPVOID" } "stdcall" ]
    dip alien-callback ; inline
TYPEDEF: void* LPDIENUMDEVICESBYSEMANTICSCBW
: LPDIENUMDEVICESBYSEMANTICSCBW ( quot -- alien )
    [ "BOOL" { "LPCDIDEVICEINSTANCEW" "IDirectInputDevice8W*" "DWORD" "DWORD" "LPVOID" } "stdcall" ]
    dip alien-callback ; inline
TYPEDEF: void* LPDICONFIGUREDEVICESCALLBACK
: LPDICONFIGUREDEVICESCALLBACK ( quot -- alien )
    [ "BOOL" { "IUnknown*" "LPVOID" } "stdcall" ]
    dip alien-callback ; inline
TYPEDEF: void* LPDIENUMEFFECTSCALLBACKW
: LPDIENUMEFFECTSCALLBACKW ( quot -- alien )
    [ "BOOL" { "LPCDIEFFECTINFOW" "LPVOID" } "stdcall" ]
    dip alien-callback ; inline
TYPEDEF: void* LPDIENUMCREATEDEFFECTOBJECTSCALLBACK
: LPDIENUMCREATEDEFFECTOBJECTSCALLBACK
    [ "BOOL" { "LPDIRECTINPUTEFFECT" "LPVOID" } "stdcall" ]
    dip alien-callback ; inline
TYPEDEF: void* LPDIENUMEFFECTSINFILECALLBACK
    [ "BOOL" { "LPCDIFILEEFFECT" "LPVOID" } "stdcall" ]
    dip alien-callback ; inline
TYPEDEF: void* LPDIENUMDEVICEOBJECTSCALLBACKW
    [ "BOOL" { "LPCDIDEVICEOBJECTINSTANCE" "LPVOID" } "stdcall" ]
    dip alien-callback ; inline

TYPEDEF: DWORD D3DCOLOR

C-STRUCT: DIDEVICEINSTANCEW
    { "DWORD"      "dwSize" }
    { "GUID"       "guidInstance" }
    { "GUID"       "guidProduct" }
    { "DWORD"      "dwDevType" }
    { "WCHAR[260]" "tszInstanceName" }
    { "WCHAR[260]" "tszProductName" }
    { "GUID"       "guidFFDriver" }
    { "WORD"       "wUsagePage" }
    { "WORD"       "wUsage" } ;
TYPEDEF: DIDEVICEINSTANCEW* LPDIDEVICEINSTANCEW
TYPEDEF: DIDEVICEINSTANCEW* LPCDIDEVICEINSTANCEW
C-UNION: DIACTION-union "LPCWSTR" "UINT" ;
C-STRUCT: DIACTIONW
    { "UINT_PTR"       "uAppData" }
    { "DWORD"          "dwSemantic" }
    { "DWORD"          "dwFlags" }
    { "DIACTION-union" "lptszActionName-or-uResIdString" }
    { "GUID"           "guidInstance" }
    { "DWORD"          "dwObjID" }
    { "DWORD"          "dwHow" } ;
TYPEDEF: DIACTIONW* LPDIACTIONW
TYPEDEF: DIACTIONW* LPCDIACTIONW
C-STRUCT: DIACTIONFORMATW
    { "DWORD"       "dwSize" }
    { "DWORD"       "dwActionSize" }
    { "DWORD"       "dwDataSize" }
    { "DWORD"       "dwNumActions" }
    { "LPDIACTIONW" "rgoAction" }
    { "GUID"        "guidActionMap" }
    { "DWORD"       "dwGenre" }
    { "DWORD"       "dwBufferSize" }
    { "LONG"        "lAxisMin" }
    { "LONG"        "lAxisMax" }
    { "HINSTANCE"   "hInstString" }
    { "FILETIME"    "ftTimeStamp" }
    { "DWORD"       "dwCRC" }
    { "WCHAR[260]"  "tszActionMap" } ;
TYPEDEF: DIACTIONFORMATW* LPDIACTIONFORMATW
TYPEDEF: DIACTIONFORMATW* LPCDIACTIONFORMATW
C-STRUCT: DICOLORSET
    { "DWORD"    "dwSize" }
    { "D3DCOLOR" "cTextFore" }
    { "D3DCOLOR" "cTextHighlight" }
    { "D3DCOLOR" "cCalloutLine" }
    { "D3DCOLOR" "cCalloutHighlight" }
    { "D3DCOLOR" "cBorder" }
    { "D3DCOLOR" "cControlFill" }
    { "D3DCOLOR" "cHighlightFill" }
    { "D3DCOLOR" "cAreaFill" } ;
TYPEDEF: DICOLORSET* LPDICOLORSET
TYPEDEF: DICOLORSET* LPCDICOLORSET

C-STRUCT: DICONFIGUREDEVICESPARAMSW
    { "DWORD"             "dwSize" }
    { "DWORD"             "dwcUsers" }
    { "LPWSTR"            "lptszUserNames" }
    { "DWORD"             "dwcFormats" }
    { "LPDIACTIONFORMATW" "lprgFormats" }
    { "HWND"              "hwnd" }
    { "DICOLORSET"        "dics" }
    { "IUnknown*"         "lpUnkDDSTarget" } ;
TYPEDEF: DICONFIGUREDEVICESPARAMSW* LPDICONFIGUREDEVICESPARAMSW
TYPEDEF: DICONFIGUREDEVICESPARAMSW* LPDICONFIGUREDEVICESPARAMSW

C-STRUCT: DIDEVCAPS
    { "DWORD" "wSize" }
    { "DWORD" "wFlags" }
    { "DWORD" "wDevType" }
    { "DWORD" "wAxes" }
    { "DWORD" "wButtons" }
    { "DWORD" "wPOVs" }
    { "DWORD" "wFFSamplePeriod" }
    { "DWORD" "wFFMinTimeResolution" }
    { "DWORD" "wFirmwareRevision" }
    { "DWORD" "wHardwareRevision" }
    { "DWORD" "wFFDriverVersion" } ;
TYPEDEF: DIDEVCAPS* LPDIDEVCAPS
TYPEDEF: DIDEVCAPS* LPCDIDEVCAPS
C-STRUCT: DIDEVICEOBJECTINSTANCEW
    { "DWORD"      "dwSize" }
    { "GUID"       "guidInstance" }
    { "GUID"       "guidProduct" }
    { "DWORD"      "dwDevType" }
    { "WCHAR[260]" "tszInstanceName" }
    { "WCHAR[260]" "tszProductName" }
    { "GUID"       "guidFFDriver" }
    { "WORD"       "wUsagePage" }
    { "WORD"       "wUsage" } ;
TYPEDEF: DIDEVICEOBJECTINSTANCEW* LPDIDEVICEOBJECTINSTANCEW
TYPEDEF: DIDEVICEOBJECTINSTANCEW* LPCDIDEVICEOBJECTINSTANCEW
C-STRUCT: DIDEVICEOBJECTDATA
    { "DWORD"    "dwOfs" }
    { "DWORD"    "dwData" }
    { "DWORD"    "dwTimeStamp" }
    { "DWORD"    "dwSequence" }
    { "UINT_PTR" "uAppData" } ;
TYPEDEF: DIDEVICEOBJECTDATA* LPDIDEVICEOBJECTDATA
TYPEDEF: DIDEVICEOBJECTDATA* LPCDIDEVICEOBJECTDATA
C-STRUCT: DIOBJECTDATAFORMAT
    { "GUID*" "pguid" }
    { "DWORD" "dwOfs" }
    { "DWORD" "dwType" }
    { "DWORD" "dwFlags" } ;
TYPEDEF: DIOBJECTDATAFORMAT* LPDIOBJECTDATAFORMAT
TYPEDEF: DIOBJECTDATAFORMAT* LPCDIOBJECTDATAFORMAT
C-STRUCT: DIDATAFORMAT
    { "DWORD" "dwSize" }
    { "DWORD" "dwObjSize" }
    { "DWORD" "dwFlags" }
    { "DWORD" "dwDataSize" }
    { "DWORD" "dwNumObjs" }
    { "LPDIOBJECTDATAFORMAT" "rgodf" } ;
TYPEDEF: DIDATAFORMAT* LPDIDATAFORMAT
TYPEDEF: DIDATAFORMAT* LPCDIDATAFORMAT
C-STRUCT: DIPROPHEADER
    { "DWORD" "dwSize" }
    { "DWORD" "dwHeaderSize" }
    { "DWORD" "dwObj" }
    { "DWORD" "dwHow" } ;
TYPEDEF: DIPROPHEADER* LPDIPROPHEADER
TYPEDEF: DIPROPHEADER* LPCDIPROPHEADER
C-STRUCT: DIENVELOPE
    { "DWORD" "dwSize" }
    { "DWORD" "dwAttackLevel" }
    { "DWORD" "dwAttackTime" }
    { "DWORD" "dwFadeLevel" }
    { "DWORD" "dwFadeTime" } ;
TYPEDEF: DIENVELOPE* LPDIENVELOPE
TYPEDEF: DIENVELOPE* LPCDIENVELOPE
C-STRUCT: DIEFFECT
    { "DWORD" "dwSize" }
    { "DWORD" "dwFlags" }
    { "DWORD" "dwDuration" }
    { "DWORD" "dwSamplePeriod" }
    { "DWORD" "dwGain" }
    { "DWORD" "dwTriggerButton" }
    { "DWORD" "dwTriggerRepeatInterval" }
    { "DWORD" "cAxes" }
    { "LPDWORD" "rgdwAxes" }
    { "LPLONG" "rglDirection" }
    { "LPDIENVELOPE" "lpEnvelope" }
    { "DWORD" "cbTypeSpecificParams" }
    { "LPVOID" "lpvTypeSpecificParams" }
    { "DWORD" "dwStartDelay" } ;
TYPEDEF: DIEFFECT* LPDIEFFECT
TYPEDEF: DIEFFECT* LPCDIEFFECT
C-STRUCT: DIEFFECTINFOW
    { "DWORD"      "dwSize" }
    { "GUID"       "guid" }
    { "DWORD"      "dwEffType" }
    { "DWORD"      "dwStaticParams" }
    { "DWORD"      "dwDynamicParams" }
    { "WCHAR[260]" "tszName" } ;
TYPEDEF: DIEFFECTINFOW* LPDIEFFECTINFOW
TYPEDEF: DIEFFECTINFOW* LPCDIEFFECTINFOW
C-STRUCT: DIEFFESCAPE
    { "DWORD"  "dwSize" }
    { "DWORD"  "dwCommand" }
    { "LPVOID" "lpvInBuffer" }
    { "DWORD"  "cbInBuffer" }
    { "LPVOID" "lpvOutBuffer" }
    { "DWORD"  "cbOutBuffer" } ;
TYPEDEF: DIEFFESCAPE* LPDIEFFESCAPE
TYPEDEF: DIEFFESCAPE* LPCDIEFFESCAPE
C-STRUCT: DIFILEEFFECT
    { "DWORD"       "dwSize" }
    { "GUID"        "GuidEffect" }
    { "LPCDIEFFECT" "lpDiEffect" }
    { "CHAR[260]"   "szFriendlyName" } ;
TYPEDEF: DIFILEEFFECT* LPDIFILEEFFECT
TYPEDEF: DIFILEEFFECT* LPCDIFILEEFFECT
C-STRUCT: DIDEVICEIMAGEINFOW
    { "WCHAR[260]" "tszImagePath" }
    { "DWORD"      "dwFlags" }
    { "DWORD"      "dwViewID" }
    { "RECT"       "rcOverlay" }
    { "DWORD"      "dwObjID" }
    { "DWORD"      "dwcValidPts" }
    { "POINT[5]"   "rgptCalloutLine" }
    { "RECT"       "rcCalloutRect" }
    { "DWORD"      "dwTextAlign" } ;
TYPEDEF: DIDEVICEIMAGEINFOW* LPDIDEVICEIMAGEINFOW
TYPEDEF: DIDEVICEIMAGEINFOW* LPCDIDEVICEIMAGEINFOW
C-STRUCT: DIDEVICEIMAGEINFOHEADERW
    { "DWORD" "dwSize" }
    { "DWORD" "dwSizeImageInfo" }
    { "DWORD" "dwcViews" }
    { "DWORD" "dwcButtons" }
    { "DWORD" "dwcAxes" }
    { "DWORD" "dwcPOVs" }
    { "DWORD" "dwBufferSize" }
    { "DWORD" "dwBufferUsed" }
    { "DIDEVICEIMAGEINFOW*" "lprgImageInfoArray" } ;
TYPEDEF: DIDEVICEIMAGEINFOHEADERW* LPDIDEVICEIMAGEINFOHEADERW
TYPEDEF: DIDEVICEIMAGEINFOHEADERW* LPCDIDEVICEIMAGEINFOHEADERW

C-STRUCT: DIMOUSESTATE2
    { "LONG"    "lX" }
    { "LONG"    "lY" }
    { "LONG"    "lZ" }
    { "BYTE[8]" "rgbButtons" } ;
TYPEDEF: DIMOUSESTATE2* LPDIMOUSESTATE2
TYPEDEF: DIMOUSESTATE2* LPCDIMOUSESTATE2

C-STRUCT: DIJOYSTATE2
    { "LONG"      "lX" }
    { "LONG"      "lY" }
    { "LONG"      "lZ" }
    { "LONG"      "lRx" }
    { "LONG"      "lRy" }
    { "LONG"      "lRz" }
    { "LONG[2]"   "rglSlider" }
    { "DWORD[4]"  "rgdwPOV" }
    { "BYTE[128]" "rgbButtons" }
    { "LONG"      "lVX" }
    { "LONG"      "lVY" }
    { "LONG"      "lVZ" }
    { "LONG"      "lVRx" }
    { "LONG"      "lVRy" }
    { "LONG"      "lVRz" }
    { "LONG[2]"   "rglVSlider" }
    { "LONG"      "lAX" }
    { "LONG"      "lAY" }
    { "LONG"      "lAZ" }
    { "LONG"      "lARx" }
    { "LONG"      "lARy" }
    { "LONG"      "lARz" }
    { "LONG[2]"   "rglASlider" }
    { "LONG"      "lFX" }
    { "LONG"      "lFY" }
    { "LONG"      "lFZ" }
    { "LONG"      "lFRx" }
    { "LONG"      "lFRy" }
    { "LONG"      "lFRz" }
    { "LONG[2]"   "rglFSlider" } ;
TYPEDEF: DIJOYSTATE2* LPDIJOYSTATE2
TYPEDEF: DIJOYSTATE2* LPCDIJOYSTATE2

COM-INTERFACE: IDirectInputEffect IUnknown {E7E1F7C0-88D2-11D0-9AD0-00A0C9A06E35}
    HRESULT Initialize ( HINSTANCE hinst, DWORD dwVersion, REFGUID rguid )
    HRESULT GetEffectGuid ( LPGUID pguid )
    HRESULT GetParameters ( LPDIEFFECT peff, DWORD dwFlags )
    HRESULT SetParameters ( LPCDIEFFECT peff, DWORD dwFlags )
    HRESULT Start ( DWORD dwIterations, DWORD dwFlags )
    HRESULT Stop ( )
    HRESULT GetEffectStatus ( LPDWORD pdwFlags )
    HRESULT Download ( )
    HRESULT Unload ( )
    HRESULT Escape ( LPDIEFFESCAPE pesc ) ;

COM-INTERFACE: IDirectInputDevice8W IUnknown {54D41081-DC15-4833-A41B-748F73A38179}
    HRESULT GetCapabilities ( LPDIDEVCAPS lpDIDeviceCaps )
    HRESULT EnumObjects ( LPDIENUMDEVICEOBJECTSCALLBACKW lpCallback, LPVOID pvRef, DWORD dwFlags )
    HRESULT GetProperty ( REFGUID rguidProp, LPDIPROPHEADER pdiph )
    HRESULT SetProperty ( REFGUID rguidProp, LPCDIPROPHEADER pdiph )
    HRESULT Acquire ( )
    HRESULT Unacquire ( )
    HRESULT GetDeviceState ( DWORD cbData, LPVOID lpvData )
    HRESULT GetDeviceData ( DWORD cbObjectData, LPDIDEVICEOBJECTDATA rgdod, LPDWORD pdwInOut, DWORD dwFlags )
    HRESULT SetDataFormat ( LPCDIDATAFORMAT lpdf )
    HRESULT SetEventNotification ( HANDLE hEvent )
    HRESULT SetCooperativeLevel ( HWND hwnd, DWORD dwFlags )
    HRESULT GetObjectInfo ( LPDIDEVICEOBJECTINSTANCEW rdidoi, DWORD dwObj, DWORD dwHow )
    HRESULT GetDeviceInfo ( LPDIDEVICEINSTANCEW pdidi )
    HRESULT RunControlPanel ( HWND hwndOwner, DWORD dwFlags )
    HRESULT Initialize ( HINSTANCE hinst, DWORD dwVersion, REFGUID rguid )
    HRESULT CreateEffect ( REFGUID rguid, LPCDIEFFECT lpeff, IDirectInputEffect** ppdeff, LPUNKNOWN punkOuter )
    HRESULT EnumEffects ( LPDIENUMEFFECTSCALLBACKW lpCallback, LPVOID pvRef, DWORD dwEffType )
    HRESULT GetEffectInfo ( LPDIEFFECTINFOW pdei, REFGUID rguid )
    HRESULT GetForceFeedbackState ( LPDWORD pdwOut )
    HRESULT SendForceFeedbackCommand ( DWORD dwFlags )
    HRESULT EnumCreatedEffectObjects ( LPDIENUMCREATEDEFFECTOBJECTSCALLBACK lpCallback, LPVOID pvRef, DWORD fl )
    HRESULT Escape ( LPDIEFFESCAPE pesc )
    HRESULT Poll ( )
    HRESULT SendDeviceData ( DWORD cbObjectData, LPCDIDEVICEOBJECTDATA rgdod, LPDWORD pdwInOut, DWORD fl )
    HRESULT EnumEffectsInFile ( LPCWSTR lpszFileName, LPDIENUMEFFECTSINFILECALLBACK lpCallback, LPVOID pvRef, DWORD dwFlags )
    HRESULT WriteEffectToFile ( LPCWSTR lpszFileName, DWORD dwEntries, LPDIFILEEFFECT rgDiFileEffect, DWORD dwFlags )
    HRESULT BuildActionMap ( LPDIACTIONFORMATW lpdiaf, LPCWSTR lpszUserName, DWORD dwFlags )
    HRESULT SetActionMap ( LPDIACTIONFORMATW lpdiActionFormat, LPCWSTR lpwszUserName, DWORD dwFlags )
    HRESULT GetImageInfo ( LPDIDEVICEIMAGEINFOHEADERW lpdiDeviceImageInfoHeader ) ;

COM-INTERFACE: IDirectInput8W IUnknown {BF798031-483A-4DA2-AA99-5D64ED369700}
    HRESULT CreateDevice ( REFGUID rguid, IDirectInputDevice8W** lplpDevice, LPUNKNOWN pUnkOuter )
    HRESULT EnumDevices ( DWORD dwDevType, LPDIENUMDEVICESCALLBACKW lpCallback, LPVOID pvRef, DWORD dwFlags )
    HRESULT GetDeviceStatus ( REFGUID rguidInstance )
    HRESULT RunControlPanel ( HWND hwndOwner, DWORD dwFlags )
    HRESULT Initialize ( HINSTANCE hinst, DWORD dwVersion )
    HRESULT FindDevice ( REFGUID rguidClass, LPCWSTR pwszName, LPGUID pguidInstance )
    HRESULT EnumDevicesBySemantics ( LPCWSTR pwszUserName, LPDIACTIONFORMATW lpdiActionFormat, LPDIENUMDEVICESBYSEMANTICSCBW lpCallback, LPVOID pvRef, DWORD dwFlags )
    HRESULT ConfigureDevices ( LPDICONFIGUREDEVICESCALLBACK lpdiCallback, LPDICONFIGUREDEVICESPARAMSW lpdiCDParams, DWORD dwFlags, LPVOID pvRefData ) ;

FUNCTION: HRESULT DirectInput8Create ( HINSTANCE hinst, DWORD dwVersion, REFIID riidtlf, LPVOID* ppvOut, LPUNKNOWN punkOuter ) ;

: DIRECTINPUT_VERSION HEX: 0800 ; inline

: DI8DEVCLASS_ALL             0 ; inline
: DI8DEVCLASS_DEVICE          1 ; inline
: DI8DEVCLASS_POINTER         2 ; inline
: DI8DEVCLASS_KEYBOARD        3 ; inline
: DI8DEVCLASS_GAMECTRL        4 ; inline

: DIEDFL_ALLDEVICES       HEX: 00000000 ; inline
: DIEDFL_ATTACHEDONLY     HEX: 00000001 ; inline
: DIEDFL_FORCEFEEDBACK    HEX: 00000100 ; inline
: DIEDFL_INCLUDEALIASES   HEX: 00010000 ; inline
: DIEDFL_INCLUDEPHANTOMS  HEX: 00020000 ; inline
: DIEDFL_INCLUDEHIDDEN    HEX: 00040000 ; inline

: DIENUM_STOP             0 ; inline
: DIENUM_CONTINUE         1 ; inline

: DIDF_ABSAXIS            1 ;
: DIDF_RELAXIS            2 ;

: DIDFT_ALL           HEX: 00000000 ; inline

: DIDFT_RELAXIS       HEX: 00000001 ; inline
: DIDFT_ABSAXIS       HEX: 00000002 ; inline
: DIDFT_AXIS          HEX: 00000003 ; inline

: DIDFT_PSHBUTTON     HEX: 00000004 ; inline
: DIDFT_TGLBUTTON     HEX: 00000008 ; inline
: DIDFT_BUTTON        HEX: 0000000C ; inline

: DIDFT_POV           HEX: 00000010 ; inline
: DIDFT_COLLECTION    HEX: 00000040 ; inline
: DIDFT_NODATA        HEX: 00000080 ; inline

: DIDFT_ANYINSTANCE   HEX: 00FFFF00 ; inline
: DIDFT_INSTANCEMASK  DIDFT_ANYINSTANCE ; inline
: DIDFT_MAKEINSTANCE ( n -- instance ) 8 shift                   ; inline
: DIDFT_GETTYPE      ( n -- type     ) HEX: FF bitand            ; inline
: DIDFT_GETINSTANCE  ( n -- instance ) -8 shift HEX: FFFF bitand ; inline
: DIDFT_FFACTUATOR        HEX: 01000000 ; inline
: DIDFT_FFEFFECTTRIGGER   HEX: 02000000 ; inline
: DIDFT_OUTPUT            HEX: 10000000 ; inline
: DIDFT_VENDORDEFINED     HEX: 04000000 ; inline
: DIDFT_ALIAS             HEX: 08000000 ; inline
: DIDFT_OPTIONAL          HEX: 80000000 ; inline

: DIDFT_ENUMCOLLECTION ( n -- instance ) 8 shift HEX: FFFF bitand ; inline
: DIDFT_NOCOLLECTION      HEX: 00FFFF00 ; inline

: DISCL_EXCLUSIVE     HEX: 00000001 ; inline
: DISCL_NONEXCLUSIVE  HEX: 00000002 ; inline
: DISCL_FOREGROUND    HEX: 00000004 ; inline
: DISCL_BACKGROUND    HEX: 00000008 ; inline
: DISCL_NOWINKEY      HEX: 00000010 ; inline

SYMBOL: +dinput+

: create-dinput ( -- )
    f GetModuleHandle DIRECTINPUT_VERSION IDirectInput8W-iid
    f <void*> [ f DirectInput8Create ole32-error ] keep *void*
    +dinput+ set ;

: delete-dinput ( -- )
    +dinput+ [ com-release f ] change ;

