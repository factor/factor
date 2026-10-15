USING: alien.libraries.finder assocs combinators io.files io.files.info io.pathnames kernel sequences system ;
IN: alien.libraries.finder.haiku
CONSTANT: haiku-library-directories
    { "/boot/home/config/non-packaged/lib" "/boot/home/config/lib"
      "/boot/system/non-packaged/lib" "/boot/system/lib" }
: haiku-library-name ( name -- filename )
    { { "c" [ "root" ] } { "m" [ "root" ] } { "rt" [ "root" ] } [ ] } case
    "lib" prepend ".so" append ;
M: haiku find-library*
    haiku-library-name haiku-library-directories
    [ swap append-path dup file-exists? [ drop f ] unless ] with map-find drop ;
