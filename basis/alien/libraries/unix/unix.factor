USING: alien.c-types alien.libraries alien io.encodings.utf8
io.pathnames system ;
IN: alien.libraries.unix

: (dlerror) ( -- string )
    \ c-string f "dlerror" { } alien-invoke ; inline

M: unix dlerror (dlerror) ;

M: unix >deployed-library-path
    file-name "$ORIGIN" prepend-path ;

M: macosx >deployed-library-path
    file-name "@executable_path/../Frameworks" prepend-path ;
