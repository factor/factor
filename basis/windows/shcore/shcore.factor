! Copyright (C) 2017 Benjamin Pollack, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax windows.types ;
IN: windows.shcore

LIBRARY: shcore

ENUM: MONITOR_DPI_TYPE
    MDT_EFFECTIVE_DPI
    MDT_ANGULAR_DPI
    MDT_RAW_DPI
    { MDT_DEFAULT 0 } ;

! CommandLineToArgvW	
! CreateRandomAccessStreamOnFile	
! CreateRandomAccessStreamOverStream	
! CreateStreamOverRandomAccessStream	
! DllCanUnloadNow	
! DllGetActivationFactory	
! DllGetClassObject	
! GetCurrentProcessExplicitAppUserModelID	
FUNCTION: HRESULT GetDpiForMonitor ( HMONITOR hMonitor, MONITOR_DPI_TYPE dpiType, UINT* dpiX, UINT *dpiY )
! GetDpiForShellUIComponent	
! GetFeatureEnabledState	
! GetFeatureVariant	
! GetProcessDpiAwareness	
! GetProcessReference	
! GetScaleFactorForDevice	
! GetScaleFactorForMonitor	
! IsOS	
! IsProcessInIsolatedContainer	
! IStream_Copy	
! IStream_Read	
! IStream_ReadStr	
! IStream_Reset	
! IStream_Size	
! IStream_Write	
! IStream_WriteStr	
! IUnknown_AtomicRelease	
! IUnknown_GetSite	
! IUnknown_QueryService	
! IUnknown_Set	
! IUnknown_SetSite	
! RecordFeatureError	
! RecordFeatureUsage	
! RegisterScaleChangeEvent	
! RegisterScaleChangeNotifications	
! RevokeScaleChangeNotifications	
! SetCurrentProcessExplicitAppUserModelID	
! SetProcessDpiAwareness	
! SetProcessReference	
! SHAnsiToAnsi	
! SHAnsiToUnicode	
! SHCopyKeyA	
! SHCopyKeyW	
! SHCreateMemStream	
! SHCreateStreamOnFileA	
! SHCreateStreamOnFileEx	
! SHCreateStreamOnFileW	
! SHCreateThread	
! SHCreateThreadRef	
! SHCreateThreadWithHandle	
! SHDeleteEmptyKeyA	
! SHDeleteEmptyKeyW	
! SHDeleteKeyA	
! SHDeleteKeyW	
! SHDeleteValueA	
! SHDeleteValueW	
! SHEnumKeyExA	
! SHEnumKeyExW	
! SHEnumValueA	
! SHEnumValueW	
! SHGetThreadRef	
! SHGetValueA	
! SHGetValueW	
! SHOpenRegStream2A	
! SHOpenRegStream2W	
! SHOpenRegStreamA	
! SHOpenRegStreamW	
! SHQueryInfoKeyA	
! SHQueryInfoKeyW	
! SHQueryValueExA	
! SHQueryValueExW	
! SHRegDuplicateHKey	
! SHRegGetIntW	
! SHRegGetPathA	
! SHRegGetPathW	
! SHRegGetValueA	
! SHRegGetValueFromHKCUHKLM	
! SHRegGetValueW	
! SHRegSetPathA	
! SHRegSetPathW	
! SHReleaseThreadRef	
! SHSetThreadRef	
! SHSetValueA	
! SHSetValueW	
! SHStrDupA	
! SHStrDupW	
! SHUnicodeToAnsi	
! SHUnicodeToUnicode	
! SubscribeFeatureStateChangeNotification	
! UnregisterScaleChangeEvent	
! UnsubscribeFeatureStateChangeNotification	
