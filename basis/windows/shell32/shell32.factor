! Copyright (C) 2006, 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.data alien.strings alien.syntax
classes.struct io.backend kernel literals math windows
windows.com windows.com.syntax windows.kernel32 windows.messages
windows.ole32 windows.types ;
IN: windows.shell32

CONSTANT: CSIDL_DESKTOP 0x00
CONSTANT: CSIDL_INTERNET 0x01
CONSTANT: CSIDL_PROGRAMS 0x02
CONSTANT: CSIDL_CONTROLS 0x03
CONSTANT: CSIDL_PRINTERS 0x04
CONSTANT: CSIDL_PERSONAL 0x05
CONSTANT: CSIDL_FAVORITES 0x06
CONSTANT: CSIDL_STARTUP 0x07
CONSTANT: CSIDL_RECENT 0x08
CONSTANT: CSIDL_SENDTO 0x09
CONSTANT: CSIDL_BITBUCKET 0x0a
CONSTANT: CSIDL_STARTMENU 0x0b
CONSTANT: CSIDL_MYDOCUMENTS 0x0c
CONSTANT: CSIDL_MYMUSIC 0x0d
CONSTANT: CSIDL_MYVIDEO 0x0e
CONSTANT: CSIDL_DESKTOPDIRECTORY 0x10
CONSTANT: CSIDL_DRIVES 0x11
CONSTANT: CSIDL_NETWORK 0x12
CONSTANT: CSIDL_NETHOOD 0x13
CONSTANT: CSIDL_FONTS 0x14
CONSTANT: CSIDL_TEMPLATES 0x15
CONSTANT: CSIDL_COMMON_STARTMENU 0x16
CONSTANT: CSIDL_COMMON_PROGRAMS 0x17
CONSTANT: CSIDL_COMMON_STARTUP 0x18
CONSTANT: CSIDL_COMMON_DESKTOPDIRECTORY 0x19
CONSTANT: CSIDL_APPDATA 0x1a
CONSTANT: CSIDL_PRINTHOOD 0x1b
CONSTANT: CSIDL_LOCAL_APPDATA 0x1c
CONSTANT: CSIDL_ALTSTARTUP 0x1d
CONSTANT: CSIDL_COMMON_ALTSTARTUP 0x1e
CONSTANT: CSIDL_COMMON_FAVORITES 0x1f
CONSTANT: CSIDL_INTERNET_CACHE 0x20
CONSTANT: CSIDL_COOKIES 0x21
CONSTANT: CSIDL_HISTORY 0x22
CONSTANT: CSIDL_COMMON_APPDATA 0x23
CONSTANT: CSIDL_WINDOWS 0x24
CONSTANT: CSIDL_SYSTEM 0x25
CONSTANT: CSIDL_PROGRAM_FILES 0x26
CONSTANT: CSIDL_MYPICTURES 0x27
CONSTANT: CSIDL_PROFILE 0x28
CONSTANT: CSIDL_SYSTEMX86 0x29
CONSTANT: CSIDL_PROGRAM_FILESX86 0x2a
CONSTANT: CSIDL_PROGRAM_FILES_COMMON 0x2b
CONSTANT: CSIDL_PROGRAM_FILES_COMMONX86 0x2c
CONSTANT: CSIDL_COMMON_TEMPLATES 0x2d
CONSTANT: CSIDL_COMMON_DOCUMENTS 0x2e
CONSTANT: CSIDL_COMMON_ADMINTOOLS 0x2f
CONSTANT: CSIDL_ADMINTOOLS 0x30
CONSTANT: CSIDL_CONNECTIONS 0x31
CONSTANT: CSIDL_COMMON_MUSIC 0x35
CONSTANT: CSIDL_COMMON_PICTURES 0x36
CONSTANT: CSIDL_COMMON_VIDEO 0x37
CONSTANT: CSIDL_RESOURCES 0x38
CONSTANT: CSIDL_RESOURCES_LOCALIZED 0x39
CONSTANT: CSIDL_COMMON_OEM_LINKS 0x3a
CONSTANT: CSIDL_CDBURN_AREA 0x3b
CONSTANT: CSIDL_COMPUTERSNEARME 0x3d
CONSTANT: CSIDL_PROFILES 0x3e
CONSTANT: CSIDL_FOLDER_MASK 0xff
CONSTANT: CSIDL_FLAG_PER_USER_INIT 0x800
CONSTANT: CSIDL_FLAG_NO_ALIAS 0x1000
CONSTANT: CSIDL_FLAG_DONT_VERIFY 0x4000
CONSTANT: CSIDL_FLAG_CREATE 0x8000
CONSTANT: CSIDL_FLAG_MASK 0xff00

CONSTANT: SHGFP_TYPE_CURRENT 0
CONSTANT: SHGFP_TYPE_DEFAULT 1

LIBRARY: shell32

FUNCTION: HRESULT SHGetFolderPathW ( HWND hwndOwner,
                                     int nFolder,
                                     HANDLE hToken,
                                     DWORD dwReserved,
                                     LPTSTR pszPath )
ALIAS: SHGetFolderPath SHGetFolderPathW

FUNCTION: HINSTANCE ShellExecuteW ( HWND hwnd,
                                    LPCTSTR lpOperation,
                                    LPCTSTR lpFile,
                                    LPCTSTR lpParameters,
                                    LPCTSTR lpDirectory, INT nShowCmd )
ALIAS: ShellExecute ShellExecuteW

