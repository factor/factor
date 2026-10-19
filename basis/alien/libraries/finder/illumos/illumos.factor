USING: alien.libraries.finder io.files io.pathnames kernel locals
sequences system ;
IN: alien.libraries.finder.illumos

CONSTANT: illumos-library-directories
    { "/lib/64" "/usr/lib/64" "/usr/lib/amd64" "/usr/lib" "/usr/gnu/lib" "/usr/local/lib" }

M:: illumos find-library* ( name -- path/f )
    name "lib" prepend ".so" append :> file
    illumos-library-directories
    [ file append-path dup file-exists? [ drop f ] unless ] map-find drop ;
