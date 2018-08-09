USING: accessors alien.libraries kernel sequences system vocabs ;
IN: alien.libraries.finder

HOOK: find-library* os ( name -- path/f )

: find-library ( name -- path/library-not-found )
    dup find-library* [ nip ] when* ;

: ?update-library ( name path abi -- )
    pick lookup-library [ dll>> dll-valid? ] [ f ] if* [
        3drop
    ] [
        [ find-library ] [ update-library ] bi*
    ] if ;

! Try to find the library from a list, but if it's not found,
! try to open a library that is the first name in that list anyway
! or "library_not_found" as a last resort for better debugging.
: find-library-from-list ( seq -- path/f )
    dup [ find-library* ] map-find drop
    [ ] [ ?first "library_not_found" or ] ?if ;


<LINUX
USING: alien.libraries.finder arrays assocs
combinators.short-circuit io io.encodings.utf8 io.files
io.files.info io.launcher kernel sequences sets splitting system
unicode ;

<PRIVATE

CONSTANT: mach-map {
    { ppc.64 { "libc6" "64bit" } }
    { x86.32 { "libc6" "x32" } }
    { x86.64 { "libc6" "x86-64" } }
}

: parse-ldconfig-lines ( string -- triple )
    [
        "=>" split1 [ [ blank? ] trim ] bi@
        [
            " " split1 [ "()" in? ] trim "," split
            [ [ blank? ] trim ] map
            [ ": Linux" swap subseq? ] reject
        ] dip 3array
    ] map ;

: load-ldconfig-cache ( -- seq )
    "/sbin/ldconfig -p" utf8 [ lines ] with-process-reader
    rest parse-ldconfig-lines ;

: ldconfig-arch ( -- str )
    mach-map cpu of { "libc6" } or ;

: name-matches? ( lib triple -- ? )
    first swap ?head [ ?first ch'. = ] [ drop f ] if ;

: arch-matches? ( lib triple -- ? )
    [ drop ldconfig-arch ] [ second swap subset? ] bi* ;

: ldconfig-matches? ( lib triple -- ? )
    { [ name-matches? ] [ arch-matches? ] } 2&& ;

PRIVATE>

M: linux find-library*
    "lib" prepend load-ldconfig-cache
    [ ldconfig-matches? ] with find nip ?first ;
LINUX>


<MACOS
USING: accessors alien.libraries.finder arrays assocs
combinators.short-circuit environment io.files io.files.info
io.pathnames kernel locals make namespaces sequences splitting
system ;

<PRIVATE

TUPLE: framework-info location name shortname version suffix ;

: make-framework-info ( filename -- info/f )
    [ framework-info new ] dip
    "/" split dup [ ".framework" tail? ] find drop [
        cut [
            [ "/" join ] bi@ [ >>location ] [ >>name ] bi*
        ] keep [
            rest dup ?first "Versions" = [
                rest dup empty? [
                    unclip swap [ >>version ] dip
                ] unless
            ] when ?first "_" split1 [ >>shortname ] [ >>suffix ] bi*
        ] unless-empty
    ] [ drop ] if* dup shortname>> empty? [ drop f ] when ;

CONSTANT: default-framework-fallback {
    "~/Library/Frameworks"
    "/Library/Frameworks"
    "/Network/Library/Frameworks"
    "/System/Library/Frameworks"
}

CONSTANT: default-library-fallback {
    "~/lib"
    "/usr/local/lib"
    "/lib"
    "/usr/lib"
}

SYMBOL: dyld-environment

: dyld-env ( name -- seq )
    dyld-environment get [ at ] [ os-env ] if* ;

: dyld-paths ( name -- seq )
    dyld-env [ ":" split ] [ f ] if* ;

: paths% ( name seq -- )
    [ prepend-path , ] with each ;

: dyld-override-search ( name -- seq )
    [
        dup make-framework-info [
            name>> "DYLD_FRAMEWORK_PATH" dyld-paths paths%
        ] when*

        file-name "DYLD_LIBRARY_PATH" dyld-paths paths%
    ] { } make ;

SYMBOL: dyld-executable-path

: dyld-executable-path-search ( name -- seq )
    "@executable_path/" ?head dyld-executable-path get and [
        dyld-executable-path get prepend-path
    ] [
        drop f
    ] if ;

:: dyld-default-search ( name -- seq )
    name make-framework-info :> framework
    name file-name :> basename
    "DYLD_FALLBACK_FRAMEWORK_PATH" dyld-paths :> fallback-framework-path
    "DYLD_FALLBACK_LIBRARY_PATH" dyld-paths :> fallback-library-path
    [
        name ,

        framework [
            name>> fallback-framework-path paths%
        ] when*

        basename fallback-library-path paths%

        framework fallback-framework-path empty? and [
            framework name>> default-framework-fallback paths%
        ] when

        fallback-library-path empty? [
            basename default-library-fallback paths%
        ] when
    ] { } make ;

: dyld-image-suffix-search ( seq -- str )
    "DYLD_IMAGE_SUFFIX" dyld-env [
        swap [
            [
                [
                    ".dylib" ?tail [ prepend ] dip
                    [ ".dylib" append ] when ,
                ] [
                    ,
                ] bi
            ] with each
        ] { } make
    ] when* ;

: dyld-search-paths ( name -- paths )
    [ dyld-override-search ]
    [ dyld-executable-path-search ]
    [ dyld-default-search ] tri 3append
    dyld-image-suffix-search ;

PRIVATE>

: dyld-find ( name -- path/f )
    dyld-search-paths
    [ { [ exists? ] [ file-info regular-file? ] } 1&& ] find
    [ nip ] when* ;

: framework-find ( name -- path )
    dup dyld-find [ nip ] [
        ".framework" over subseq-start [
            dupd head
        ] [
            [ ".framework" append ] keep
        ] if* file-name append-path dyld-find
    ] if* ;

M: macosx find-library*
    [ "lib" ".dylib" surround ]
    [ ".dylib" append ]
    [ ".framework/" over 3append ] tri 3array
    [ dyld-find ] map-find drop ;

MACOS>


<WINDOWS
USING: alien.libraries.finder arrays combinators.short-circuit
environment io.backend io.files io.files.info io.pathnames kernel
sequences splitting system system-info.windows ;

<PRIVATE

: search-paths ( -- seq )
    "resource:" normalize-path
    system-directory
    windows-directory 3array
    "PATH" os-env [ ";" split ] [ f ] if* append ;

: candidate-paths ( name -- seq )
    search-paths over ".dll" tail? [
        [ prepend-path ] with map
    ] [
        [
            [ prepend-path ]
            [ [ ".dll" append ] [ prepend-path ] bi* ] 2bi
            2array
        ] with map concat
    ] if ;

PRIVATE>

M: windows find-library*
    candidate-paths [
        { [ exists? ] [ file-info regular-file? ] } 1&&
    ] find nip ;
WINDOWS>
