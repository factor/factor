USING: windows.kernel32 windows.ole32 windows.com windows.com.syntax
alien alien.c-types alien.syntax kernel system namespaces math ;
IN: windows.dinput

<<
    os windows?
    [ "dinput" "dinput8.dll" "stdcall" add-library ]
    when
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

: DIK_ESCAPE          HEX: 01 ; inline
: DIK_1               HEX: 02 ; inline
: DIK_2               HEX: 03 ; inline
: DIK_3               HEX: 04 ; inline
: DIK_4               HEX: 05 ; inline
: DIK_5               HEX: 06 ; inline
: DIK_6               HEX: 07 ; inline
: DIK_7               HEX: 08 ; inline
: DIK_8               HEX: 09 ; inline
: DIK_9               HEX: 0A ; inline
: DIK_0               HEX: 0B ; inline
: DIK_MINUS           HEX: 0C ; inline
: DIK_EQUALS          HEX: 0D ; inline
: DIK_BACK            HEX: 0E ; inline
: DIK_TAB             HEX: 0F ; inline
: DIK_Q               HEX: 10 ; inline
: DIK_W               HEX: 11 ; inline
: DIK_E               HEX: 12 ; inline
: DIK_R               HEX: 13 ; inline
: DIK_T               HEX: 14 ; inline
: DIK_Y               HEX: 15 ; inline
: DIK_U               HEX: 16 ; inline
: DIK_I               HEX: 17 ; inline
: DIK_O               HEX: 18 ; inline
: DIK_P               HEX: 19 ; inline
: DIK_LBRACKET        HEX: 1A ; inline
: DIK_RBRACKET        HEX: 1B ; inline
: DIK_RETURN          HEX: 1C ; inline
: DIK_LCONTROL        HEX: 1D ; inline
: DIK_A               HEX: 1E ; inline
: DIK_S               HEX: 1F ; inline
: DIK_D               HEX: 20 ; inline
: DIK_F               HEX: 21 ; inline
: DIK_G               HEX: 22 ; inline
: DIK_H               HEX: 23 ; inline
: DIK_J               HEX: 24 ; inline
: DIK_K               HEX: 25 ; inline
: DIK_L               HEX: 26 ; inline
: DIK_SEMICOLON       HEX: 27 ; inline
: DIK_APOSTROPHE      HEX: 28 ; inline
: DIK_GRAVE           HEX: 29 ; inline
: DIK_LSHIFT          HEX: 2A ; inline
: DIK_BACKSLASH       HEX: 2B ; inline
: DIK_Z               HEX: 2C ; inline
: DIK_X               HEX: 2D ; inline
: DIK_C               HEX: 2E ; inline
: DIK_V               HEX: 2F ; inline
: DIK_B               HEX: 30 ; inline
: DIK_N               HEX: 31 ; inline
: DIK_M               HEX: 32 ; inline
: DIK_COMMA           HEX: 33 ; inline
: DIK_PERIOD          HEX: 34 ; inline
: DIK_SLASH           HEX: 35 ; inline
: DIK_RSHIFT          HEX: 36 ; inline
: DIK_MULTIPLY        HEX: 37 ; inline
: DIK_LMENU           HEX: 38 ; inline
: DIK_SPACE           HEX: 39 ; inline
: DIK_CAPITAL         HEX: 3A ; inline
: DIK_F1              HEX: 3B ; inline
: DIK_F2              HEX: 3C ; inline
: DIK_F3              HEX: 3D ; inline
: DIK_F4              HEX: 3E ; inline
: DIK_F5              HEX: 3F ; inline
: DIK_F6              HEX: 40 ; inline
: DIK_F7              HEX: 41 ; inline
: DIK_F8              HEX: 42 ; inline
: DIK_F9              HEX: 43 ; inline
: DIK_F10             HEX: 44 ; inline
: DIK_NUMLOCK         HEX: 45 ; inline
: DIK_SCROLL          HEX: 46 ; inline
: DIK_NUMPAD7         HEX: 47 ; inline
: DIK_NUMPAD8         HEX: 48 ; inline
: DIK_NUMPAD9         HEX: 49 ; inline
: DIK_SUBTRACT        HEX: 4A ; inline
: DIK_NUMPAD4         HEX: 4B ; inline
: DIK_NUMPAD5         HEX: 4C ; inline
: DIK_NUMPAD6         HEX: 4D ; inline
: DIK_ADD             HEX: 4E ; inline
: DIK_NUMPAD1         HEX: 4F ; inline
: DIK_NUMPAD2         HEX: 50 ; inline
: DIK_NUMPAD3         HEX: 51 ; inline
: DIK_NUMPAD0         HEX: 52 ; inline
: DIK_DECIMAL         HEX: 53 ; inline
: DIK_OEM_102         HEX: 56 ; inline
: DIK_F11             HEX: 57 ; inline
: DIK_F12             HEX: 58 ; inline
: DIK_F13             HEX: 64 ; inline
: DIK_F14             HEX: 65 ; inline
: DIK_F15             HEX: 66 ; inline
: DIK_KANA            HEX: 70 ; inline
: DIK_ABNT_C1         HEX: 73 ; inline
: DIK_CONVERT         HEX: 79 ; inline
: DIK_NOCONVERT       HEX: 7B ; inline
: DIK_YEN             HEX: 7D ; inline
: DIK_ABNT_C2         HEX: 7E ; inline
: DIK_NUMPADEQUALS    HEX: 8D ; inline
: DIK_PREVTRACK       HEX: 90 ; inline
: DIK_AT              HEX: 91 ; inline
: DIK_COLON           HEX: 92 ; inline
: DIK_UNDERLINE       HEX: 93 ; inline
: DIK_KANJI           HEX: 94 ; inline
: DIK_STOP            HEX: 95 ; inline
: DIK_AX              HEX: 96 ; inline
: DIK_UNLABELED       HEX: 97 ; inline
: DIK_NEXTTRACK       HEX: 99 ; inline
: DIK_NUMPADENTER     HEX: 9C ; inline
: DIK_RCONTROL        HEX: 9D ; inline
: DIK_MUTE            HEX: A0 ; inline
: DIK_CALCULATOR      HEX: A1 ; inline
: DIK_PLAYPAUSE       HEX: A2 ; inline
: DIK_MEDIASTOP       HEX: A4 ; inline
: DIK_VOLUMEDOWN      HEX: AE ; inline
: DIK_VOLUMEUP        HEX: B0 ; inline
: DIK_WEBHOME         HEX: B2 ; inline
: DIK_NUMPADCOMMA     HEX: B3 ; inline
: DIK_DIVIDE          HEX: B5 ; inline
: DIK_SYSRQ           HEX: B7 ; inline
: DIK_RMENU           HEX: B8 ; inline
: DIK_PAUSE           HEX: C5 ; inline
: DIK_HOME            HEX: C7 ; inline
: DIK_UP              HEX: C8 ; inline
: DIK_PRIOR           HEX: C9 ; inline
: DIK_LEFT            HEX: CB ; inline
: DIK_RIGHT           HEX: CD ; inline
: DIK_END             HEX: CF ; inline
: DIK_DOWN            HEX: D0 ; inline
: DIK_NEXT            HEX: D1 ; inline
: DIK_INSERT          HEX: D2 ; inline
: DIK_DELETE          HEX: D3 ; inline
: DIK_LWIN            HEX: DB ; inline
: DIK_RWIN            HEX: DC ; inline
: DIK_APPS            HEX: DD ; inline
: DIK_POWER           HEX: DE ; inline
: DIK_SLEEP           HEX: DF ; inline
: DIK_WAKE            HEX: E3 ; inline
: DIK_WEBSEARCH       HEX: E5 ; inline
: DIK_WEBFAVORITES    HEX: E6 ; inline
: DIK_WEBREFRESH      HEX: E7 ; inline
: DIK_WEBSTOP         HEX: E8 ; inline
: DIK_WEBFORWARD      HEX: E9 ; inline
: DIK_WEBBACK         HEX: EA ; inline
: DIK_MYCOMPUTER      HEX: EB ; inline
: DIK_MAIL            HEX: EC ; inline
: DIK_MEDIASELECT     HEX: ED ; inline

