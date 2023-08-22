! Copyright (C) 2006, 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.strings
alien.syntax assocs classes.struct io.backend kernel literals
math sequences vocabs windows windows.com windows.com.syntax
windows.kernel32 windows.messages windows.ole32 windows.types ;
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

! GUID: 905e63b6-c1bf-494e-b29c-65b732d3d21a 0 f 0 wchar_t <ref> [ SHGetKnownFolderPath ] keep
! swap [ [ void* deref alien>native-string ] [ ] [ f ] if-zero

TYPEDEF: wchar_t* PWSTR
STRUCT: KNOWNFOLDERID
    { guid GUID } ;
TYPEDEF: KNOWNFOLDERID* REFKNOWNFOLDERID
FUNCTION: HRESULT SHGetKnownFolderPath ( REFKNOWNFOLDERID rfid, DWORD dwFlags, HANDLE hToken, PWSTR* ppszPath )

: get-known-folder-path ( guid -- str )
    0 f 0 wchar_t <ref> [ SHGetKnownFolderPath ] keep
    swap
    [ void* deref [ alien>native-string ] [ CoTaskMemFree ] bi ]
    [ 2drop f ] if-zero ;

CONSTANT: FOLDERID_AccountPictures GUID: 008ca0b1-55b4-4c56-b8a8-4de4b299d3be
CONSTANT: FOLDERID_AddNewPrograms GUID: de61d971-5ebc-4f02-a3a9-6c82895e5c04
CONSTANT: FOLDERID_AdminTools GUID: 724EF170-A42D-4FEF-9F26-B60E846FBA4F
CONSTANT: FOLDERID_ApplicationShortcuts GUID: A3918781-E5F2-4890-B3D9-A7E54332328C
CONSTANT: FOLDERID_AppsFolder GUID: 905e63b6-c1bf-494e-b29c-65b732d3d21a
CONSTANT: FOLDERID_AppUpdates GUID: a305ce99-f527-492b-8b1a-7e76fa98d6e4
CONSTANT: FOLDERID_CameraRoll GUID: AB5FB87B-7CE2-4F83-915D-550846C9537B
CONSTANT: FOLDERID_CDBurning GUID: 9E52AB10-F80D-49DF-ACB8-4330F5687855
CONSTANT: FOLDERID_CommonAdminTools GUID: D0384E7D-BAC3-4797-8F14-CBA229B392B5
CONSTANT: FOLDERID_CommonOEMLinks GUID: C1BAE2D0-10DF-4334-BEDD-7AA20B227A9D
CONSTANT: FOLDERID_CommonPrograms GUID: F7F1ED05-9F6D-47A2-AAAE-29D317C6F066
CONSTANT: FOLDERID_CommonStartMenu GUID: A4115719-D62E-491D-AA7C-E74B8BE3B067
CONSTANT: FOLDERID_CommonStartup GUID: 82A5EA35-D9CD-47C5-9629-E15D2F714E6E
CONSTANT: FOLDERID_CommonTemplates GUID: B94237E7-57AC-4347-9151-B08C6C32D1F7
CONSTANT: FOLDERID_ComputerFolder GUID: 0AC0837C-BBF8-452A-850D-79D08E667CA7
CONSTANT: FOLDERID_ConflictFolder GUID: 4bfefb45-347d-4006-a5be-ac0cb0567192
CONSTANT: FOLDERID_ConnectionsFolder GUID: 6F0CD92B-2E97-45D1-88FF-B0D186B8DEDD
CONSTANT: FOLDERID_Contacts GUID: 56784854-C6CB-462b-8169-88E350ACB882
CONSTANT: FOLDERID_ControlPanelFolder GUID: 82A74AEB-AEB4-465C-A014-D097EE346D63
CONSTANT: FOLDERID_Cookies GUID: 2B0F765D-C0E9-4171-908E-08A611B84FF6
CONSTANT: FOLDERID_Desktop GUID: B4BFCC3A-DB2C-424C-B029-7FE99A87C641
CONSTANT: FOLDERID_DeviceMetadataStore GUID: 5ce4a5e9-e4eb-479d-b89f-130c02886155
CONSTANT: FOLDERID_DocumentsLibrary GUID: 7b0db17d-9cd2-4a93-9733-46cc89022e7c
CONSTANT: FOLDERID_Downloads GUID: 374de290-123f-4565-9164-39c4925e467b
CONSTANT: FOLDERID_Favorites GUID: 1777f761-68ad-4d8a-87bd-30b759fa33dd
CONSTANT: FOLDERID_Fonts GUID: fd228cb7-ae11-4ae3-864c-16f3910ab8fe
CONSTANT: FOLDERID_GameTasks GUID: 054fae61-4dd8-4787-80b6-090220c4b700
CONSTANT: FOLDERID_Games GUID: d3e34b21-9d75-101a-8c3d-00aa001a1652
CONSTANT: FOLDERID_History GUID: d9dc8a3b-b784-432e-a781-5a1130a75963
CONSTANT: FOLDERID_HomeGroup GUID: b4bfcc3a-db2c-424c-b029-7fe99a87c641
CONSTANT: FOLDERID_HomeGroupCurrentUser GUID: 9b74b6a3-0dfd-4f11-9e78-5f7800f2e772
CONSTANT: FOLDERID_ImplicitAppShortcuts GUID: bcb5256f-79f6-4cee-b725-dc34e402fd46
CONSTANT: FOLDERID_InternetCache GUID: 352481e8-33be-4251-ba85-6007caedcf9d
CONSTANT: FOLDERID_InternetFolder GUID: 4d9f7874-4e0c-4904-967b-40b0d20c3e4b
CONSTANT: FOLDERID_Libraries GUID: 1b3ea5dc-b587-4786-b4ef-bd1dc332aeae
CONSTANT: FOLDERID_Links GUID: bfb9d5e0-c6a9-404c-b2b2-ae6db6af4968
CONSTANT: FOLDERID_LocalAppData GUID: f1b32785-6fba-4fcf-9d55-7b8e7f157091
CONSTANT: FOLDERID_LocalAppDataLow GUID: a520a1a4-1780-4ff6-bd18-167343c5af16
CONSTANT: FOLDERID_LocalizedResourcesDir GUID: 2a00375e-224c-49de-b8d1-440df7ef3ddc
CONSTANT: FOLDERID_MusicLibrary GUID: 2112ab0a-c86a-4ffe-a368-0de96e47012e
CONSTANT: FOLDERID_MusicGUID_Playlists GUID: 5f4eab9a-6833-4f61-899d-31cf46979d49
CONSTANT: FOLDERID_NetHood GUID: c5abbf53-e17f-4121-8900-86626fc2c973
CONSTANT: FOLDERID_NetworkFolder GUID: D20BEEC4-5CA8-4905-AE3B-BF251EA09B53
CONSTANT: FOLDERID_OriginalImages GUID: 2C36C0AA-5812-4b87-BFD0-4CD0DFB19B39
CONSTANT: FOLDERID_PhotoAlbums GUID: 69D2CF90-FC33-4FB7-9A0C-EBB0F0FCB43C
CONSTANT: FOLDERID_PicturesLibrary GUID: A990AE9F-A03B-4e80-94BC-9912D7504104
CONSTANT: FOLDERID_Playlists GUID: DE92C1C7-837F-4F69-A3BB-86E631204A23
CONSTANT: FOLDERID_PrintersFolder GUID: 76FC4E2D-D6AD-4519-A663-37BD56068185
CONSTANT: FOLDERID_PrintHood GUID: 9274BD8D-CFD1-41c3-B35E-B13F55A758F4
CONSTANT: FOLDERID_Profile GUID: 5E6C858F-0E22-4760-9AFE-EA3317B67173
CONSTANT: FOLDERID_ProgramData GUID: 62AB5D82-FDC1-4dc3-A9DD-070D1D495D97
CONSTANT: FOLDERID_ProgramFiles GUID: 905E63B6-C1BF-494E-B29C-65B732D3D21A
CONSTANT: FOLDERID_ProgramFilesCommon GUID: F7F1ED05-9F6D-47A2-AAAE-29D317C6F066
CONSTANT: FOLDERID_ProgramFilesCommonX64 GUID: 6365D5A7-0F0D-45E5-87F6-0DA56B6A4F7D
CONSTANT: FOLDERID_ProgramFilesCommonX86 GUID: DE974D24-D9C6-4D3E-BF91-F4455120B917
CONSTANT: FOLDERID_ProgramFilesX64 GUID: 6D809377-6AF0-444B-8957-A3773F02200E
CONSTANT: FOLDERID_ProgramFilesX86 GUID: 7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E
CONSTANT: FOLDERID_ProgramFilesX86_Common GUID: F7C73F05-CDFA-4831-9F2F-7AFA717B99E2
CONSTANT: FOLDERID_Programs GUID: A77F5D77-2E2B-44C3-A6A2-ABA601054A51
CONSTANT: FOLDERID_Public GUID: DFDF76A2-C82A-4D63-906A-5644AC457385
CONSTANT: FOLDERID_PublicDesktop GUID: C4AA340D-F20F-4863-AFEF-F87EF2E6BA25
CONSTANT: FOLDERID_PublicDocuments GUID: ED4824AF-DCE4-45A8-81E2-FC7965083634
CONSTANT: FOLDERID_PublicDownloads GUID: 3D644C9B-1FB8-4f30-9B45-F670235F79C0
CONSTANT: FOLDERID_PublicGameTasks GUID: debf2536-e1a8-4c59-b6a2-414586476aea
CONSTANT: FOLDERID_PublicLibraries GUID: 48daf80b-e6cf-4f4e-b800-0e69d84ee384
CONSTANT: FOLDERID_PublicMusic GUID: dfdf76a2-c82a-4d63-906a-5644ac457385
CONSTANT: FOLDERID_PublicPictures GUID: b6ebfb86-6907-413c-9af7-4fc2abf07cc5
CONSTANT: FOLDERID_PublicRingtones GUID: e555ab60-153b-4d17-9f04-a5fe99fc15ec
CONSTANT: FOLDERID_PublicUserTiles GUID: 0482af6c-08f1-4c34-8c90-e17ec98b1e17
CONSTANT: FOLDERID_PublicVideos GUID: 2400183a-6185-49fb-a2d8-4a392a602ba3
CONSTANT: FOLDERID_QuickLaunch GUID: 52a4f021-7b75-48a9-9f6b-4b87a210bc8f
CONSTANT: FOLDERID_RecordedTVLibrary GUID: 1a6fdba2-f42d-4358-a798-b74d745926c5
CONSTANT: FOLDERID_Ringtones GUID: c870044b-f49e-4126-a9c3-b52a1ff411e8
CONSTANT: FOLDERID_RoamingAppData GUID: 3eb685db-65f9-4cf6-a03a-e3ef65729f3d
CONSTANT: FOLDERID_RoamingTiles GUID: f3ce0f7c-4901-4acc-8648-d5d44b04ef8f
CONSTANT: FOLDERID_SampleMusic GUID: b250c668-f57d-4ee1-a63c-290ee7d1aa1f
CONSTANT: FOLDERID_SamplePictures GUID: c4900540-2379-4c75-844b-64e6faf8716b
CONSTANT: FOLDERID_SamplePlaylists GUID: 15ca69b3-30ee-49c1-ace1-6b5ec372afb5
CONSTANT: FOLDERID_SampleVideos GUID: 859edda-0a8d-4cfe-a27a-3e7a2077b0ad
CONSTANT: FOLDERID_SavedGames GUID: 4c5c32ff-bb9d-43b0-b5b4-2d72e54eaaa4
CONSTANT: FOLDERID_SavedSearches GUID: 7d1d3a04-debb-4115-95cf-2f29da2920da
CONSTANT: FOLDERID_Screenshots GUID: b7bede81-df94-4682-a7d8-57a52620b86f
CONSTANT: FOLDERID_SearchHistory GUID: 0d4c3db6-03a3-462f-a0e6-08924c41b5d4
CONSTANT: FOLDERID_SearchHome GUID: 190337d1-b8ca-4121-a639-6d472d1972a
CONSTANT: FOLDERID_SendTo GUID: 8983036C-27C0-404B-8F08-102D10DCFD74
CONSTANT: FOLDERID_Startup GUID: B97D20BB-F46A-4C97-BA10-5E3608430854
CONSTANT: FOLDERID_SyncManagerFolder GUID: 43668BF8-C14E-49B2-97C9-747784D784B7
CONSTANT: FOLDERID_SyncResultsFolder GUID: 289a9a43-be44-4057-a41b-587a76d7e7f9
CONSTANT: FOLDERID_SyncSetupFolder GUID: 0F214138-B1D3-4a90-BBA9-27CBC0C5389A
CONSTANT: FOLDERID_System GUID: 1AC14E77-02E7-4E5D-B744-2EB1AE5198B7
CONSTANT: FOLDERID_SystemX86 GUID: 7B396E54-9EC5-4300-BE0A-2482EBAE1A26
CONSTANT: FOLDERID_Templates GUID: A63293E8-664E-48DB-A079-DF759E0509F7
CONSTANT: FOLDERID_UserPinned GUID: 9E3995AB-1F9C-4F13-B827-48B24B6C7174
CONSTANT: FOLDERID_UserProfiles GUID: 0762D272-C50A-4BB0-A382-697DCD729B80
CONSTANT: FOLDERID_UserProgramFiles GUID: 5cd7aee2-2219-4a67-b85d-6c9ce15660cb
CONSTANT: FOLDERID_UserProgramFilesCommon GUID: Bcbd3057-ca5c-4622-b42d-bc56db0ae516
CONSTANT: FOLDERID_UsersFiles GUID: F3CE0F7C-4901-4ACC-8648-D5D44B04EF8F
CONSTANT: FOLDERID_UsersLibraries GUID: A302545D-DEFF-464b-ABE8-61C8648D939B
CONSTANT: FOLDERID_Videos GUID: 18989B1D-99B5-455B-841C-AB7C74E4DDFC
CONSTANT: FOLDERID_Windows GUID: F38BF404-1D43-42F2-9305-67DE0B28FC23

: all-folderid-dirs ( -- seq )
    all-words [ name>> "FOLDERID_" head? ] filter
    [ execute( -- obj ) get-known-folder-path ] zip-with ;



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