CONSTANT: SHGFI_ICON 0x000000100
CONSTANT: SHGFI_DISPLAYNAME 0x000000200
CONSTANT: SHGFI_TYPENAME 0x000000400
CONSTANT: SHGFI_ATTRIBUTES 0x000000800
CONSTANT: SHGFI_ICONLOCATION 0x000001000
CONSTANT: SHGFI_EXETYPE 0x000002000
CONSTANT: SHGFI_SYSICONINDEX 0x000004000
CONSTANT: SHGFI_LINKOVERLAY 0x000008000
CONSTANT: SHGFI_SELECTED 0x000010000
CONSTANT: SHGFI_ATTR_SPECIFIED 0x000020000
CONSTANT: SHGFI_LARGEICON 0x000000000
CONSTANT: SHGFI_SMALLICON 0x000000001
CONSTANT: SHGFI_OPENICON 0x000000002
CONSTANT: SHGFI_SHELLICONSIZE 0x000000004
CONSTANT: SHGFI_PIDL 0x000000008
CONSTANT: SHGFI_USEFILEATTRIBUTES 0x000000010
CONSTANT: SHGFI_ADDOVERLAYS 0x000000020
CONSTANT: SHGFI_OVERLAYINDEX 0x000000040

STRUCT: SHFILEINFO
    { hIcon HICON }
    { iIcon int }
    { dwAttributes DWORD }
    { szDisplayName TCHAR[MAX_PATH] }
    { szTypeName TCHAR[80] } ;

FUNCTION: DWORD_PTR SHGetFileInfoW ( LPCTSTR pszPath,
                                     DWORD dwFileAttributes,
                                     SHFILEINFO *psfi,
                                     UINT cbFileInfo,
                                     UINT uFlags )

: shell32-file-info ( path -- err struct )
    normalize-path
    0
    SHFILEINFO new
    [ dup byte-length SHGFI_EXETYPE SHGetFileInfoW ] keep ;

SINGLETONS:
    +dos-executable+
    +win32-console-executable+
    +win32-vxd-executable+
    +win32-os2-executable+
    +win32-nt-executable+ ;

MIXIN: windows-executable
INSTANCE: +dos-executable+ windows-executable        ! mz
INSTANCE: +win32-console-executable+ windows-executable
INSTANCE: +win32-vxd-executable+ windows-executable  ! le
INSTANCE: +win32-os2-executable+ windows-executable  ! ne
INSTANCE: +win32-nt-executable+ windows-executable   ! pe

: shell32-directory ( n -- str )
    f swap f SHGFP_TYPE_DEFAULT
    MAX_UNICODE_PATH ushort <c-array>
    [ SHGetFolderPath drop ] keep alien>native-string ;

: desktop ( -- str )
    CSIDL_DESKTOPDIRECTORY shell32-directory ;

: my-documents ( -- str )
    CSIDL_PERSONAL shell32-directory ;

: application-data ( -- str )
    CSIDL_APPDATA shell32-directory ;

: local-application-data ( -- str )
    CSIDL_LOCAL_APPDATA shell32-directory ;

: common-application-data ( -- str )
    CSIDL_COMMON_APPDATA shell32-directory ;

: windows-directory ( -- str )
    CSIDL_WINDOWS shell32-directory ;

: programs ( -- str )
    CSIDL_PROGRAMS shell32-directory ;

: program-files ( -- str )
    CSIDL_PROGRAM_FILES shell32-directory ;

: program-files-x86 ( -- str )
    CSIDL_PROGRAM_FILESX86 shell32-directory ;

: program-files-common ( -- str )
    CSIDL_PROGRAM_FILES_COMMON shell32-directory ;

: program-files-common-x86 ( -- str )
    CSIDL_PROGRAM_FILES_COMMONX86 shell32-directory ;


CONSTANT: SHCONTF_FOLDERS 32
CONSTANT: SHCONTF_NONFOLDERS 64
CONSTANT: SHCONTF_INCLUDEHIDDEN 128
CONSTANT: SHCONTF_INIT_ON_FIRST_NEXT 256
CONSTANT: SHCONTF_NETPRINTERSRCH 512
CONSTANT: SHCONTF_SHAREABLE 1024
CONSTANT: SHCONTF_STORAGE 2048

TYPEDEF: DWORD SHCONTF

CONSTANT: SHGDN_NORMAL 0
CONSTANT: SHGDN_INFOLDER 1
CONSTANT: SHGDN_FOREDITING 0x1000
CONSTANT: SHGDN_INCLUDE_NONFILESYS 0x2000
CONSTANT: SHGDN_FORADDRESSBAR 0x4000
CONSTANT: SHGDN_FORPARSING 0x8000

TYPEDEF: DWORD SHGDNF

ALIAS: SFGAO_CANCOPY           DROPEFFECT_COPY
ALIAS: SFGAO_CANMOVE           DROPEFFECT_MOVE
ALIAS: SFGAO_CANLINK           DROPEFFECT_LINK
CONSTANT: SFGAO_CANRENAME         0x00000010
CONSTANT: SFGAO_CANDELETE         0x00000020
CONSTANT: SFGAO_HASPROPSHEET      0x00000040
CONSTANT: SFGAO_DROPTARGET        0x00000100
CONSTANT: SFGAO_CAPABILITYMASK    0x00000177
CONSTANT: SFGAO_LINK              0x00010000
CONSTANT: SFGAO_SHARE             0x00020000
CONSTANT: SFGAO_READONLY          0x00040000
CONSTANT: SFGAO_GHOSTED           0x00080000
CONSTANT: SFGAO_HIDDEN            0x00080000
CONSTANT: SFGAO_DISPLAYATTRMASK   0x000F0000
CONSTANT: SFGAO_FILESYSANCESTOR   0x10000000
CONSTANT: SFGAO_FOLDER            0x20000000
CONSTANT: SFGAO_FILESYSTEM        0x40000000
CONSTANT: SFGAO_HASSUBFOLDER      0x80000000
CONSTANT: SFGAO_CONTENTSMASK      0x80000000
CONSTANT: SFGAO_VALIDATE          0x01000000
CONSTANT: SFGAO_REMOVABLE         0x02000000
CONSTANT: SFGAO_COMPRESSED        0x04000000
CONSTANT: SFGAO_BROWSABLE         0x08000000
CONSTANT: SFGAO_NONENUMERATED     0x00100000
CONSTANT: SFGAO_NEWCONTENT        0x00200000

