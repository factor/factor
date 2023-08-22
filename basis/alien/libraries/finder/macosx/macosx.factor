! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors alien.c-types alien.libraries.finder
alien.syntax arrays assocs combinators environment io.files
io.files.info io.pathnames kernel make math.order namespaces
sequences splitting system system-info ;

IN: alien.libraries.finder.macosx

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

FUNCTION: bool _dyld_shared_cache_contains_path ( c-string name )

: use-dyld-shared-cache? ( -- ? )
    os-version { 11 0 0 } after=? ;

PRIVATE>

: dyld-find ( name -- path/f )
    dyld-search-paths [
        {
            { [ dup file-exists? ] [ file-info regular-file? ] }
            { [ use-dyld-shared-cache? ] [ _dyld_shared_cache_contains_path ] }
            [ drop f ]
        } cond
    ] find nip ;

: framework-find ( name -- path )
    dup dyld-find [ nip ] [
        dup ".framework" subseq-index [
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
