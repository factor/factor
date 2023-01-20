! Copyright (C) 2010 Doug Coleman.
! Copyright (C) 2018 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data byte-arrays
classes.struct continuations io.encodings.string
io.encodings.utf16 kernel literals locals math sequences sets
splitting windows windows.advapi32 windows.errors
windows.kernel32 windows.time windows.types ;
IN: windows.registry

ERROR: open-key-failed key subkey mode error-string ;
ERROR: create-key-failed hKey lpSubKey lpClass dwOptions
samDesired lpSecurityAttributes phkResult lpdwDisposition ;

CONSTANT: registry-value-max-length 16384

:: open-key ( key subkey mode -- hkey )
    key subkey 0 mode 0 HKEY <ref>
    [
        RegOpenKeyEx dup ERROR_SUCCESS = [
            drop
        ] [
            [ key subkey mode ] dip n>win32-error-string
            open-key-failed
        ] if
    ] keep HKEY deref ;

:: create-key* ( hKey lpSubKey lpClass dwOptions samDesired lpSecurityAttributes -- hkey new? )
    f :> ret!
    hKey lpSubKey 0 lpClass dwOptions samDesired lpSecurityAttributes
    0 HKEY <ref>
    0 DWORD <ref>
    [ RegCreateKeyEx ret! ] 2keep
    [ HKEY deref ]
    [ DWORD deref REG_CREATED_NEW_KEY = ] bi*
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
    RegCloseKey n>win32-error-check ;

:: with-open-registry-key ( key subkey mode quot -- )
    key subkey mode open-key :> hkey
    [ hkey quot call ]
    [ hkey close-key ]
    finally ; inline

:: with-create-registry-key ( key subkey quot -- )
    key subkey create-key :> hkey
    [ hkey quot call ]
    [ hkey close-key ]
    finally ; inline

<PRIVATE

: grow-buffer ( byte-array -- byte-array' )
    length 2 * <byte-array> ;

PRIVATE>

:: reg-query-value-ex ( key value-name ptr1 lpType buffer -- buffer )
    buffer length uint <ref> :> pdword
    key value-name ptr1 lpType buffer pdword [ RegQueryValueEx ] 2keep
    rot :> ret
    ret ERROR_SUCCESS = [
        uint deref head
    ] [
        ret ERROR_MORE_DATA = [
            2drop
            key value-name ptr1 lpType buffer
            grow-buffer reg-query-value-ex
        ] [
            ret throw-windows-error
        ] if
    ] if ;

: delete-value ( key value-name -- )
    RegDeleteValue dup ERROR_SUCCESS = [
        drop
    ] [
        n>win32-error-string throw
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
    registry-info sub-keys>> <iota> [
        [ registry-info key>> ] dip
        registry-value-max-length TCHAR <c-array> dup :> registry-value
        registry-value length dup :> registry-value-length
        f
        0 DWORD <ref> dup :> type
        f ! 0 BYTE <ref> dup :> data
        f ! 0 BYTE <ref> dup :> buffer
        RegEnumKeyEx dup ERROR_SUCCESS = [

        ] [
        ] if
    ] map ;

:: reg-query-info-key ( key -- n )
    key
    MAX_PATH
    dup TCHAR <c-array> dup :> class-buffer
    swap int <ref> dup :> class-buffer-length
    f
    0 DWORD <ref> dup :> sub-keys
    0 DWORD <ref> dup :> longest-subkey
    0 DWORD <ref> dup :> longest-class-string
    0 DWORD <ref> dup :> #values
    0 DWORD <ref> dup :> max-value
    0 DWORD <ref> dup :> max-value-data
    0 DWORD <ref> dup :> security-descriptor
    FILETIME new dup :> last-write-time
    RegQueryInfoKey :> ret
    ret ERROR_SUCCESS = [
        key
        class-buffer
        sub-keys uint deref
        longest-subkey uint deref
        longest-class-string uint deref
        #values uint deref
        max-value uint deref
        max-value-data uint deref
        security-descriptor uint deref
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

: windows-performance-data ( -- byte-array )
    HKEY_PERFORMANCE_DATA "Global" f f
    21 2^ <byte-array> reg-query-value-ex ;

: read-registry ( key subkey -- registry-info )
    KEY_READ [ reg-query-info-key ] with-open-registry-key ;

:: change-registry-value ( key subkey value-name quot: ( value -- value' ) -- )
    0 DWORD <ref> :> type
    key subkey flags{ KEY_QUERY_VALUE KEY_SET_VALUE } [
        dup :> hkey value-name f type MAX_PATH <byte-array>
        reg-query-value-ex
        type DWORD deref ${ REG_SZ REG_EXPAND_SZ REG_MULTI_SZ } in?
        dup :> string-type? [
            utf16n decode type DWORD deref REG_MULTI_SZ = [
                "\0" split 2
            ] [ 1 ] if head*
        ] when
        quot call( x -- x' )
        string-type? [
            type DWORD deref REG_MULTI_SZ = [
                "\0" join 2
            ] [ 1 ] if [ CHAR: \0 suffix ] times utf16n encode
        ] when
        [ hkey value-name type DWORD deref ] dip dup length
        set-reg-key
    ] with-open-registry-key ;

:: query-registry ( key subkey value-name -- value )
    key subkey KEY_READ [
        value-name f 0 DWORD <ref> dup :> ptype MAX_PATH <byte-array> reg-query-value-ex
        ptype DWORD deref dup :> type ${ REG_SZ REG_EXPAND_SZ REG_MULTI_SZ } in?
        [ utf16n decode type REG_MULTI_SZ = [ "\0" split 2 ] [ 1 ] if head* ] when
    ] with-open-registry-key ;
