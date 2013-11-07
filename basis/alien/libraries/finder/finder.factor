USING:
    alien.libraries
    arrays
    assocs
    combinators
    formatting
    io io.encodings.utf8 io.launcher io.pathnames
    kernel
    sequences
    splitting
    system ;
IN: alien.libraries.finder

! Util
: vsprintf1 ( obj fmt -- str )
    [ 1array ] dip vsprintf ;

CONSTANT: name-formats {
    { windows { "lib%s.dll" "%s.dll" } }
    { linux { "lib%s.so" } }
    { unix { "lib%s.so" } }
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

: path-formats ( -- path-formats )
    search-paths name-formats [ os of ] bi@
    [ append-path ] cartesian-map concat ;

! Find lib using ldconfig
CONSTANT: mach-map {
    { ppc.64 "libc6,64bit" }
    { x86.32 "libc6,x86-32" }
    { x86.64 "libc6,x86-64" }
}

: ldconfig-cache ( -- seq )
    "/sbin/ldconfig -p" utf8 [ lines ] with-process-reader rest
    [ "=>" "" replace "\t " split harvest ] map ;

: ldconfig-filter ( -- str )
    mach-map cpu of dup "libc6" ? "(" ")" surround ;

: ldconfig-matches? ( lib this-lib this-arch -- ? )
    [ start 0 = ] [ ldconfig-filter = ] bi* and ;

: ldconfig-find-soname ( lib -- seq )
    name-formats os of first vsprintf1
    ldconfig-cache [ first2 ldconfig-matches? ] with filter [ first ] map ;

: candidate-paths ( name -- paths )
    {
        { [ os windows? ] [ path-formats [ vsprintf1 ] with map ] }
        { [ os linux? ] [ ldconfig-find-soname ] }
    } cond ;

: find-library ( name -- path/f )
    candidate-paths [ dlopen dll-valid? ] map-find nip ;
