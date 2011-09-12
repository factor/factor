USING: alien.c-types alien.syntax io.encodings.utf8 ;
IN: alien.libraries.unix

FUNCTION-ALIAS: (dlerror)
    c-string[utf8] dlerror ( ) ;
