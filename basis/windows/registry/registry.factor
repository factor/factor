! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types byte-arrays kernel locals sequences
windows.advapi32 windows.errors math windows
windows.kernel32 windows.time accessors alien.data
nested-comments windows.types classes.struct continuations ;
IN: windows.registry

ERROR: open-key-failed key subkey mode error-string ;
ERROR: create-key-failed hKey lpSubKey lpClass dwOptions
samDesired lpSecurityAttributes phkResult lpdwDisposition ;

CONSTANT: registry-value-max-length 16384

:: open-key ( key subkey mode -- hkey )
    key subkey 0 mode HKEY <c-object>
    [
        RegOpenKeyEx dup ERROR_SUCCESS = [
            drop
        ] [
            [ key subkey mode ] dip n>win32-error-string
            open-key-failed
        ] if
    ] keep *uint ;

:: create-key* ( hKey lpSubKey lpClass dwOptions samDesired lpSecurityAttributes -- hkey new? )
    hKey lpSubKey 0 lpClass dwOptions samDesired lpSecurityAttributes
    HKEY <c-object>
    DWORD <c-object>
    f :> ret!
    [ RegCreateKeyEx ret! ] 2keep
    [ *uint ]
    [ *uint REG_CREATED_NEW_KEY = ] bi*
    ret ERROR_SUCCESS = [
        [
            hKey lpSubKey 0 lpClass dwOptions samDesired
            lpSecurityAttributes
        ] dip n>win32-error-string
        create-key-failed
    ] unless ;

: create-key ( hkey lsubkey -- hkey )
    f 0 KEY_ALL_ACCESS f create-key* drop ;

: close-key ( hkey -- )
    RegCloseKey dup ERROR_SUCCESS = [
        drop
    ] [
        n>win32-error-string throw
    ] if ;

:: with-open-registry-key ( key subkey mode quot -- )
    key subkey mode open-key :> hkey
    [ hkey quot call ]
    [ hkey close-key ]
    [ ] cleanup ; inline
    
:: with-create-registry-key ( key subkey quot -- )
    key subkey create-key :> hkey
    [ hkey quot call ]
    [ hkey close-key ]
    [ ] cleanup ; inline

<PRIVATE

: grow-buffer ( byte-array -- byte-array' )
    length 2 * <byte-array> ;

:: reg-query-value-ex ( key subkey ptr1 ptr2 buffer -- buffer )
    buffer length <uint> :> pdword
    key subkey ptr1 ptr2 buffer pdword [ RegQueryValueEx ] 2keep
    rot :> ret
    ret ERROR_SUCCESS = [
        *uint head
    ] [
        ret ERROR_MORE_DATA = [
            2drop
            key subkey ptr1 ptr2 buffer
            grow-buffer reg-query-value-ex
        ] [
            ret n>win32-error-string throw
        ] if
    ] if ;

TUPLE: registry-info
key
class-name
sub-keys
longest-subkey
longest-class-string
#values
max-value
max-value-data
security-descriptor
last-write-time ;

TUPLE: registry-enum-key ;


:: reg-enum-keys ( registry-info -- seq )
    registry-info sub-keys>> iota [
        [ registry-info key>> ] dip
        registry-value-max-length TCHAR <c-array> dup :> registry-value
        registry-value length dup :> registry-value-length
        f
        DWORD <c-object> dup :> type
        f ! BYTE <c-object> dup :> data
        f ! BYTE <c-object> dup :> buffer
        RegEnumKeyEx dup ERROR_SUCCESS = [
            
        ] [
        ] if
    ] map ;

:: reg-query-info-key ( key -- n )
    key
    MAX_PATH
    dup TCHAR <c-array> dup :> class-buffer
    swap <int> dup :> class-buffer-length
    f
    DWORD <c-object> dup :> sub-keys
    DWORD <c-object> dup :> longest-subkey
    DWORD <c-object> dup :> longest-class-string
    DWORD <c-object> dup :> #values
    DWORD <c-object> dup :> max-value
    DWORD <c-object> dup :> max-value-data
    DWORD <c-object> dup :> security-descriptor
    FILETIME <struct> dup :> last-write-time
    RegQueryInfoKey :> ret
    ret ERROR_SUCCESS = [
        key
        class-buffer
        sub-keys *uint
        longest-subkey *uint
        longest-class-string *uint
        #values *uint
        max-value *uint
        max-value-data *uint
        security-descriptor *uint
        last-write-time FILETIME>timestamp
        registry-info boa
    ] [
        ret n>win32-error-string
    ] if ;

: set-reg-key ( hkey value type lpdata cbdata -- )
    [ 0 ] 3dip
    RegSetValueEx dup ERROR_SUCCESS = [
        drop
    ] [ 
        "omg" throw
    ] if ;

: set-reg-binary ( hkey value lpdata cbdata -- )
    [ REG_BINARY ] 2dip set-reg-key ;

: set-reg-dword ( hkey value lpdata cbdata -- )
    [ REG_DWORD ] 2dip set-reg-key ;

: set-reg-dword-le ( hkey value lpdata cbdata -- )
    [ REG_DWORD_LITTLE_ENDIAN ] 2dip set-reg-key ;

: set-reg-dword-be ( hkey value lpdata cbdata -- )
    [ REG_DWORD_BIG_ENDIAN ] 2dip set-reg-key ;

: set-reg-expand-sz ( hkey value lpdata cbdata -- )
    [ REG_EXPAND_SZ ] 2dip set-reg-key ;

: set-reg-link ( hkey value lpdata cbdata -- )
    [ REG_LINK ] 2dip set-reg-key ;

: set-reg-multi-sz ( hkey value lpdata cbdata -- )
    [ REG_MULTI_SZ ] 2dip set-reg-key ;

: set-reg-none ( hkey value lpdata cbdata -- )
    [ REG_NONE ] 2dip set-reg-key ;

: set-reg-qword ( hkey value lpdata cbdata -- )
    [ REG_QWORD ] 2dip set-reg-key ;

: set-reg-qword-le ( hkey value lpdata cbdata -- )
    [ REG_QWORD_LITTLE_ENDIAN ] 2dip set-reg-key ;

: set-reg-sz ( hkey value lpdata cbdata -- )
    [ REG_SZ ] 2dip set-reg-key ;

PRIVATE>

: windows-performance-data ( -- byte-array )
    HKEY_PERFORMANCE_DATA "Global" f f
    21 2^ <byte-array> reg-query-value-ex ;
    
: read-registry ( key subkey -- registry-info )
    KEY_READ [ reg-query-info-key ] with-open-registry-key ;