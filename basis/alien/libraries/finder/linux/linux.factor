! Copyright (C) 2013 Björn Lindqvist, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license
USING: accessors alien.data alien.libraries.finder arrays assocs
combinators combinators.short-circuit continuations endian environment
io io.directories io.encodings.binary io.encodings.utf8 io.files
io.files.info io.launcher io.pathnames io.standard-paths kernel layouts
libc locals make math sequences sets sorting.human splitting system unicode ;
IN: alien.libraries.finder.linux

<PRIVATE

CONSTANT: elf-machine-map {
    { ppc.32 20 } { ppc.64 21 } { x86.32 3 }
    { x86.64 62 } { arm.64 183 }
}

CONSTANT: emulation-map {
    { x86.32 "elf_i386" }
    { x86.64 "elf_x86_64" }
    { arm.64 "aarch64linux" }
}

: parse-ldconfig-lines ( string -- triple )
    [
        "=>" split1 [ [ unicode:blank? ] trim ] bi@
        [
            " " split1 [ "()" in? ] trim "," split
            [ [ unicode:blank? ] trim ] map
            [ ": Linux" subseq-of? ] reject
        ] dip 3array
    ] map ;

: load-ldconfig-cache ( -- seq )
    "ldconfig" find-in-path [
        { "/usr/sbin/ldconfig" "/sbin/ldconfig" }
        [ dup file-exists? [ file-executable? ] [ drop f ] if ] find nip
    ] unless*
    [
        "-p" 2array <process> swap >>command +closed+ >>stderr
        utf8 [ read-lines ] with-process-reader* nip 0 = [
            [ "=>" swap subseq? ] filter parse-ldconfig-lines
        ] [ drop { } ] if
    ] [ { } ] if* ;

! Inspect, do not dlopen, discovery candidates: loading would execute their
! constructors. Also reject linker scripts and foreign-architecture DSOs.
:: native-elf-header? ( bytes -- ? )
    bytes length 20 >= [
        bytes 4 head B{ 127 69 76 70 } =
        4 bytes nth cell 8 = 2 1 ? = and
        5 bytes nth alien.data:little-endian? 1 2 ? = and
        16 18 bytes subseq alien.data:little-endian? [ le> ] [ be> ] if 3 = and
        18 20 bytes subseq alien.data:little-endian? [ le> ] [ be> ] if
        elf-machine-map cpu of = and
    ] [ f ] if ;

: native-library? ( path -- ? )
    '[
        _ dup regular-file? [
            binary [ 20 read [ native-elf-header? ] [ f ] if* ] with-file-reader
        ] [ drop f ] if
    ]
    [ dup libc-error? [ drop f ] [ rethrow ] if ] recover ;

: name-matches? ( lib triple -- ? )
    first swap ?head [ ?first CHAR: . = ] [ drop f ] if ;

: arch-matches? ( lib triple -- ? )
    nip third native-library? ;

: ldconfig-matches? ( lib triple -- ? )
    { [ name-matches? ] [ arch-matches? ] } 2&& ;

: find-ldconfig ( name -- path/f )
    load-ldconfig-cache [ ldconfig-matches? ] with find nip ?last ;

:: find-ld ( name -- path/f )
    "ld" find-in-path :> linker
    emulation-map cpu of :> emulation
    linker emulation and [
        name <process>
            [
                linker , "-t" ,
                "LD_LIBRARY_PATH" os-env "" or ":" split [ "-L" , , ] each
                "-m" emulation append ,
                "-o" , "/dev/null" , "-l" name append ,
            ] { } make >>command
            +closed+ >>stderr
        utf8 [ read-lines ] with-process-reader* 2drop
        [ subseq? ] with find nip
        dup [ dup native-library? [ drop f ] unless ] when
    ] [ f ] if ;

: library-search-directories ( -- directories )
    "LD_LIBRARY_PATH" os-env [
        ":" split [ dup empty? [ drop "." ] when ] map
    ] [ { } ] if*
    {
        { x86.64 "x86_64" } { x86.32 "i386" } { arm.64 "aarch64" }
        { ppc.32 "powerpc" } { ppc.64 "powerpc64" }
    } cpu of [
        "/etc/ld-musl-" ".path" surround
        dup file-exists? [ utf8 file-contents ":\n" split harvest append ] [ drop ] if
    ] when*
    { "/lib" "/usr/lib" "/lib64" "/usr/lib64" "/usr/local/lib" } append
    {
        { x86.64 "x86_64-linux-gnu" } { x86.32 "i386-linux-gnu" }
        { arm.64 "aarch64-linux-gnu" }
    } cpu of [
        [ "/lib" swap append-path ] [ "/usr/lib" swap append-path ] bi 2array append
    ] when* members ;

:: find-in-library-directories ( name -- path/f )
    name ".so" append :> stem
    library-search-directories [| directory |
        directory stem append-path :> exact
        exact file-exists? [ exact native-library? ] [ f ] if [ exact ] [
            directory directory? [
                directory directory-files
                [ stem "." append head? ] filter human-sort reverse
                [ directory swap append-path dup native-library? [ drop f ] unless ] map-find drop
            ] [ f ] if
        ] if
    ] map-find drop ;

PRIVATE>

M: linux find-library*
    [ "lib" prepend ] keep 2array [
        { [ find-in-library-directories ] [ find-ldconfig ] [ find-ld ] } 1||
    ] map-find drop ;