TYPEDEF: ULONG SFGAOF

STRUCT: DROPFILES
    { pFiles DWORD }
    { pt POINT }
    { fNC BOOL }
    { fWide BOOL } ;
TYPEDEF: DROPFILES* LPDROPFILES
TYPEDEF: DROPFILES* LPCDROPFILES

STRUCT: SHITEMID
    { cb USHORT }
    { abID BYTE[1] } ;
TYPEDEF: SHITEMID* LPSHITEMID
TYPEDEF: SHITEMID* LPCSHITEMID

STRUCT: ITEMIDLIST
    { mkid SHITEMID } ;
TYPEDEF: ITEMIDLIST* LPITEMIDLIST
TYPEDEF: ITEMIDLIST* LPCITEMIDLIST
TYPEDEF: ITEMIDLIST ITEMID_CHILD
TYPEDEF: ITEMID_CHILD* PITEMID_CHILD
TYPEDEF: ITEMID_CHILD* PCUITEMID_CHILD
TYPEDEF: ITEMIDLIST ITEMIDLIST_RELATIVE
TYPEDEF: ITEMIDLIST ITEMIDLIST_ABSOLUTE
TYPEDEF: ITEMIDLIST_ABSOLUTE* PIDLIST_ABSOLUTE
TYPEDEF: ITEMIDLIST_ABSOLUTE* PCIDLIST_ABSOLUTE

CONSTANT: STRRET_WSTR 0
CONSTANT: STRRET_OFFSET 1
CONSTANT: STRRET_CSTR 2

UNION-STRUCT: STRRET-union
    { pOleStr LPWSTR }
    { uOffset UINT }
    { cStr char[260] } ;
STRUCT: STRRET
    { uType int }
    { value STRRET-union } ;

COM-INTERFACE: IEnumIDList IUnknown {000214F2-0000-0000-C000-000000000046}
    HRESULT Next ( ULONG celt, LPITEMIDLIST* rgelt, ULONG* pceltFetched )
    HRESULT Skip ( ULONG celt )
    HRESULT Reset ( )
    HRESULT Clone ( IEnumIDList** ppenum ) ;

COM-INTERFACE: IShellFolder IUnknown {000214E6-0000-0000-C000-000000000046}
    HRESULT ParseDisplayName ( HWND hwndOwner,
                               void* pbcReserved,
                               LPOLESTR lpszDisplayName,
                               ULONG* pchEaten,
                               LPITEMIDLIST* ppidl,
                               ULONG* pdwAttributes )
    HRESULT EnumObjects ( HWND hwndOwner,
                          SHCONTF grfFlags,
                          IEnumIDList** ppenumIDList )
    HRESULT BindToObject ( LPCITEMIDLIST pidl,
                           void* pbcReserved,
                           REFGUID riid,
                           void** ppvOut )
    HRESULT BindToStorage ( LPCITEMIDLIST pidl,
                            void* pbcReserved,
                            REFGUID riid,
                            void** ppvObj )
    HRESULT CompareIDs ( LPARAM lParam,
                         LPCITEMIDLIST pidl1,
                         LPCITEMIDLIST pidl2 )
    HRESULT CreateViewObject ( HWND hwndOwner,
                               REFGUID riid,
                               void** ppvOut )
    HRESULT GetAttributesOf ( UINT cidl,
                              LPCITEMIDLIST* apidl,
                              SFGAOF* rgfInOut )
    HRESULT GetUIObjectOf ( HWND hwndOwner,
                            UINT cidl,
                            LPCITEMIDLIST* apidl,
                            REFGUID riid,
                            UINT* prgfInOut,
                            void** ppvOut )
    HRESULT GetDisplayNameOf ( LPCITEMIDLIST pidl,
                               SHGDNF uFlags,
                               STRRET* lpName )
    HRESULT SetNameOf ( HWND hwnd,
                        LPCITEMIDLIST pidl,
                        LPCOLESTR lpszName,
                        SHGDNF uFlags,
                        LPITEMIDLIST* ppidlOut ) ;

FUNCTION: HRESULT SHGetDesktopFolder ( IShellFolder** ppshf )

FUNCTION: void DragAcceptFiles ( HWND hWnd, BOOL fAccept )

FUNCTION: UINT DragQueryFileW ( HDROP hDrop,
                                UINT iFile,
                                LPWSTR lpszFile,
                                UINT cch )
ALIAS: DragQueryFile DragQueryFileW

FUNCTION: BOOL DragQueryPoint ( HDROP hDrop, POINT* lppt )

FUNCTION: void DragFinish ( HDROP hDrop )

FUNCTION: BOOL IsUserAnAdmin ( )


CONSTANT: NIM_ADD 0
CONSTANT: NIM_MODIFY 1
CONSTANT: NIM_DELETE 2
CONSTANT: NIM_SETFOCUS 3
CONSTANT: NIM_SETVERSION 4

CONSTANT: NIF_MESSAGE 0x1
CONSTANT: NIF_ICON 0x2
CONSTANT: NIF_TIP 0x4
CONSTANT: NIF_STATE 0x8
CONSTANT: NIF_INFO 0x10
CONSTANT: NIF_GUID 0x20
CONSTANT: NIF_REALTIME 0x40
CONSTANT: NIF_SHOWTIP 0x80

