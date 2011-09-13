USING: alien.libraries io.pathnames system windows.errors ;
IN: alien.libraries.windows

M: windows >deployed-library-path
    file-name ;

M: windows dlerror ( -- message )
    win32-error-string ;
