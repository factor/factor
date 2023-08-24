USING: alien.libraries io.pathnames system windows.errors
windows.kernel32 ;
IN: alien.libraries.windows

M: windows >deployed-library-path
    file-name ;

M: windows dlerror ( -- message )
    GetLastError n>win32-error-string ;
