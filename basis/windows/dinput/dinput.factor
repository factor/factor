USING: windows.kernel32 windows.ole32 windows.com windows.com.syntax
alien alien.c-types alien.syntax kernel system namespaces math ;
IN: windows.dinput

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
: LPDIENUMCREATEDEFFECTOBJECTSCALLBACK ( quot -- callback )
    [ "BOOL" { "LPDIRECTINPUTEFFECT" "LPVOID" } "stdcall" ]
    dip alien-callback ; inline
TYPEDEF: void* LPDIENUMEFFECTSINFILECALLBACK
: LPDIENUMEFFECTSINFILECALLBACK ( quot -- callback )
    [ "BOOL" { "LPCDIFILEEFFECT" "LPVOID" } "stdcall" ]
    dip alien-callback ; inline
TYPEDEF: void* LPDIENUMDEVICEOBJECTSCALLBACKW
: LPDIENUMDEVICEOBJECTSCALLBACKW ( quot -- callback )
    [ "BOOL" { "LPCDIDEVICEOBJECTINSTANCEW" "LPVOID" } "stdcall" ]
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
    { "DWORD" "dwSize" }
    { "DWORD" "dwFlags" }
    { "DWORD" "dwDevType" }
    { "DWORD" "dwAxes" }
    { "DWORD" "dwButtons" }
    { "DWORD" "dwPOVs" }
    { "DWORD" "dwFFSamplePeriod" }
    { "DWORD" "dwFFMinTimeResolution" }
    { "DWORD" "dwFirmwareRevision" }
    { "DWORD" "dwHardwareRevision" }
    { "DWORD" "dwFFDriverVersion" } ;
TYPEDEF: DIDEVCAPS* LPDIDEVCAPS
TYPEDEF: DIDEVCAPS* LPCDIDEVCAPS
C-STRUCT: DIDEVICEOBJECTINSTANCEW
    { "DWORD" "dwSize" }
    { "GUID" "guidType" }
    { "DWORD" "dwOfs" }
    { "DWORD" "dwType" }
    { "DWORD" "dwFlags" }
    { "WCHAR[260]" "tszName" }
    { "DWORD" "dwFFMaxForce" }
    { "DWORD" "dwFFForceResolution" }
    { "WORD" "wCollectionNumber" }
    { "WORD" "wDesignatorIndex" }
    { "WORD" "wUsagePage" }
    { "WORD" "wUsage" }
    { "DWORD" "dwDimension" }
    { "WORD" "wExponent" }
    { "WORD" "wReportId" } ;
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
C-STRUCT: DIPROPDWORD
    { "DIPROPHEADER" "diph" }
    { "DWORD"        "dwData" } ;
TYPEDEF: DIPROPDWORD* LPDIPROPDWORD
TYPEDEF: DIPROPDWORD* LPCDIPROPDWORD
C-STRUCT: DIPROPPOINTER
    { "DIPROPHEADER" "diph" }
    { "UINT_PTR" "uData" } ;
TYPEDEF: DIPROPPOINTER* LPDIPROPPOINTER
TYPEDEF: DIPROPPOINTER* LPCDIPROPPOINTER
C-STRUCT: DIPROPRANGE
    { "DIPROPHEADER" "diph" }
    { "LONG" "lMin" }
    { "LONG" "lMax" } ;
TYPEDEF: DIPROPRANGE* LPDIPROPRANGE
TYPEDEF: DIPROPRANGE* LPCDIPROPRANGE
C-STRUCT: DIPROPCAL
    { "DIPROPHEADER" "diph" }
    { "LONG" "lMin" }
    { "LONG" "lCenter" }
    { "LONG" "lMax" } ;
TYPEDEF: DIPROPCAL* LPDIPROPCAL
TYPEDEF: DIPROPCAL* LPCDIPROPCAL
C-STRUCT: DIPROPGUIDANDPATH
    { "DIPROPHEADER" "diph" }
    { "GUID" "guidClass" }
    { "WCHAR[260]"   "wszPath" } ;
TYPEDEF: DIPROPGUIDANDPATH* LPDIPROPGUIDANDPATH
TYPEDEF: DIPROPGUIDANDPATH* LPCDIPROPGUIDANDPATH
C-STRUCT: DIPROPSTRING
    { "DIPROPHEADER" "diph" }
    { "WCHAR[260]"   "wsz" } ;