CONSTANT: NIIF_NONE 0x0
CONSTANT: NIIF_INFO 0x1
CONSTANT: NIIF_WARNING 0x2
CONSTANT: NIIF_ERROR 0x3
CONSTANT: NIIF_USER 0x4
CONSTANT: NIIF_ICON_MASK 0xF
CONSTANT: NIIF_NOSOUND 0x10

CONSTANT: NIS_HIDDEN 1
CONSTANT: NIS_SHAREDICON 2

CONSTANT: NOTIFYICON_VERSION 3
CONSTANT: NOTIFYICON_VERSION_4 4

! >= 0x0500
CONSTANT: NIN_SELECT $[ WM_USER 0 + ]
CONSTANT: NIN_KEYSELECT $[ WM_USER 1 + ]
! >= 0x0501
CONSTANT: NIN_BALLOONSHOW $[ WM_USER 2 + ]
CONSTANT: NIN_BALLOONHIDE $[ WM_USER 3 + ]
CONSTANT: NIN_BALLOONTIMEOUT $[ WM_USER 4 + ]
CONSTANT: NIN_BALLOONUSERCLICK $[ WM_USER 5 + ]

UNION-STRUCT: timeout-version-union { uTimeout UINT } { uVersion UINT } ;
STRUCT: NOTIFYICONDATA
    { cbSize DWORD }
    { hWnd HWND }
    { uID UINT }
    { uFlags UINT }
    { uCallbackMessage UINT }
    { hIcon HICON }
    { szTip TCHAR[64] }
    { dwState DWORD }
    { dwStateMask DWORD }
    { szInfo TCHAR[256] }
    { timeout-version timeout-version-union } ! { uVersion UINT } ! c-union here1
    { szInfoTitle TCHAR[64] }
    { dwInfoFlags DWORD }
    { guidItem GUID }
    { hBalloonIcon HICON } ;

TYPEDEF: NOTIFYICONDATA* PNOTIFYICONDATA

FUNCTION: BOOL Shell_NotifyIcon ( DWORD dwMessage, PNOTIFYICONDATA lpdata )

TYPEDEF: HRESULT SHSTDAPI

FUNCTION: SHSTDAPI SHBindToParent (
    PCIDLIST_ABSOLUTE pidl,
    REFIID            riid,
    void              **ppv,
    PCUITEMID_CHILD   *ppidlLast
)

