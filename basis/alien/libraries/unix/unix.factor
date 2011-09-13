USING: alien.c-types alien.libraries alien.syntax io.encodings.utf8
io.pathnames system ;
IN: alien.libraries.unix

FUNCTION-ALIAS: (dlerror)
    c-string dlerror ( ) ;

M: unix dlerror (dlerror) ;

M: unix >deployed-library-path
    file-name "$ORIGIN" prepend-path ;

M: macosx >deployed-library-path
    file-name "@executable_path/../Frameworks" prepend-path ;