TYPEDEF: DIPROPSTRING* LPDIPROPSTRING
TYPEDEF: DIPROPSTRING* LPCDIPROPSTRING
C-STRUCT: CPOINT
    { "LONG" "lP" }
    { "DWORD" "dwLog" } ;
C-STRUCT: DIPROPCPOINTS
    { "DIPROPHEADER" "diph" }
    { "DWORD" "dwCPointsNum" }
    { "CPOINT[8]" "cp" } ;
TYPEDEF: DIPROPCPOINTS* LPDIPROPCPOINTS
TYPEDEF: DIPROPCPOINTS* LPCDIPROPCPOINTS
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

CONSTANT: DIRECTINPUT_VERSION HEX: 0800
                               
CONSTANT: DI8DEVCLASS_ALL             0
CONSTANT: DI8DEVCLASS_DEVICE          1
CONSTANT: DI8DEVCLASS_POINTER         2
CONSTANT: DI8DEVCLASS_KEYBOARD        3
CONSTANT: DI8DEVCLASS_GAMECTRL        4

CONSTANT: DIEDFL_ALLDEVICES       HEX: 00000000
CONSTANT: DIEDFL_ATTACHEDONLY     HEX: 00000001
CONSTANT: DIEDFL_FORCEFEEDBACK    HEX: 00000100
CONSTANT: DIEDFL_INCLUDEALIASES   HEX: 00010000
CONSTANT: DIEDFL_INCLUDEPHANTOMS  HEX: 00020000
CONSTANT: DIEDFL_INCLUDEHIDDEN    HEX: 00040000
                                               
CONSTANT: DIENUM_STOP             0
CONSTANT: DIENUM_CONTINUE         1

CONSTANT: DIDF_ABSAXIS            1
CONSTANT: DIDF_RELAXIS            2

CONSTANT: DIDFT_ALL           HEX: 00000000
         
CONSTANT: DIDFT_RELAXIS       HEX: 00000001
CONSTANT: DIDFT_ABSAXIS       HEX: 00000002
CONSTANT: DIDFT_AXIS          HEX: 00000003
         
CONSTANT: DIDFT_PSHBUTTON     HEX: 00000004
CONSTANT: DIDFT_TGLBUTTON     HEX: 00000008
CONSTANT: DIDFT_BUTTON        HEX: 0000000C
         
CONSTANT: DIDFT_POV           HEX: 00000010
CONSTANT: DIDFT_COLLECTION    HEX: 00000040
CONSTANT: DIDFT_NODATA        HEX: 00000080
         
CONSTANT: DIDFT_ANYINSTANCE   HEX: 00FFFF00
ALIAS: DIDFT_INSTANCEMASK  DIDFT_ANYINSTANCE
: DIDFT_MAKEINSTANCE ( n -- instance ) 8 shift                   ; inline
: DIDFT_GETTYPE      ( n -- type     ) HEX: FF bitand            ; inline
: DIDFT_GETINSTANCE  ( n -- instance ) -8 shift HEX: FFFF bitand ; inline
CONSTANT: DIDFT_FFACTUATOR        HEX: 01000000
CONSTANT: DIDFT_FFEFFECTTRIGGER   HEX: 02000000
CONSTANT: DIDFT_OUTPUT            HEX: 10000000
CONSTANT: DIDFT_VENDORDEFINED     HEX: 04000000
CONSTANT: DIDFT_ALIAS             HEX: 08000000
CONSTANT: DIDFT_OPTIONAL          HEX: 80000000

: DIDFT_ENUMCOLLECTION ( n -- instance ) 8 shift HEX: FFFF bitand ; inline
CONSTANT: DIDFT_NOCOLLECTION      HEX: 00FFFF00

CONSTANT: DIDOI_FFACTUATOR        HEX: 00000001
CONSTANT: DIDOI_FFEFFECTTRIGGER   HEX: 00000002
CONSTANT: DIDOI_POLLED            HEX: 00008000
CONSTANT: DIDOI_ASPECTPOSITION    HEX: 00000100
CONSTANT: DIDOI_ASPECTVELOCITY    HEX: 00000200
CONSTANT: DIDOI_ASPECTACCEL       HEX: 00000300
CONSTANT: DIDOI_ASPECTFORCE       HEX: 00000400
CONSTANT: DIDOI_ASPECTMASK        HEX: 00000F00
CONSTANT: DIDOI_GUIDISUSAGE       HEX: 00010000