! FUNCTION: AppCompat_RunDLLW
! FUNCTION: AssocCreateForClasses
! FUNCTION: AssocGetDetailsOfPropKey
! FUNCTION: CDefFolderMenu_Create2
! FUNCTION: CheckEscapesW
! FUNCTION: CIDLData_CreateFromIDArray
! FUNCTION: CommandLineToArgvW
! FUNCTION: Control_RunDLL
! FUNCTION: Control_RunDLLA
! FUNCTION: Control_RunDLLAsUserW
! FUNCTION: Control_RunDLLW
! FUNCTION: CreateStorageItemFromPath_FullTrustCaller
! FUNCTION: CreateStorageItemFromPath_FullTrustCaller_ForPackage
! FUNCTION: CreateStorageItemFromPath_PartialTrustCaller
! FUNCTION: CreateStorageItemFromShellItem_FullTrustCaller
! FUNCTION: CreateStorageItemFromShellItem_FullTrustCaller_ForPackage
! FUNCTION: CreateStorageItemFromShellItem_FullTrustCaller_ForPackage_WithProcessHandle
! FUNCTION: CreateStorageItemFromShellItem_FullTrustCaller_UseImplicitFlagsAndPackage
! FUNCTION: CStorageItem_GetValidatedStorageItemObject
! FUNCTION: DAD_AutoScroll
! FUNCTION: DAD_DragEnterEx
! FUNCTION: DAD_DragEnterEx2
! FUNCTION: DAD_DragLeave
! FUNCTION: DAD_DragMove
! FUNCTION: DAD_SetDragImage
! FUNCTION: DAD_ShowDragImage
! FUNCTION: DllCanUnloadNow
! FUNCTION: DllGetActivationFactory
! FUNCTION: DllGetClassObject
! FUNCTION: DllGetVersion
! FUNCTION: DllInstall
! FUNCTION: DllRegisterServer
! FUNCTION: DllUnregisterServer
! FUNCTION: DoEnvironmentSubstA
! FUNCTION: DoEnvironmentSubstW
! FUNCTION: DragQueryFileA
! FUNCTION: DragQueryFileAorW
! FUNCTION: DriveType
! FUNCTION: DuplicateIcon
! FUNCTION: ExtractAssociatedIconA
! FUNCTION: ExtractAssociatedIconExA
! FUNCTION: ExtractAssociatedIconExW
! FUNCTION: ExtractAssociatedIconW
! FUNCTION: ExtractIconA
! FUNCTION: ExtractIconEx
! FUNCTION: ExtractIconExA
! FUNCTION: ExtractIconExW
! FUNCTION: ExtractIconW
! FUNCTION: FindExecutableA
! FUNCTION: FindExecutableW
! FUNCTION: FreeIconList
! FUNCTION: GetCurrentProcessExplicitAppUserModelID
! FUNCTION: GetFileNameFromBrowse
! FUNCTION: GetSystemPersistedStorageItemList
! FUNCTION: ILAppendID
! FUNCTION: ILClone
! FUNCTION: ILCloneFirst
! FUNCTION: ILCombine
! FUNCTION: ILCreateFromPath
! FUNCTION: ILCreateFromPathA
! FUNCTION: ILCreateFromPathW
! FUNCTION: ILFindChild
! FUNCTION: ILFindLastID
! FUNCTION: ILFree
! FUNCTION: ILGetNext
! FUNCTION: ILGetSize
! FUNCTION: ILIsEqual
! FUNCTION: ILIsParent
! FUNCTION: ILLoadFromStreamEx
! FUNCTION: ILRemoveLastID
! FUNCTION: ILSaveToStream
! FUNCTION: InitNetworkAddressControl
! FUNCTION: InternalExtractIconListA
! FUNCTION: InternalExtractIconListW
! FUNCTION: IsDesktopExplorerProcess
! FUNCTION: IsLFNDrive
! FUNCTION: IsLFNDriveA
! FUNCTION: IsLFNDriveW
! FUNCTION: IsNetDrive
! FUNCTION: IsProcessAnExplorer
! FUNCTION: LaunchMSHelp_RunDLLW
! FUNCTION: OpenAs_RunDLL
! FUNCTION: OpenAs_RunDLLA
! FUNCTION: OpenAs_RunDLLW
! FUNCTION: OpenRegStream
! FUNCTION: Options_RunDLL
! FUNCTION: Options_RunDLLA
! FUNCTION: Options_RunDLLW
! FUNCTION: PathCleanupSpec
! FUNCTION: PathGetShortPath
! FUNCTION: PathIsExe
! FUNCTION: PathIsSlowA
! FUNCTION: PathIsSlowW
! FUNCTION: PathMakeUniqueName
! FUNCTION: PathQualify
! FUNCTION: PathResolve
! FUNCTION: PathYetAnotherMakeUniqueName
! FUNCTION: PickIconDlg
! FUNCTION: PifMgr_CloseProperties
! FUNCTION: PifMgr_GetProperties
! FUNCTION: PifMgr_OpenProperties
! FUNCTION: PifMgr_SetProperties
! FUNCTION: PrepareDiscForBurnRunDllW
! FUNCTION: PrintersGetCommand_RunDLL
! FUNCTION: PrintersGetCommand_RunDLLA
! FUNCTION: PrintersGetCommand_RunDLLW
! FUNCTION: ReadCabinetState
! FUNCTION: RealDriveType
! FUNCTION: RealShellExecuteA
! FUNCTION: RealShellExecuteExA
! FUNCTION: RealShellExecuteExW
! FUNCTION: RealShellExecuteW
! FUNCTION: RegenerateUserEnvironment
! FUNCTION: RestartDialog
! FUNCTION: RestartDialogEx
! FUNCTION: RunAsNewUser_RunDLLW
! FUNCTION: SetCurrentProcessExplicitAppUserModelID
! FUNCTION: SHAddDefaultPropertiesByExt
! FUNCTION: SHAddFromPropSheetExtArray
! FUNCTION: SHAddToRecentDocs
! FUNCTION: SHAlloc
! FUNCTION: SHAppBarMessage
! FUNCTION: SHAssocEnumHandlers
! FUNCTION: SHAssocEnumHandlersForProtocolByApplication
! FUNCTION: SHBindToFolderIDListParent
! FUNCTION: SHBindToFolderIDListParentEx
! FUNCTION: SHBindToObject
! FUNCTION: SHBrowseForFolder
! FUNCTION: SHBrowseForFolderA
! FUNCTION: SHBrowseForFolderW
! FUNCTION: SHChangeNotification_Lock
! FUNCTION: SHChangeNotification_Unlock
! FUNCTION: SHChangeNotify
! FUNCTION: SHChangeNotifyDeregister
! FUNCTION: SHChangeNotifyRegister
! FUNCTION: SHChangeNotifyRegisterThread
! FUNCTION: SHChangeNotifySuspendResume
! FUNCTION: SHCloneSpecialIDList
! FUNCTION: SHCLSIDFromString
! FUNCTION: SHCoCreateInstance
! FUNCTION: SHCoCreateInstanceWorker
! FUNCTION: SHCreateAssociationRegistration
! FUNCTION: SHCreateCategoryEnum
! FUNCTION: SHCreateDataObject
! FUNCTION: SHCreateDefaultContextMenu
! FUNCTION: SHCreateDefaultExtractIcon
! FUNCTION: SHCreateDefaultPropertiesOp
! FUNCTION: SHCreateDirectory
! FUNCTION: SHCreateDirectoryExA
! FUNCTION: SHCreateDirectoryExW
! FUNCTION: SHCreateDrvExtIcon
! FUNCTION: SHCreateFileExtractIconW
! FUNCTION: SHCreateItemFromIDList
! FUNCTION: SHCreateItemFromParsingName
! FUNCTION: SHCreateItemFromRelativeName
! FUNCTION: SHCreateItemInKnownFolder
! FUNCTION: SHCreateItemWithParent
! FUNCTION: SHCreateLocalServerRunDll
! FUNCTION: SHCreateProcessAsUserW
! FUNCTION: SHCreatePropSheetExtArray
! FUNCTION: SHCreateQueryCancelAutoPlayMoniker
! FUNCTION: SHCreateShellFolderView
! FUNCTION: SHCreateShellFolderViewEx
! FUNCTION: SHCreateShellItem
! FUNCTION: SHCreateShellItemArray
! FUNCTION: SHCreateShellItemArrayFromDataObject
! FUNCTION: SHCreateShellItemArrayFromIDLists
! FUNCTION: SHCreateShellItemArrayFromShellItem
! FUNCTION: SHCreateStdEnumFmtEtc
! FUNCTION: SHDefExtractIconA
! FUNCTION: SHDefExtractIconW
! FUNCTION: SHDestroyPropSheetExtArray
! FUNCTION: SHDoDragDrop
! FUNCTION: SheChangeDirA
! FUNCTION: SheChangeDirExW
! FUNCTION: SheGetDirA
! FUNCTION: SHELL32_AddToBackIconTable
! FUNCTION: SHELL32_AddToFrontIconTable
! FUNCTION: SHELL32_AreAllItemsAvailable
! FUNCTION: SHELL32_BindToFilePlaceholderHandler
! FUNCTION: SHELL32_CallFileCopyHooks
! FUNCTION: SHELL32_CanDisplayWin8CopyDialog
! FUNCTION: SHELL32_CCommonPlacesFolder_CreateInstance
! FUNCTION: SHELL32_CDBurn_CloseSession
! FUNCTION: SHELL32_CDBurn_DriveSupportedForDataBurn
! FUNCTION: SHELL32_CDBurn_Erase
! FUNCTION: SHELL32_CDBurn_GetCDInfo
! FUNCTION: SHELL32_CDBurn_GetLiveFSDiscInfo
! FUNCTION: SHELL32_CDBurn_GetStagingPathOrNormalPath
! FUNCTION: SHELL32_CDBurn_GetTaskInfo
! FUNCTION: SHELL32_CDBurn_IsBlankDisc
! FUNCTION: SHELL32_CDBurn_IsBlankDisc2
! FUNCTION: SHELL32_CDBurn_IsLiveFS
! FUNCTION: SHELL32_CDBurn_OnDeviceChange
! FUNCTION: SHELL32_CDBurn_OnEject
! FUNCTION: SHELL32_CDBurn_OnMediaChange
! FUNCTION: SHELL32_CDefFolderMenu_Create2
! FUNCTION: SHELL32_CDefFolderMenu_Create2Ex
! FUNCTION: SHELL32_CDefFolderMenu_MergeMenu
! FUNCTION: SHELL32_CDrives_CreateSFVCB
! FUNCTION: SHELL32_CDrivesContextMenu_Create
! FUNCTION: SHELL32_CDrivesDropTarget_Create
! FUNCTION: SHELL32_CFillPropertiesTask_CreateInstance
! FUNCTION: SHELL32_CFSDropTarget_CreateInstance
! FUNCTION: SHELL32_CFSFolderCallback_Create
! FUNCTION: SHELL32_CLibraryDropTarget_CreateInstance
! FUNCTION: SHELL32_CLocationContextMenu_Create
! FUNCTION: SHELL32_CLocationFolderUI_CreateInstance
! FUNCTION: SHELL32_CloseAutoplayPrompt
! FUNCTION: SHELL32_CMountPoint_DoAutorun
! FUNCTION: SHELL32_CMountPoint_DoAutorunPrompt
! FUNCTION: SHELL32_CMountPoint_IsAutoRunDriveAndEnabledByPolicy
! FUNCTION: SHELL32_CMountPoint_ProcessAutoRunFile
! FUNCTION: SHELL32_CMountPoint_WantAutorunUI
! FUNCTION: SHELL32_CMountPoint_WantAutorunUIGetReady
! FUNCTION: SHELL32_CommandLineFromMsiDescriptor
! FUNCTION: SHELL32_CopyFilePlaceholderToNewFile
! FUNCTION: SHELL32_CopySecondaryTiles
! FUNCTION: SHELL32_CPL_CategoryIdArrayFromVariant
! FUNCTION: SHELL32_CPL_IsLegacyCanonicalNameListedUnderKey
! FUNCTION: SHELL32_CPL_ModifyWowDisplayName
! FUNCTION: SHELL32_Create_IEnumUICommand
! FUNCTION: SHELL32_CreateConfirmationInterrupt
! FUNCTION: SHELL32_CreateConflictInterrupt
! FUNCTION: SHELL32_CreateDefaultOperationDataProvider
! FUNCTION: SHELL32_CreateFileFolderContextMenu
! FUNCTION: SHELL32_CreateLinkInfoW
! FUNCTION: SHELL32_CreatePlaceholderFile
! FUNCTION: SHELL32_CreateQosRecorder
! FUNCTION: SHELL32_CreateSharePointView
! FUNCTION: SHELL32_CRecentDocsContextMenu_CreateInstance
! FUNCTION: SHELL32_CSyncRootManager_CreateInstance
! FUNCTION: SHELL32_CTransferConfirmation_CreateInstance
! FUNCTION: SHELL32_DestroyLinkInfo
! FUNCTION: SHELL32_EncryptDirectory
! FUNCTION: SHELL32_EncryptedFileKeyInfo
! FUNCTION: SHELL32_EnumCommonTasks
! FUNCTION: SHELL32_FilePlaceholder_BindToPrimaryStream
! FUNCTION: SHELL32_FilePlaceholder_CreateInstance
! FUNCTION: SHELL32_FreeEncryptedFileKeyInfo
! FUNCTION: SHELL32_GenerateAppID
! FUNCTION: SHELL32_GetAppIDRoot
! FUNCTION: SHELL32_GetCommandProviderForFolderType
! FUNCTION: SHELL32_GetDiskCleanupPath
! FUNCTION: SHELL32_GetDPIAdjustedLogicalSize
! FUNCTION: SHELL32_GetFileNameFromBrowse
! FUNCTION: SHELL32_GetIconOverlayManager
! FUNCTION: SHELL32_GetLinkInfoData
! FUNCTION: SHELL32_GetPlaceholderStatesFromFileAttributesAndReparsePointTag
! FUNCTION: SHELL32_GetRatingBucket
! FUNCTION: SHELL32_GetSkyDriveNetworkStates
! FUNCTION: SHELL32_GetSqmableFileName
! FUNCTION: SHELL32_GetThumbnailAdornerFromFactory
! FUNCTION: SHELL32_GetThumbnailAdornerFromFactory2
! FUNCTION: SHELL32_HandleUnrecognizedFileSystem
! FUNCTION: SHELL32_IconCache_AboutToExtractIcons
! FUNCTION: SHELL32_IconCache_DoneExtractingIcons
! FUNCTION: SHELL32_IconCache_ExpandEnvAndSearchPath
! FUNCTION: SHELL32_IconCache_RememberRecentlyExtractedIconsW
! FUNCTION: SHELL32_IconCacheCreate
! FUNCTION: SHELL32_IconCacheDestroy
! FUNCTION: SHELL32_IconCacheHandleAssociationChanged
! FUNCTION: SHELL32_IconCacheRestore
! FUNCTION: SHELL32_IconOverlayManagerInit
! FUNCTION: SHELL32_IsGetKeyboardLayoutPresent
! FUNCTION: SHELL32_IsSystemUpgradeInProgress
! FUNCTION: SHELL32_IsValidLinkInfo
! FUNCTION: SHELL32_LegacyEnumSpecialTasksByType
! FUNCTION: SHELL32_LegacyEnumTasks
! FUNCTION: SHELL32_LookupBackIconIndex
! FUNCTION: SHELL32_LookupFrontIconIndex
! FUNCTION: SHELL32_NormalizeRating
! FUNCTION: SHELL32_NotifyLinkTrackingServiceOfMove
! FUNCTION: SHELL32_PifMgr_CloseProperties
! FUNCTION: SHELL32_PifMgr_GetProperties
! FUNCTION: SHELL32_PifMgr_OpenProperties
! FUNCTION: SHELL32_PifMgr_SetProperties
! FUNCTION: SHELL32_Printers_CreateBindInfo
! FUNCTION: SHELL32_Printjob_GetPidl
! FUNCTION: SHELL32_PurgeSystemIcon
! FUNCTION: SHELL32_RefreshOverlayImages
! FUNCTION: SHELL32_ResolveLinkInfoW
! FUNCTION: SHELL32_SendToMenu_InvokeTargetedCommand
! FUNCTION: SHELL32_SendToMenu_VerifyTargetedCommand
! FUNCTION: SHELL32_SetPlaceholderReparsePointAttribute
! FUNCTION: SHELL32_SetPlaceholderReparsePointAttribute2
! FUNCTION: SHELL32_SHAddSparseIcon
! FUNCTION: SHELL32_SHCreateByValueOperationInterrupt
! FUNCTION: SHELL32_SHCreateDefaultContextMenu
! FUNCTION: SHELL32_SHCreateLocalServer
! FUNCTION: SHELL32_SHCreateShellFolderView
! FUNCTION: SHELL32_SHDuplicateEncryptionInfoFile
! FUNCTION: SHELL32_SHEncryptFile
! FUNCTION: SHELL32_SHFormatDriveAsync
! FUNCTION: SHELL32_SHGetThreadUndoManager
! FUNCTION: SHELL32_SHGetUserNameW
! FUNCTION: SHELL32_SHIsVirtualDevice
! FUNCTION: SHELL32_SHLaunchPropSheet
! FUNCTION: SHELL32_SHLogILFromFSIL
! FUNCTION: SHELL32_SHOpenWithDialog
! FUNCTION: SHELL32_ShowHideIconOnlyOnDesktop
! FUNCTION: SHELL32_SHStartNetConnectionDialogW
! FUNCTION: SHELL32_SHUICommandFromGUID
! FUNCTION: SHELL32_SimpleRatingToFilterCondition
! FUNCTION: SHELL32_StampIconForFile
! FUNCTION: SHELL32_SuspendUndo
! FUNCTION: SHELL32_TryVirtualDiscImageDriveEject
! FUNCTION: SHELL32_UpdateFilePlaceholderStates
! FUNCTION: SHELL32_VerifySaferTrust
! FUNCTION: Shell_GetCachedImageIndex
! FUNCTION: Shell_GetCachedImageIndexA
! FUNCTION: Shell_GetCachedImageIndexW
! FUNCTION: Shell_GetImageLists
! FUNCTION: Shell_MergeMenus
! FUNCTION: Shell_NotifyIconA
! FUNCTION: Shell_NotifyIconGetRect
! FUNCTION: Shell_NotifyIconW
! FUNCTION: ShellAboutA
! FUNCTION: ShellAboutW
! FUNCTION: ShellExec_RunDLL
! FUNCTION: ShellExec_RunDLLA
! FUNCTION: ShellExec_RunDLLW
! FUNCTION: ShellExecuteA
! FUNCTION: ShellExecuteEx
! FUNCTION: ShellExecuteExA
! FUNCTION: ShellExecuteExW
! FUNCTION: ShellHookProc
! FUNCTION: ShellMessageBoxA
! FUNCTION: ShellMessageBoxW
! FUNCTION: SHEmptyRecycleBinA
! FUNCTION: SHEmptyRecycleBinW
! FUNCTION: SHEnableServiceObject
! FUNCTION: SHEnumerateUnreadMailAccountsW
! FUNCTION: SheSetCurDrive
! FUNCTION: SHEvaluateSystemCommandTemplate
! FUNCTION: SHExtractIconsW
! FUNCTION: SHFileOperation
! FUNCTION: SHFileOperationA
! FUNCTION: SHFileOperationW
! FUNCTION: SHFind_InitMenuPopup
! FUNCTION: SHFindFiles
! FUNCTION: SHFlushSFCache
! FUNCTION: SHFormatDrive
! FUNCTION: SHFree
! FUNCTION: SHFreeNameMappings
! FUNCTION: SHGetAttributesFromDataObject
! FUNCTION: SHGetDataFromIDListA
! FUNCTION: SHGetDataFromIDListW
! FUNCTION: SHGetDiskFreeSpaceA
! FUNCTION: SHGetDiskFreeSpaceExA
! FUNCTION: SHGetDiskFreeSpaceExW
! FUNCTION: SHGetDriveMedia
! FUNCTION: SHGetFileInfo
! FUNCTION: SHGetFileInfoA
! FUNCTION: SHGetFolderLocation
! FUNCTION: SHGetFolderPathA
! FUNCTION: SHGetFolderPathAndSubDirA
! FUNCTION: SHGetFolderPathAndSubDirW
! FUNCTION: SHGetFolderPathEx
! FUNCTION: SHGetIconOverlayIndexA
! FUNCTION: SHGetIconOverlayIndexW
! FUNCTION: SHGetIDListFromObject
! FUNCTION: SHGetImageList
! FUNCTION: SHGetInstanceExplorer
! FUNCTION: SHGetItemFromDataObject
! FUNCTION: SHGetItemFromObject
! FUNCTION: SHGetKnownFolderIDList
! FUNCTION: SHGetKnownFolderItem
! FUNCTION: SHGetKnownFolderPath
! FUNCTION: SHGetLocalizedName
! FUNCTION: SHGetMalloc
! FUNCTION: SHGetNameFromIDList
! FUNCTION: SHGetNewLinkInfo
! FUNCTION: SHGetNewLinkInfoA
! FUNCTION: SHGetNewLinkInfoW
! FUNCTION: SHGetPathFromIDList
! FUNCTION: SHGetPathFromIDListA
! FUNCTION: SHGetPathFromIDListEx
! FUNCTION: SHGetPathFromIDListW
! FUNCTION: SHGetPropertyStoreForWindow
! FUNCTION: SHGetPropertyStoreFromIDList
! FUNCTION: SHGetPropertyStoreFromParsingName
! FUNCTION: SHGetRealIDL
! FUNCTION: SHGetSetFolderCustomSettings
! FUNCTION: SHGetSetSettings
! FUNCTION: SHGetSettings
! FUNCTION: SHGetSpecialFolderLocation
! FUNCTION: SHGetSpecialFolderPathA
! FUNCTION: SHGetSpecialFolderPathW
! FUNCTION: SHGetStockIconInfo
! FUNCTION: SHGetTemporaryPropertyForItem
! FUNCTION: SHGetUnreadMailCountW
! FUNCTION: SHHandleUpdateImage
! FUNCTION: SHHelpShortcuts_RunDLL
! FUNCTION: SHHelpShortcuts_RunDLLA
! FUNCTION: SHHelpShortcuts_RunDLLW
! FUNCTION: SHILCreateFromPath
! FUNCTION: SHInvokePrinterCommandA
! FUNCTION: SHInvokePrinterCommandW
! FUNCTION: SHIsFileAvailableOffline
! FUNCTION: SHLimitInputEdit
! FUNCTION: SHLoadInProc
! FUNCTION: SHLoadNonloadedIconOverlayIdentifiers
! FUNCTION: SHMapPIDLToSystemImageListIndex
! FUNCTION: SHMultiFileProperties
! FUNCTION: SHObjectProperties
! FUNCTION: SHOpenFolderAndSelectItems
! FUNCTION: SHOpenPropSheetW
! FUNCTION: SHOpenWithDialog
! FUNCTION: SHParseDisplayName
! FUNCTION: SHPathPrepareForWriteA
! FUNCTION: SHPathPrepareForWriteW
! FUNCTION: SHPropStgCreate
! FUNCTION: SHPropStgReadMultiple
! FUNCTION: SHPropStgWriteMultiple
! FUNCTION: SHQueryRecycleBinA
! FUNCTION: SHQueryRecycleBinW
! FUNCTION: SHQueryUserNotificationState
! FUNCTION: SHRemoveLocalizedName
! FUNCTION: SHReplaceFromPropSheetExtArray
! FUNCTION: SHResolveLibrary
! FUNCTION: SHRestricted
! FUNCTION: SHSetDefaultProperties
! FUNCTION: SHSetFolderPathA
! FUNCTION: SHSetFolderPathW
! FUNCTION: SHSetInstanceExplorer
! FUNCTION: SHSetKnownFolderPath
! FUNCTION: SHSetLocalizedName
! FUNCTION: SHSetTemporaryPropertyForItem
! FUNCTION: SHSetUnreadMailCountW
! FUNCTION: SHShellFolderView_Message
! FUNCTION: SHShowManageLibraryUI
! FUNCTION: SHSimpleIDListFromPath
! FUNCTION: SHStartNetConnectionDialogW
! FUNCTION: SHTestTokenMembership
! FUNCTION: SHUpdateImageA
! FUNCTION: SHUpdateImageW
! FUNCTION: SHUpdateRecycleBinIcon
! FUNCTION: SHValidateUNC
! FUNCTION: SignalFileOpen
! FUNCTION: StgMakeUniqueName
! FUNCTION: StrChrA
! FUNCTION: StrChrIA
! FUNCTION: StrChrIW
! FUNCTION: StrChrW
! FUNCTION: StrCmpNA
! FUNCTION: StrCmpNIA
! FUNCTION: StrCmpNIW
! FUNCTION: StrCmpNW
! FUNCTION: StrNCmpA
! FUNCTION: StrNCmpIA
! FUNCTION: StrNCmpIW
! FUNCTION: StrNCmpW
! FUNCTION: StrRChrA
! FUNCTION: StrRChrIA
! FUNCTION: StrRChrIW
! FUNCTION: StrRChrW
! FUNCTION: StrRStrA
! FUNCTION: StrRStrIA
! FUNCTION: StrRStrIW
! FUNCTION: StrRStrW
! FUNCTION: StrStrA
! FUNCTION: StrStrIA
! FUNCTION: StrStrIW
! FUNCTION: StrStrW
! FUNCTION: UsersLibrariesFolderUI_CreateInstance
! FUNCTION: WaitForExplorerRestartW
! FUNCTION: Win32DeleteFile
! FUNCTION: WOWShellExecute
! FUNCTION: WriteCabinetState
