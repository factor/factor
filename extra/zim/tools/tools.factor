! Copyright (C) 2023 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors combinators command-line destructors formatting
io io.directories io.encodings io.encodings.binary io.files
kernel math math.parser namespaces sequences uuid zim ;

IN: zim.tools

: zim-info ( zim args -- )
    drop {
        [ path>> "path: %s\n" printf ]
        [ header>> uuid>> uuid-unparse "uuid: %s\n" printf ]
        [ header>> entry-count>> "entries: %s\n" printf ]
        [ header>> cluster-count>> "clusters: %s\n" printf ]
        [ mime-types>> length "mime-types: %s\n" printf ]
        [
            drop -16 seek-end seek-input 16 read
            bytes>hex-string "checksum: %s\n" printf
        ]
        [
            [ header>> main-page>> ] [ read-entry-index ] bi
            [ url>> ] [ "-" ] if* "main: %s\n" printf
        ]
    } cleave ;

: zim-list ( zim args -- )
    drop [ length ] keep '[
        dup _ read-entry-index [ url>> ] [ "-" ] if*
        "%s: %s\n" printf
    ] each-integer ;

: zim-show ( zim args -- )
    [
        swap f -rot read-entry-url drop
        output-stream get binary re-encode stream-write
    ] with each ;

: zim-main ( zim args -- )
    drop read-main-page drop [
        output-stream get binary re-encode stream-write
    ] when* ;

: zim-dump ( zim args -- )
    ?first "." or dup make-directories [
        ! XXX: redirect-entry: write symlinks or HTML redirects
        [ first2 swap url>> binary set-file-contents ] each
    ] with-directory ;

: zim-usage ( -- )
    "Usage: zim.tools command zim-path [args...]" print
    nl
    "Commands:" print
    "    dump [directory]       extract all files" print
    "    info                   print zim info" print
    "    list                   list all entry urls" print
    "    show [urls...]         show contents of urls" print
    "    main                   show contents of main url" print
    ;

: zim-tools-main ( -- )
    command-line get dup length 2 < [
        drop zim-usage
    ] [
        unclip swap unclip read-zim [
            [
                swap rot {
                    { "dump" [ zim-dump ] }
                    { "info" [ zim-info ] }
                    { "list" [ zim-list ] }
                    { "show" [ zim-show ] }
                    { "main" [ zim-main ] }
                    [
                        "Unknown command: " prepend print
                        zim-usage 2drop
                    ]
                } case
            ] with-zim
        ] with-disposal
    ] if ;

MAIN: zim-tools-main