CONSTANT: DISCL_EXCLUSIVE     HEX: 00000001
CONSTANT: DISCL_NONEXCLUSIVE  HEX: 00000002
CONSTANT: DISCL_FOREGROUND    HEX: 00000004
CONSTANT: DISCL_BACKGROUND    HEX: 00000008
CONSTANT: DISCL_NOWINKEY      HEX: 00000010

CONSTANT: DIMOFS_X        0
CONSTANT: DIMOFS_Y        4
CONSTANT: DIMOFS_Z        8
CONSTANT: DIMOFS_BUTTON0 12
CONSTANT: DIMOFS_BUTTON1 13
CONSTANT: DIMOFS_BUTTON2 14
CONSTANT: DIMOFS_BUTTON3 15
CONSTANT: DIMOFS_BUTTON4 16
CONSTANT: DIMOFS_BUTTON5 17
CONSTANT: DIMOFS_BUTTON6 18
CONSTANT: DIMOFS_BUTTON7 19

CONSTANT: DIK_ESCAPE          HEX: 01
CONSTANT: DIK_1               HEX: 02
CONSTANT: DIK_2               HEX: 03
CONSTANT: DIK_3               HEX: 04
CONSTANT: DIK_4               HEX: 05
CONSTANT: DIK_5               HEX: 06
CONSTANT: DIK_6               HEX: 07
CONSTANT: DIK_7               HEX: 08
CONSTANT: DIK_8               HEX: 09
CONSTANT: DIK_9               HEX: 0A
CONSTANT: DIK_0               HEX: 0B
CONSTANT: DIK_MINUS           HEX: 0C
CONSTANT: DIK_EQUALS          HEX: 0D
CONSTANT: DIK_BACK            HEX: 0E
CONSTANT: DIK_TAB             HEX: 0F
CONSTANT: DIK_Q               HEX: 10
CONSTANT: DIK_W               HEX: 11
CONSTANT: DIK_E               HEX: 12
CONSTANT: DIK_R               HEX: 13
CONSTANT: DIK_T               HEX: 14
CONSTANT: DIK_Y               HEX: 15
CONSTANT: DIK_U               HEX: 16
CONSTANT: DIK_I               HEX: 17
CONSTANT: DIK_O               HEX: 18
CONSTANT: DIK_P               HEX: 19
CONSTANT: DIK_LBRACKET        HEX: 1A
CONSTANT: DIK_RBRACKET        HEX: 1B
CONSTANT: DIK_RETURN          HEX: 1C
CONSTANT: DIK_LCONTROL        HEX: 1D
CONSTANT: DIK_A               HEX: 1E
CONSTANT: DIK_S               HEX: 1F
CONSTANT: DIK_D               HEX: 20
CONSTANT: DIK_F               HEX: 21
CONSTANT: DIK_G               HEX: 22
CONSTANT: DIK_H               HEX: 23
CONSTANT: DIK_J               HEX: 24
CONSTANT: DIK_K               HEX: 25
CONSTANT: DIK_L               HEX: 26
CONSTANT: DIK_SEMICOLON       HEX: 27
CONSTANT: DIK_APOSTROPHE      HEX: 28
CONSTANT: DIK_GRAVE           HEX: 29
CONSTANT: DIK_LSHIFT          HEX: 2A
CONSTANT: DIK_BACKSLASH       HEX: 2B
CONSTANT: DIK_Z               HEX: 2C
CONSTANT: DIK_X               HEX: 2D
CONSTANT: DIK_C               HEX: 2E
CONSTANT: DIK_V               HEX: 2F
CONSTANT: DIK_B               HEX: 30
CONSTANT: DIK_N               HEX: 31
CONSTANT: DIK_M               HEX: 32
CONSTANT: DIK_COMMA           HEX: 33
CONSTANT: DIK_PERIOD          HEX: 34
CONSTANT: DIK_SLASH           HEX: 35
CONSTANT: DIK_RSHIFT          HEX: 36
CONSTANT: DIK_MULTIPLY        HEX: 37
CONSTANT: DIK_LMENU           HEX: 38
CONSTANT: DIK_SPACE           HEX: 39
CONSTANT: DIK_CAPITAL         HEX: 3A
CONSTANT: DIK_F1              HEX: 3B
CONSTANT: DIK_F2              HEX: 3C
CONSTANT: DIK_F3              HEX: 3D
CONSTANT: DIK_F4              HEX: 3E
CONSTANT: DIK_F5              HEX: 3F
CONSTANT: DIK_F6              HEX: 40
CONSTANT: DIK_F7              HEX: 41
CONSTANT: DIK_F8              HEX: 42
CONSTANT: DIK_F9              HEX: 43
CONSTANT: DIK_F10             HEX: 44
CONSTANT: DIK_NUMLOCK         HEX: 45
CONSTANT: DIK_SCROLL          HEX: 46
CONSTANT: DIK_NUMPAD7         HEX: 47
CONSTANT: DIK_NUMPAD8         HEX: 48
CONSTANT: DIK_NUMPAD9         HEX: 49
CONSTANT: DIK_SUBTRACT        HEX: 4A
CONSTANT: DIK_NUMPAD4         HEX: 4B
CONSTANT: DIK_NUMPAD5         HEX: 4C
CONSTANT: DIK_NUMPAD6         HEX: 4D
CONSTANT: DIK_ADD             HEX: 4E
CONSTANT: DIK_NUMPAD1         HEX: 4F
CONSTANT: DIK_NUMPAD2         HEX: 50
CONSTANT: DIK_NUMPAD3         HEX: 51
CONSTANT: DIK_NUMPAD0         HEX: 52
CONSTANT: DIK_DECIMAL         HEX: 53
CONSTANT: DIK_OEM_102         HEX: 56
CONSTANT: DIK_F11             HEX: 57
CONSTANT: DIK_F12             HEX: 58
CONSTANT: DIK_F13             HEX: 64
CONSTANT: DIK_F14             HEX: 65
CONSTANT: DIK_F15             HEX: 66
CONSTANT: DIK_KANA            HEX: 70
CONSTANT: DIK_ABNT_C1         HEX: 73
CONSTANT: DIK_CONVERT         HEX: 79
CONSTANT: DIK_NOCONVERT       HEX: 7B
CONSTANT: DIK_YEN             HEX: 7D
CONSTANT: DIK_ABNT_C2         HEX: 7E
CONSTANT: DIK_NUMPADEQUALS    HEX: 8D
CONSTANT: DIK_PREVTRACK       HEX: 90
CONSTANT: DIK_AT              HEX: 91
CONSTANT: DIK_COLON           HEX: 92
CONSTANT: DIK_UNDERLINE       HEX: 93
CONSTANT: DIK_KANJI           HEX: 94
CONSTANT: DIK_STOP            HEX: 95
CONSTANT: DIK_AX              HEX: 96
CONSTANT: DIK_UNLABELED       HEX: 97
CONSTANT: DIK_NEXTTRACK       HEX: 99
CONSTANT: DIK_NUMPADENTER     HEX: 9C
CONSTANT: DIK_RCONTROL        HEX: 9D
CONSTANT: DIK_MUTE            HEX: A0
CONSTANT: DIK_CALCULATOR      HEX: A1
CONSTANT: DIK_PLAYPAUSE       HEX: A2
CONSTANT: DIK_MEDIASTOP       HEX: A4
CONSTANT: DIK_VOLUMEDOWN      HEX: AE
CONSTANT: DIK_VOLUMEUP        HEX: B0
CONSTANT: DIK_WEBHOME         HEX: B2
CONSTANT: DIK_NUMPADCOMMA     HEX: B3
CONSTANT: DIK_DIVIDE          HEX: B5
CONSTANT: DIK_SYSRQ           HEX: B7
CONSTANT: DIK_RMENU           HEX: B8
CONSTANT: DIK_PAUSE           HEX: C5
CONSTANT: DIK_HOME            HEX: C7
CONSTANT: DIK_UP              HEX: C8
CONSTANT: DIK_PRIOR           HEX: C9
CONSTANT: DIK_LEFT            HEX: CB
CONSTANT: DIK_RIGHT           HEX: CD
CONSTANT: DIK_END             HEX: CF
CONSTANT: DIK_DOWN            HEX: D0
CONSTANT: DIK_NEXT            HEX: D1
CONSTANT: DIK_INSERT          HEX: D2
CONSTANT: DIK_DELETE          HEX: D3
CONSTANT: DIK_LWIN            HEX: DB
CONSTANT: DIK_RWIN            HEX: DC
CONSTANT: DIK_APPS            HEX: DD
CONSTANT: DIK_POWER           HEX: DE
CONSTANT: DIK_SLEEP           HEX: DF
CONSTANT: DIK_WAKE            HEX: E3
CONSTANT: DIK_WEBSEARCH       HEX: E5
CONSTANT: DIK_WEBFAVORITES    HEX: E6
CONSTANT: DIK_WEBREFRESH      HEX: E7
CONSTANT: DIK_WEBSTOP         HEX: E8
CONSTANT: DIK_WEBFORWARD      HEX: E9
CONSTANT: DIK_WEBBACK         HEX: EA
CONSTANT: DIK_MYCOMPUTER      HEX: EB
CONSTANT: DIK_MAIL            HEX: EC
CONSTANT: DIK_MEDIASELECT     HEX: ED