: DIK_BACKSPACE       DIK_BACK ; inline
: DIK_NUMPADSTAR      DIK_MULTIPLY ; inline
: DIK_LALT            DIK_LMENU ; inline
: DIK_CAPSLOCK        DIK_CAPITAL ; inline
: DIK_NUMPADMINUS     DIK_SUBTRACT ; inline
: DIK_NUMPADPLUS      DIK_ADD ; inline
: DIK_NUMPADPERIOD    DIK_DECIMAL ; inline
: DIK_NUMPADSLASH     DIK_DIVIDE ; inline
: DIK_RALT            DIK_RMENU ; inline
: DIK_UPARROW         DIK_UP ; inline
: DIK_PGUP            DIK_PRIOR ; inline
: DIK_LEFTARROW       DIK_LEFT ; inline
: DIK_RIGHTARROW      DIK_RIGHT ; inline
: DIK_DOWNARROW       DIK_DOWN ; inline
: DIK_PGDN            DIK_NEXT ; inline

: DIK_CIRCUMFLEX      DIK_PREVTRACK ; inline

SYMBOL: +dinput+

: create-dinput ( -- )
    f GetModuleHandle DIRECTINPUT_VERSION IDirectInput8W-iid
    f <void*> [ f DirectInput8Create ole32-error ] keep *void*
    +dinput+ set ;

: delete-dinput ( -- )
    +dinput+ [ com-release f ] change ;

