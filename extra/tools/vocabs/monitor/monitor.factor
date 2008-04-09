! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: threads io.files io.monitors init kernel
vocabs vocabs.loader tools.vocabs namespaces continuations
sequences splitting assocs ;
IN: tools.vocabs.monitor

: vocab-dir>vocab-name ( path -- vocab )
    left-trim-separators right-trim-separators
    { { CHAR: / CHAR: . } { CHAR: \\ CHAR: . } } substitute ;

: path>vocab-name ( path -- vocab )
    dup ".factor" tail? [ parent-directory ] when
     ;

: chop-vocab-root ( path -- path' )
    "resource:" prepend-path (normalize-path)
    dup vocab-roots get
    [ (normalize-path) ] map
    [ head? ] with find nip
    ?head drop ;

: path>vocab ( path -- vocab )
    chop-vocab-root path>vocab-name vocab-dir>vocab-name ;

: changed-vocab ( vocab -- )
    dup vocab
    [ dup changed-vocabs get-global set-at ] [ drop ] if ;

: monitor-thread ( monitor -- )
    #! On OS X, monitors give us the full path, so we chop it
    #! off if its there.
    next-change drop path>vocab changed-vocab reset-cache ;

: start-monitor-thread ( monitor -- )
    #! Silently ignore errors during monitor creation since
    #! monitors are not supported on all platforms.
    [ monitor-thread t ] curry
    "Vocabulary monitor" spawn-server
    drop ;

: start-monitor-threads ( -- )
    [
        "" resource-path t <monitor> start-monitor-thread
        H{ } clone changed-vocabs set-global
        vocabs [ changed-vocab ] each
    ] ignore-errors ;

[ start-monitor-threads ] "tools.vocabs.monitor" add-init-hook
