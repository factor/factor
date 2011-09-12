USING: windows.errors ;
IN: alien.libraries.windows

: (dlerror) ( -- message )
    win32-error-string ;
