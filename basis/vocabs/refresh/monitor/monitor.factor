! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors command-line continuations fry init io
io.backend io.files io.monitors io.pathnames kernel namespaces
prettyprint sequences splitting threads tr vocabs vocabs.cache
vocabs.loader vocabs.private vocabs.refresh ;
IN: vocabs.refresh.monitor

TR: convert-separators "/\\" ".." ;

: vocab-dir>vocab-name ( path -- vocab/f )
    trim-head-separators
    trim-tail-separators
    convert-separators
    dup valid-vocab-name? and* ;

: path>vocab-parent-dir ( path -- path' )
    dup ".factor" tail? [ parent-directory ] when ;

: chop-vocab-root ( path -- path' )
    "resource:" prepend-path normalize-path
    dup vocab-roots get
    [ [ normalize-path ] map ]
    [ [ resolve-symlinks ] map ] bi append
    [ head? ] with find nip
    ?head drop ;

: path>vocab-name ( path -- vocab-name/f )
    chop-vocab-root path>vocab-parent-dir vocab-dir>vocab-name ;

: monitor-loop ( monitor -- )
    ! On OS X, monitors give us the full path, so we chop it
    ! off if its there.
    [
        next-change path>>
        [
            path>vocab-name [
                [ changed-vocab ] [ reset-cache ] bi
            ] when*
        ] [
            [
                [ "monitor-loop warning for path ``" "``:" surround write ]
                [ . ] bi* flush
            ] with-global
        ] recover
    ] [ monitor-loop ] bi ;

: (start-vocab-monitor) ( vocab-root -- )
    [ [ t <monitor> monitor-loop ] with-monitors ] when-file-exists ;

: start-vocab-monitor ( vocab-root -- )
    [
        dup '[
            [ _ (start-vocab-monitor) ]
            [
                [
                    _ "fatal error for monitor root ``" "``: " surround write
                    . flush
                ] with-global
            ] recover
        ]
    ] [ "Root monitor: " prepend ]
    bi spawn drop ;

: init-vocab-monitor ( -- )
    HS{ } clone changed-vocabs set-global
    loaded-vocab-names [ changed-vocab ] each ;

STARTUP-HOOK: [
    "-no-monitors" (command-line) member? [
        [ drop ] add-vocab-root-hook set-global
        f changed-vocabs set-global
    ] [
        init-vocab-monitor
        vocab-roots get [ start-vocab-monitor ] each
        [ start-vocab-monitor ] add-vocab-root-hook set-global
    ] if
]
