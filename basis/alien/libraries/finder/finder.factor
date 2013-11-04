USING:
    alien.libraries
    arrays
    assocs
    formatting
    io.pathnames
    kernel
    sequences
    system ;
IN: alien.libraries.finder

CONSTANT: name-formats {
    { windows { "lib%s.dll" "%s.dll" } }
    { unix { "lib%s.so.0" } }
    { macosx { "lib%s.0.dylib" } }
}

! On Windows, bundled dlls are shipped in a directory named "dlls" in
! the Factor distribution. On other operating systems, the dynamic
! linker can itself figure out where libraries are located.
CONSTANT: search-paths {
    { windows { "" "dlls" } }
    { unix { "" } }
    { macosx { "" } }
}

: vsprintf1 ( obj fmt -- str )
    [ 1array ] dip vsprintf ;

: path-formats ( -- path-formats )
    search-paths name-formats [ os of ] bi@
    [ append-path ] cartesian-map concat ;

: candidate-paths ( name -- paths )
    path-formats [ vsprintf1 ] with map ;

: find-library ( name -- path/f )
    candidate-paths [ dlopen dll-valid? ] map-find nip ;