ALIAS: DIK_BACKSPACE       DIK_BACK
ALIAS: DIK_NUMPADSTAR      DIK_MULTIPLY
ALIAS: DIK_LALT            DIK_LMENU
ALIAS: DIK_CAPSLOCK        DIK_CAPITAL
ALIAS: DIK_NUMPADMINUS     DIK_SUBTRACT
ALIAS: DIK_NUMPADPLUS      DIK_ADD
ALIAS: DIK_NUMPADPERIOD    DIK_DECIMAL
ALIAS: DIK_NUMPADSLASH     DIK_DIVIDE
ALIAS: DIK_RALT            DIK_RMENU
ALIAS: DIK_UPARROW         DIK_UP
ALIAS: DIK_PGUP            DIK_PRIOR
ALIAS: DIK_LEFTARROW       DIK_LEFT
ALIAS: DIK_RIGHTARROW      DIK_RIGHT
ALIAS: DIK_DOWNARROW       DIK_DOWN
ALIAS: DIK_PGDN            DIK_NEXT

ALIAS: DIK_CIRCUMFLEX      DIK_PREVTRACK

CONSTANT: DI8DEVTYPE_DEVICE           HEX: 11
CONSTANT: DI8DEVTYPE_MOUSE            HEX: 12
CONSTANT: DI8DEVTYPE_KEYBOARD         HEX: 13
CONSTANT: DI8DEVTYPE_JOYSTICK         HEX: 14
CONSTANT: DI8DEVTYPE_GAMEPAD          HEX: 15
CONSTANT: DI8DEVTYPE_DRIVING          HEX: 16
CONSTANT: DI8DEVTYPE_FLIGHT           HEX: 17
CONSTANT: DI8DEVTYPE_1STPERSON        HEX: 18
CONSTANT: DI8DEVTYPE_DEVICECTRL       HEX: 19
CONSTANT: DI8DEVTYPE_SCREENPOINTER    HEX: 1A
CONSTANT: DI8DEVTYPE_REMOTE           HEX: 1B
CONSTANT: DI8DEVTYPE_SUPPLEMENTAL     HEX: 1C

