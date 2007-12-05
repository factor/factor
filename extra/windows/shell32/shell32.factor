USING: alien alien.c-types alien.syntax combinators
kernel windows ;
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

: SW_HIDE            0 ; inline
: SW_SHOWNORMAL      1 ; inline
: SW_NORMAL          1 ; inline
: SW_SHOWMINIMIZED   2 ; inline
: SW_SHOWMAXIMIZED   3 ; inline
: SW_MAXIMIZE        3 ; inline
: SW_SHOWNOACTIVATE  4 ; inline
: SW_SHOW            5 ; inline
: SW_MINIMIZE        6 ; inline
: SW_SHOWMINNOACTIVE 7 ; inline
: SW_SHOWNA          8 ; inline
: SW_RESTORE         9 ; inline
: SW_SHOWDEFAULT     10 ; inline
: SW_MAX          10 ; inline

: S_OK 0 ; inline
: S_FALSE 1 ; inline
: E_FAIL HEX: 80004005 ; inline
: E_INVALIDARG HEX: 80070057 ; inline
: ERROR_FILE_NOT_FOUND 2 ; inline

: SHGFP_TYPE_CURRENT 0 ; inline
: SHGFP_TYPE_DEFAULT 1 ; inline

LIBRARY: shell32

TYPEDEF: void* PIDLIST_ABSOLUTE
FUNCTION: HRESULT SHGetFolderPathW ( HWND hwndOwner, int nFolder, HANDLE hToken, DWORD dwReserved, LPTSTR pszPath ) ;
! SHGetSpecialFolderLocation
! SHGetSpecialFolderPath
FUNCTION: HINSTANCE ShellExecuteW ( HWND hwnd, LPCTSTR lpOperation, LPCTSTR lpFile, LPCTSTR lpParameters, LPCTSTR lpDirectory, INT nShowCmd ) ;
: ShellExecute ShellExecuteW ; inline

: open-in-explorer ( dir -- )
    f "open" rot f f SW_SHOWNORMAL ShellExecute drop ;

: SHGetFolderPath SHGetFolderPathW ; inline

: shell32-error ( n -- )
    dup S_OK = [
        drop
    ] [
        {
            ! { ERROR_FILE_NOT_FOUND [ "file not found" throw ] }
            ! { E_INVALIDARG [ "invalid arg" throw ] }
            [ (win32-error-string) throw ]
        } case
    ] if ;

: shell32-directory ( n -- str )
    f swap f SHGFP_TYPE_DEFAULT
    MAX_UNICODE_PATH "ushort" <c-array>
    [ SHGetFolderPath shell32-error ] keep alien>u16-string ;

: desktop ( -- str )
    CSIDL_DESKTOPDIRECTORY shell32-directory ;

: my-documents ( -- str )
    CSIDL_PERSONAL shell32-directory ;

: application-data ( -- str )
    CSIDL_APPDATA shell32-directory ;

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
