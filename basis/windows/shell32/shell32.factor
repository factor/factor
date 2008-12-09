USING: alien alien.c-types alien.strings alien.syntax combinators
kernel windows windows.user32 windows.ole32
windows.com windows.com.syntax io.files io.encodings.utf16n ;
IN: windows.shell32

: CSIDL_DESKTOP HEX: 00 ; inline
: CSIDL_INTERNET HEX: 01 ; inline
: CSIDL_PROGRAMS HEX: 02 ; inline
: CSIDL_CONTROLS HEX: 03 ; inline
: CSIDL_PRINTERS HEX: 04 ; inline
: CSIDL_PERSONAL HEX: 05 ; inline
: CSIDL_FAVORITES HEX: 06 ; inline
: CSIDL_STARTUP HEX: 07 ; inline
: CSIDL_RECENT HEX: 08 ; inline
: CSIDL_SENDTO HEX: 09 ; inline
: CSIDL_BITBUCKET HEX: 0a ; inline
: CSIDL_STARTMENU HEX: 0b ; inline
: CSIDL_MYDOCUMENTS HEX: 0c ; inline
: CSIDL_MYMUSIC HEX: 0d ; inline
: CSIDL_MYVIDEO HEX: 0e ; inline
: CSIDL_DESKTOPDIRECTORY HEX: 10 ; inline
: CSIDL_DRIVES HEX: 11 ; inline
: CSIDL_NETWORK HEX: 12 ; inline
: CSIDL_NETHOOD HEX: 13 ; inline
: CSIDL_FONTS HEX: 14 ; inline
: CSIDL_TEMPLATES HEX: 15 ; inline
: CSIDL_COMMON_STARTMENU HEX: 16 ; inline
: CSIDL_COMMON_PROGRAMS HEX: 17 ; inline
: CSIDL_COMMON_STARTUP HEX: 18 ; inline
: CSIDL_COMMON_DESKTOPDIRECTORY HEX: 19 ; inline
: CSIDL_APPDATA HEX: 1a ; inline
: CSIDL_PRINTHOOD HEX: 1b ; inline
: CSIDL_LOCAL_APPDATA HEX: 1c ; inline
: CSIDL_ALTSTARTUP HEX: 1d ; inline
: CSIDL_COMMON_ALTSTARTUP HEX: 1e ; inline
: CSIDL_COMMON_FAVORITES HEX: 1f ; inline
: CSIDL_INTERNET_CACHE HEX: 20 ; inline
: CSIDL_COOKIES HEX: 21 ; inline
: CSIDL_HISTORY HEX: 22 ; inline
: CSIDL_COMMON_APPDATA HEX: 23 ; inline
: CSIDL_WINDOWS HEX: 24 ; inline
: CSIDL_SYSTEM HEX: 25 ; inline
: CSIDL_PROGRAM_FILES HEX: 26 ; inline
: CSIDL_MYPICTURES HEX: 27 ; inline
: CSIDL_PROFILE HEX: 28 ; inline
: CSIDL_SYSTEMX86 HEX: 29 ; inline
: CSIDL_PROGRAM_FILESX86 HEX: 2a ; inline
: CSIDL_PROGRAM_FILES_COMMON HEX: 2b ; inline
: CSIDL_PROGRAM_FILES_COMMONX86 HEX: 2c ; inline
: CSIDL_COMMON_TEMPLATES HEX: 2d ; inline
: CSIDL_COMMON_DOCUMENTS HEX: 2e ; inline
: CSIDL_COMMON_ADMINTOOLS HEX: 2f ; inline
: CSIDL_ADMINTOOLS HEX: 30 ; inline
: CSIDL_CONNECTIONS HEX: 31 ; inline
: CSIDL_COMMON_MUSIC HEX: 35 ; inline
: CSIDL_COMMON_PICTURES HEX: 36 ; inline
: CSIDL_COMMON_VIDEO HEX: 37 ; inline
: CSIDL_RESOURCES HEX: 38 ; inline
: CSIDL_RESOURCES_LOCALIZED HEX: 39 ; inline
: CSIDL_COMMON_OEM_LINKS HEX: 3a ; inline
: CSIDL_CDBURN_AREA HEX: 3b ; inline
: CSIDL_COMPUTERSNEARME HEX: 3d ; inline
: CSIDL_PROFILES HEX: 3e ; inline
: CSIDL_FOLDER_MASK HEX: ff ; inline
: CSIDL_FLAG_PER_USER_INIT HEX: 800 ; inline
: CSIDL_FLAG_NO_ALIAS HEX: 1000 ; inline
: CSIDL_FLAG_DONT_VERIFY HEX: 4000 ; inline
: CSIDL_FLAG_CREATE HEX: 8000 ; inline
: CSIDL_FLAG_MASK HEX: ff00 ; inline


