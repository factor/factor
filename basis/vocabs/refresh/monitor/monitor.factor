! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs command-line concurrency.messaging
continuations init io.backend io.files io.monitors io.pathnames
kernel namespaces sequences sets splitting threads fry
tr vocabs vocabs.loader vocabs.refresh vocabs.cache ;
IN: vocabs.refresh.monitor

TR: convert-separators "/\\" ".." ;

: vocab-dir>vocab-name ( path -- vocab )
    trim-head-separators
    trim-tail-separators
    convert-separators ;

: path>vocab-name ( path -- vocab )
    dup ".factor" tail? [ parent-directory ] when ;

: chop-vocab-root ( path -- path' )
    "resource:" prepend-path normalize-path
    dup vocab-roots get
    [ normalize-path ] map
    [ head? ] with find nip
    ?head drop ;

: path>vocab ( path -- vocab )
    chop-vocab-root path>vocab-name vocab-dir>vocab-name ;

: monitor-loop ( monitor -- )
    #! On OS X, monitors give us the full path, so we chop it
    #! off if its there.
    [ next-change path>> path>vocab changed-vocab reset-cache ]
    [ monitor-loop ]
    bi ;

: (start-vocab-monitor) ( vocab-root -- )
    dup exists?
    [ [ t <monitor> monitor-loop ] with-monitors ] [ drop ] if ;

: start-vocab-monitor ( vocab-root -- )
    [ '[ [ _ (start-vocab-monitor) ] ignore-errors ] ]
    [ "Root monitor: " prepend ]
    bi spawn drop ;

: init-vocab-monitor ( -- )
    H{ } clone changed-vocabs set-global
    vocabs [ changed-vocab ] each ;

[
    "-no-monitors" (command-line) member? [
        [ drop ] add-vocab-root-hook set-global
        f changed-vocabs set-global
    ] [
        init-vocab-monitor
        vocab-roots get [ start-vocab-monitor ] each
        [ start-vocab-monitor ] add-vocab-root-hook set-global
    ] if
] "vocabs.refresh.monitor" add-startup-hook
