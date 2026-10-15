USING: alien.libraries.finder io.directories io.files io.files.info io.pathnames
    kernel locals sequences sorting splitting system ;
IN: alien.libraries.finder.netbsd

:: library-file? ( name library -- ? )
    "lib" name append ".so" append :> base
    library base = library base "." append head? or ;

M:: netbsd find-library* ( name -- path/f )
    { "/lib" "/usr/lib" "/usr/local/lib" "/usr/X11R6/lib" "/usr/pkg/lib" }
    [| directory |
        directory file-exists? [
            directory directory-files sort
            [ name swap library-file? ] find nip
            [ directory swap append-path ] [ f ] if*
        ] [ f ] if
    ] map-find drop ;