: ERROR_FILE_NOT_FOUND 2 ; inline

: SHGFP_TYPE_CURRENT 0 ; inline
: SHGFP_TYPE_DEFAULT 1 ; inline

LIBRARY: shell32

FUNCTION: HRESULT SHGetFolderPathW ( HWND hwndOwner, int nFolder, HANDLE hToken, DWORD dwReserved, LPTSTR pszPath ) ;
: SHGetFolderPath SHGetFolderPathW ; inline

FUNCTION: HINSTANCE ShellExecuteW ( HWND hwnd, LPCTSTR lpOperation, LPCTSTR lpFile, LPCTSTR lpParameters, LPCTSTR lpDirectory, INT nShowCmd ) ;
: ShellExecute ShellExecuteW ; inline

: open-in-explorer ( dir -- )
    f "open" rot (normalize-path) f f SW_SHOWNORMAL ShellExecute drop ;

: shell32-error ( n -- )
    ole32-error ; inline

: shell32-directory ( n -- str )
    f swap f SHGFP_TYPE_DEFAULT
    MAX_UNICODE_PATH "ushort" <c-array>
    [ SHGetFolderPath shell32-error ] keep utf16n alien>string ;

: desktop ( -- str )
    CSIDL_DESKTOPDIRECTORY shell32-directory ;

: my-documents ( -- str )
    CSIDL_PERSONAL shell32-directory ;

: application-data ( -- str )
    CSIDL_APPDATA shell32-directory ;

: windows ( -- str )
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

: SHCONTF_FOLDERS 32 ; inline
: SHCONTF_NONFOLDERS 64 ; inline
: SHCONTF_INCLUDEHIDDEN 128 ; inline
: SHCONTF_INIT_ON_FIRST_NEXT 256 ; inline
: SHCONTF_NETPRINTERSRCH 512 ; inline
: SHCONTF_SHAREABLE 1024 ; inline
: SHCONTF_STORAGE 2048 ; inline

TYPEDEF: DWORD SHCONTF

: SHGDN_NORMAL 0 ; inline
: SHGDN_INFOLDER 1 ; inline
: SHGDN_FOREDITING HEX: 1000 ; inline
: SHGDN_INCLUDE_NONFILESYS HEX: 2000 ; inline
: SHGDN_FORADDRESSBAR HEX: 4000 ; inline
: SHGDN_FORPARSING HEX: 8000 ; inline

TYPEDEF: DWORD SHGDNF

: SFGAO_CANCOPY           DROPEFFECT_COPY ; inline
: SFGAO_CANMOVE           DROPEFFECT_MOVE ; inline
: SFGAO_CANLINK           DROPEFFECT_LINK ; inline
: SFGAO_CANRENAME         HEX: 00000010 ; inline
: SFGAO_CANDELETE         HEX: 00000020 ; inline
: SFGAO_HASPROPSHEET      HEX: 00000040 ; inline
: SFGAO_DROPTARGET        HEX: 00000100 ; inline
: SFGAO_CAPABILITYMASK    HEX: 00000177 ; inline
: SFGAO_LINK              HEX: 00010000 ; inline
: SFGAO_SHARE             HEX: 00020000 ; inline
: SFGAO_READONLY          HEX: 00040000 ; inline
: SFGAO_GHOSTED           HEX: 00080000 ; inline
: SFGAO_HIDDEN            HEX: 00080000 ; inline
: SFGAO_DISPLAYATTRMASK   HEX: 000F0000 ; inline
: SFGAO_FILESYSANCESTOR   HEX: 10000000 ; inline
: SFGAO_FOLDER            HEX: 20000000 ; inline
: SFGAO_FILESYSTEM        HEX: 40000000 ; inline
: SFGAO_HASSUBFOLDER      HEX: 80000000 ; inline
: SFGAO_CONTENTSMASK      HEX: 80000000 ; inline
: SFGAO_VALIDATE          HEX: 01000000 ; inline
: SFGAO_REMOVABLE         HEX: 02000000 ; inline
: SFGAO_COMPRESSED        HEX: 04000000 ; inline
: SFGAO_BROWSABLE         HEX: 08000000 ; inline
: SFGAO_NONENUMERATED     HEX: 00100000 ; inline
: SFGAO_NEWCONTENT        HEX: 00200000 ; inline