: GET_DIDEVICE_TYPE ( dwType -- type ) HEX: FF bitand ; inline

CONSTANT: DIPROPRANGE_NOMIN       HEX: 80000000
CONSTANT: DIPROPRANGE_NOMAX       HEX: 7FFFFFFF
CONSTANT: MAXCPOINTSNUM           8

CONSTANT: DIPH_DEVICE             0
CONSTANT: DIPH_BYOFFSET           1
CONSTANT: DIPH_BYID               2
CONSTANT: DIPH_BYUSAGE            3
                                   
: DIMAKEUSAGEDWORD ( UsagePage Usage -- DWORD ) 16 shift bitor ; inline

: DIPROP_BUFFERSIZE ( -- alien ) 1 <alien> ; inline
: DIPROP_AXISMODE   ( -- alien ) 2 <alien> ; inline

CONSTANT: DIPROPAXISMODE_ABS      0
CONSTANT: DIPROPAXISMODE_REL      1
                                   
: DIPROP_GRANULARITY ( -- alien ) 3 <alien> ; inline
: DIPROP_RANGE       ( -- alien ) 4 <alien> ; inline
: DIPROP_DEADZONE    ( -- alien ) 5 <alien> ; inline
: DIPROP_SATURATION  ( -- alien ) 6 <alien> ; inline
: DIPROP_FFGAIN      ( -- alien ) 7 <alien> ; inline
: DIPROP_FFLOAD      ( -- alien ) 8 <alien> ; inline
: DIPROP_AUTOCENTER  ( -- alien ) 9 <alien> ; inline

CONSTANT: DIPROPAUTOCENTER_OFF    0
CONSTANT: DIPROPAUTOCENTER_ON     1

: DIPROP_CALIBRATIONMODE ( -- alien ) 10 <alien> ; inline

CONSTANT: DIPROPCALIBRATIONMODE_COOKED    0
CONSTANT: DIPROPCALIBRATIONMODE_RAW       1

: DIPROP_CALIBRATION ( -- alien )        11 <alien> ; inline
: DIPROP_GUIDANDPATH ( -- alien )        12 <alien> ; inline
: DIPROP_INSTANCENAME ( -- alien )       13 <alien> ; inline
: DIPROP_PRODUCTNAME ( -- alien )        14 <alien> ; inline
: DIPROP_JOYSTICKID ( -- alien )         15 <alien> ; inline
: DIPROP_GETPORTDISPLAYNAME ( -- alien ) 16 <alien> ; inline
: DIPROP_PHYSICALRANGE ( -- alien )      18 <alien> ; inline
: DIPROP_LOGICALRANGE ( -- alien )       19 <alien> ; inline
: DIPROP_KEYNAME ( -- alien )            20 <alien> ; inline
: DIPROP_CPOINTS ( -- alien )            21 <alien> ; inline
: DIPROP_APPDATA ( -- alien )            22 <alien> ; inline
: DIPROP_SCANCODE ( -- alien )           23 <alien> ; inline
: DIPROP_VIDPID ( -- alien )             24 <alien> ; inline
: DIPROP_USERNAME ( -- alien )           25 <alien> ; inline
: DIPROP_TYPENAME ( -- alien )           26 <alien> ; inline

CONSTANT: GUID_XAxis          GUID: {A36D02E0-C9F3-11CF-BFC7-444553540000}
CONSTANT: GUID_YAxis          GUID: {A36D02E1-C9F3-11CF-BFC7-444553540000}
CONSTANT: GUID_ZAxis          GUID: {A36D02E2-C9F3-11CF-BFC7-444553540000}
CONSTANT: GUID_RxAxis         GUID: {A36D02F4-C9F3-11CF-BFC7-444553540000}
CONSTANT: GUID_RyAxis         GUID: {A36D02F5-C9F3-11CF-BFC7-444553540000}
CONSTANT: GUID_RzAxis         GUID: {A36D02E3-C9F3-11CF-BFC7-444553540000}
CONSTANT: GUID_Slider         GUID: {A36D02E4-C9F3-11CF-BFC7-444553540000}
CONSTANT: GUID_Button         GUID: {A36D02F0-C9F3-11CF-BFC7-444553540000}
CONSTANT: GUID_Key            GUID: {55728220-D33C-11CF-BFC7-444553540000}
CONSTANT: GUID_POV            GUID: {A36D02F2-C9F3-11CF-BFC7-444553540000}
CONSTANT: GUID_Unknown        GUID: {A36D02F3-C9F3-11CF-BFC7-444553540000}
CONSTANT: GUID_SysMouse       GUID: {6F1D2B60-D5A0-11CF-BFC7-444553540000}
CONSTANT: GUID_SysKeyboard    GUID: {6F1D2B61-D5A0-11CF-BFC7-444553540000}
CONSTANT: GUID_Joystick       GUID: {6F1D2B70-D5A0-11CF-BFC7-444553540000}
CONSTANT: GUID_SysMouseEm     GUID: {6F1D2B80-D5A0-11CF-BFC7-444553540000}
CONSTANT: GUID_SysMouseEm2    GUID: {6F1D2B81-D5A0-11CF-BFC7-444553540000}
CONSTANT: GUID_SysKeyboardEm  GUID: {6F1D2B82-D5A0-11CF-BFC7-444553540000}
CONSTANT: GUID_SysKeyboardEm2 GUID: {6F1D2B83-D5A0-11CF-BFC7-444553540000}