TYPEDEF: ULONG SFGAOF

C-STRUCT: DROPFILES
    { "DWORD" "pFiles" }
    { "POINT" "pt" }
    { "BOOL" "fNC" }
    { "BOOL" "fWide" } ;
TYPEDEF: DROPFILES* LPDROPFILES
TYPEDEF: DROPFILES* LPCDROPFILES
TYPEDEF: HANDLE HDROP

C-STRUCT: SHITEMID
    { "USHORT" "cb" }
    { "BYTE[1]" "abID" } ;
TYPEDEF: SHITEMID* LPSHITEMID
TYPEDEF: SHITEMID* LPCSHITEMID

C-STRUCT: ITEMIDLIST
    { "SHITEMID" "mkid" } ;
TYPEDEF: ITEMIDLIST* LPITEMIDLIST
TYPEDEF: ITEMIDLIST* LPCITEMIDLIST
TYPEDEF: ITEMIDLIST ITEMID_CHILD
TYPEDEF: ITEMID_CHILD* PITEMID_CHILD
TYPEDEF: ITEMID_CHILD* PCUITEMID_CHILD

: STRRET_WSTR 0 ; inline
: STRRET_OFFSET 1 ; inline
: STRRET_CSTR 2 ; inline

C-UNION: STRRET-union "LPWSTR" "LPSTR" "UINT" "char[260]" ;
C-STRUCT: STRRET
    { "int" "uType" }
    { "STRRET-union" "union" } ;

COM-INTERFACE: IEnumIDList IUnknown {000214F2-0000-0000-C000-000000000046}
    HRESULT Next ( ULONG celt, LPITEMIDLIST* rgelt, ULONG* pceltFetched )
    HRESULT Skip ( ULONG celt )
    HRESULT Reset ( )
    HRESULT Clone ( IEnumIDList** ppenum ) ;

COM-INTERFACE: IShellFolder IUnknown {000214E6-0000-0000-C000-000000000046}
    HRESULT ParseDisplayName ( HWND hwndOwner, void* pbcReserved, LPOLESTR lpszDisplayName, ULONG* pchEaten, LPITEMIDLIST* ppidl, ULONG* pdwAttributes )
    HRESULT EnumObjects ( HWND hwndOwner, SHCONTF grfFlags, IEnumIDList** ppenumIDList )
    HRESULT BindToObject ( LPCITEMIDLIST pidl, void* pbcReserved, REFGUID riid, void** ppvOut )
    HRESULT BindToStorage ( LPCITEMIDLIST pidl, void* pbcReserved, REFGUID riid, void** ppvObj )
    HRESULT CompareIDs ( LPARAM lParam, LPCITEMIDLIST pidl1, LPCITEMIDLIST pidl2 )
    HRESULT CreateViewObject ( HWND hwndOwner, REFGUID riid, void** ppvOut )
    HRESULT GetAttributesOf ( UINT cidl, LPCITEMIDLIST* apidl, SFGAOF* rgfInOut )
    HRESULT GetUIObjectOf ( HWND hwndOwner, UINT cidl, LPCITEMIDLIST* apidl, REFGUID riid, UINT* prgfInOut, void** ppvOut )
    HRESULT GetDisplayNameOf ( LPCITEMIDLIST pidl, SHGDNF uFlags, STRRET* lpName )
    HRESULT SetNameOf ( HWND hwnd, LPCITEMIDLIST pidl, LPCOLESTR lpszName, SHGDNF uFlags, LPITEMIDLIST* ppidlOut ) ;

FUNCTION: HRESULT SHGetDesktopFolder ( IShellFolder** ppshf ) ;

FUNCTION: UINT DragQueryFileW ( HDROP hDrop, UINT iFile, LPWSTR lpszFile, UINT cch ) ;
: DragQueryFile DragQueryFileW ; inline

